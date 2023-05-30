param name string
param tags object
param location string
param aadJoin bool
param count int
param vnetId string
param subnetName string
param localAdminName string
@secure()
param localAdminPassword string
param vmSize string
@allowed([
  'Windows_Client'
  'Windows_Server'
])
param licenseType string = 'Windows_Client'
param domainToJoin string
param domainUserName string
@secure()
param domainPassword string
@description('Set of bit flags that define the join options. Default value of 3 is a combination of NETSETUP_JOIN_DOMAIN (0x00000001) & NETSETUP_ACCT_CREATE (0x00000002) i.e. will join the domain and create the account on the domain. For more information see https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx')
param domainJoinOptions int = 3
param ouPath string
param installNVidiaGPUDriver bool = false
param imgID string 
@description('OS Type, Example: Linux / Windows')
param osType string
param hostpoolName string
param workspaceName string
param appgroupName string
@description('Workspace Resource ID.')
param WorkspaceResourceId string
param extensionName string = 'AdminCenter'
param extensionPublisher string = 'Microsoft.AdminCenter'
param extensionType string = 'AdminCenter'
param extensionVersion string = '0.0'
param port string ='6516'
param salt string = 'wac'

// var VmNamevar = split(VmResourceId, '/')[8]
var DaExtensionName = ((toLower(osType) == 'windows') ? 'DependencyAgentWindows' : 'DependencyAgentLinux')
var DaExtensionType = ((toLower(osType) == 'windows') ? 'DependencyAgentWindows' : 'DependencyAgentLinux')
var DaExtensionVersion = '9.5'
var MmaExtensionName = ((toLower(osType) == 'windows') ? 'MMAExtension' : 'OMSExtension')
var MmaExtensionType = ((toLower(osType) == 'windows') ? 'MicrosoftMonitoringAgent' : 'OmsAgentForLinux')
var MmaExtensionVersion = ((toLower(osType) == 'windows') ? '1.0' : '1.4')

// Retrieve the host pool info to pass into the module that builds session hosts. These values will be used when invoking the VM extension to install AVD agents
resource hostPoolToken 'Microsoft.DesktopVirtualization/hostPools@2021-01-14-preview' existing = {
  name: 'vdpool-${name}'
}
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-03-09-preview' existing = {
  name: hostpoolName
}
resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2021-03-09-preview' existing = {
  name: appgroupName
}
resource workspace 'Microsoft.DesktopVirtualization/workspaces@2021-03-09-preview' existing = {
  name: workspaceName
}
resource networkInterface 'Microsoft.Network/networkInterfaces@2019-07-01' = [for i in range(0, count): {
  name: 'nic-${take(name, 10)}-${i + 1}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnetId}/subnets/${subnetName}'          
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}]
resource sessionHost 'Microsoft.Compute/virtualMachines@2019-07-01' = [for i in range(0, count): {
  name: 'vm${take(name, 10)}-${i + 1}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    osProfile: {
      computerName: 'vm${take(name, 10)}-${i + 1}'
      adminUsername: localAdminName
      adminPassword: localAdminPassword
      windowsConfiguration:{
        enableAutomaticUpdates:false
        provisionVMAgent:true
      }
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        id: imgID
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk:{
        //storageAccountType: ephemeral ? 'StandardSSD_LRS' : vmDiskType
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    licenseType: licenseType
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: networkInterface[i].id
        }
      ]
    }    
  }
  dependsOn: [
    networkInterface[i]
  ]
}]
resource sessionHostDomainJoin 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, count): if (!aadJoin) {
  name: '${sessionHost[i].name}/JoinDomain'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainToJoin
      ouPath: ouPath
      user: '${domainToJoin}\\${domainUserName}'
      restart: true
      options: domainJoinOptions
    }
    protectedSettings: {
      password: domainPassword
    }
  }
  dependsOn: [
    sessionHost[i]
  ]
}]
resource sessionHostAADLogin 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, count): if (aadJoin) {
  name: '${sessionHost[i].name}/AADLoginForWindows'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}]
resource sessionHostAVDAgent 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, count): {
  name: '${sessionHost[i].name}/AddSessionHost'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: 'https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_8-16-2021.zip'
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPoolToken.name
        registrationInfoToken: hostPoolToken.properties.registrationInfo.token
        aadJoin: aadJoin
      }
    }
  }
  dependsOn: [
    sessionHostDomainJoin[i]
  ]
}]
resource sessionHostGPUDriver 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, count): if (installNVidiaGPUDriver) {
  name: '${sessionHost[i].name}/InstallNvidiaGpuDriverWindows'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.HpcCompute'
    type: 'NvidiaGpuDriverWindows'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {}
  }
}]
resource daExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = [for i in range(0, count):{
  parent: sessionHost[i]
  name: DaExtensionName
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: DaExtensionType
    typeHandlerVersion: DaExtensionVersion
    autoUpgradeMinorVersion: true
  }
}]
resource mmaExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = [for i in range(0, count):{
  parent: sessionHost[i]
  name: MmaExtensionName
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: MmaExtensionType
    typeHandlerVersion: MmaExtensionVersion
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: reference(WorkspaceResourceId, '2021-12-01-preview').customerId
      azureResourceId: sessionHost[i].id
      stopOnMultipleConnections: true
    }
    protectedSettings: {
      workspaceKey: listKeys(WorkspaceResourceId, '2021-12-01-preview').primarySharedKey
    }
  }
}]
resource vmName_extension 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = [for i in range(0, count):{
  name: '${sessionHost[i]}/${extensionName}'
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionType
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    settings: {
      port: port
      salt: salt
      cspFrameAncestors: [
        'https://*.hosting.portal.azure.net'
        'https://localhost:1340'
        'https://ms.portal.azure.com'
        'https://portal.azure.com'
        'https://preview.portal.azure.com'
      ]
      corsOrigins: [
        'https://ms.portal.azure.com'
        'https://portal.azure.com'
        'https://portal-s1.site.wac.azure.com'
        'https://portal-s1.site.waconazure.com'
        'https://portal-s2.site.wac.azure.com'
        'https://portal-s2.site.waconazure.com'
        'https://portal-s3.site.wac.azure.com'
        'https://portal-s3.site.waconazure.com'
        'https://portal-s4.site.wac.azure.com'
        'https://portal-s4.site.waconazure.com'
        'https://portal-s5.site.wac.azure.com'
        'https://portal-s5.site.waconazure.com'
        'https://preview.portal.azure.com'
        'https://waconazure.com'
      ]
    }
  }
}]
// param events string = ''
module diagnostic 'diagnostics.bicep'={
  name: 'diag-deploy'
  params: {
    // events: events
    appgroupName: appGroup.name
    hostpoolName: hostPool.name
    workspaceName: workspace.name
  }
  dependsOn:[
    sessionHostAVDAgent
  ]
}


