targetScope = 'subscription'

param name string = ''
param location string = ''
param tags object
param aadJoin bool
param localAdminName string
@secure()
param localAdminPassword string 
param maxSessionLimit int = 999999
param vmSize string
param vmCount int = 1
param vmLicenseType string
// param dnsServer string = ''
param domainToJoin string = ''
param domainUserName string = ''
@secure()
param domainPassword string = ''
param ouPath string = ''
param subName string = ''
param hostPoolType string = ''
param imgID string = '/subscriptions/6e14122b-c3a3-4468-b9d6-2d6883f0b369/resourceGroups/rg-tech-srv/providers/Microsoft.Compute/galleries/vmgalleryavd/images/imgdefinitionavd'

resource rg_tech_avd 'Microsoft.Resources/resourceGroups@2020-06-01' existing ={
  name: 'rg-tech-avd'
}
resource vnet_avd 'Microsoft.Network/virtualNetworks@2022-07-01' existing ={
  scope: rg_tech_avd
  name: 'vnet-tech-avd'
}
module hostPool 'modules/hostPools.bicep' = {
  scope: rg_tech_avd
  name: 'hostPoolDeploy'
  params: {
    name: name
    tags: tags
    location: location
    aadJoin: aadJoin
    hostPoolType: hostPoolType
    maxSessionLimit: maxSessionLimit
  }
}
output hostPoolName string = hostPool.outputs.Name
output hostPoolID string = hostPool.outputs.id

module applicationGroup 'modules/applicationGroup.bicep' = {
  scope: rg_tech_avd
  name: 'applicationGroupDeploy'
  params: {
    name: name
    tags: tags
    location: location
    hostPoolId: hostPool.outputs.id
  }
  dependsOn:[
    hostPool
  ]
}
output appGroupName string = applicationGroup.outputs.Name
output appGroupID string = applicationGroup.outputs.id

module workspace 'modules/workspace.bicep' = {
  scope: rg_tech_avd
  name: 'workspaceDeploy'
  params: {
    name: name
    tags: tags
    location: location
    applicationGroupId: applicationGroup.outputs.id
  }
  dependsOn:[
    applicationGroup
  ]
}
output workspaceName string = workspace.outputs.Name

module Analytics 'modules/logAnalytics.bicep'={
  scope: rg_tech_avd
  name: 'analytics-deploy'
  params: {
    appgroupName: applicationGroup.outputs.Name
    location: location
  }
}
module sessionhost 'modules/sessionHost.bicep'={
  scope: rg_tech_avd
  name: 'sessionHostDeploy'
  params: {
    appgroupName: applicationGroup.outputs.Name
    hostpoolName: hostPool.outputs.Name
    workspaceName: workspace.outputs.Name
    imgID: imgID
    WorkspaceResourceId: Analytics.outputs.logID
    osType:'Windows'
    name: name
    tags: tags
    location: location
    localAdminName: localAdminName
    localAdminPassword: localAdminPassword
    subnetName: subName
    vmSize: vmSize
    count: vmCount
    licenseType: vmLicenseType
    aadJoin: aadJoin
    domainToJoin: domainToJoin
    domainPassword: domainPassword
    domainUserName: domainUserName
    ouPath: ouPath
    vnetId: vnet_avd.id
  }
  dependsOn: [
    hostPool
    Analytics
  ]
}







