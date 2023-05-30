//Parametros 
param hostpoolName string
param workspaceName string
param appgroupName string
param logAnalyticsName string = 'monitoring-${appgroupName}'

//Recuperação dos recursos existentes
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsName
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
//Diagnostic Settings 
resource hostpoolDiagName 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${hostpoolName}'
  scope: hostPool
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'Checkpoint'
        enabled: true
      }
      {
        category: 'Error'
        enabled: true
      }
      {
        category: 'Management'
        enabled: true
      }
      {
        category: 'Connection'
        enabled: true
      }
      {
        category: 'HostRegistration'
        enabled: true
      }
      {
        category: 'AgentHealthStatus'
        enabled: true
      }
      {
        category: 'NetworkData'
        enabled: true
      }
      {
        category: 'SessionHostManagement'
        enabled: true
      }
    ]
  }
  dependsOn:[
    logAnalytics
  ]
}
resource appGroupDiagName 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${appgroupName}'
  scope: appGroup
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'Checkpoint'
        enabled: true
      }
      {
        category: 'Error'
        enabled: true
      }
      {
        category: 'Management'
        enabled: true
      }
    ]
  }
  dependsOn:[
    logAnalytics
  ]
}
resource workspaceDiagName 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${workspaceName}'
  scope: workspace
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'Checkpoint'
        enabled: true
      }
      {
        category: 'Error'
        enabled: true
      }
      {
        category: 'Management'
        enabled: true
      }
      {
        category: 'Feed'
        enabled: true
      }
    ]
  }
  dependsOn:[
    logAnalytics
  ]
}

//Contadores de metricas VMs
resource workspaceName_perfcounter1 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter1'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: 'C:'
    intervalSeconds: 60
    counterName: '% Free Space'
  }
}
resource workspaceName_perfcounter2 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter2'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: 'C:'
    intervalSeconds: 30
    counterName: 'Avg. Disk Queue Length'
  }
}
resource workspaceName_perfcounter3 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter3'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: 'C:'
    intervalSeconds: 60
    counterName: 'Avg. Disk sec/Transfer'
  }
}
resource workspaceName_perfcounter4 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter4'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'LogicalDisk'
    instanceName: 'C:'
    intervalSeconds: 30
    counterName: 'Current Disk Queue Length'
  }
}
resource workspaceName_perfcounter5 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter5'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Available Mbytes'
  }
}
resource workspaceName_perfcounter6 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter6'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Page Faults/sec'
  }
}
resource workspaceName_perfcounter7 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter7'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Pages/sec'
  }
}
resource workspaceName_perfcounter8 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter8'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 30
    counterName: '% Committed Bytes In Use'
  }
}
resource workspaceName_perfcounter9 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter9'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Avg. Disk Queue Length'
  }
}
resource workspaceName_perfcounter10 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter10'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Avg. Disk sec/Read'
  }
}
resource workspaceName_perfcounter11 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter11'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Avg. Disk sec/Transfer'
  }
}
resource workspaceName_perfcounter12 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter12'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Avg. Disk sec/Write'
  }
}
resource workspaceName_perfcounter18 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter18'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Processor Information'
    instanceName: '_Total'
    intervalSeconds: 30
    counterName: '% Processor Time'
  }
}
resource workspaceName_perfcounter19 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter19'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Terminal Services'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Active Sessions'
  }
}
resource workspaceName_perfcounter20 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter20'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Terminal Services'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Inactive Sessions'
  }
}
resource workspaceName_perfcounter21 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter21'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'Terminal Services'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Total Sessions'
  }
}
resource workspaceName_perfcounter22 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter22'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'User Input Delay per Process'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Max Input Delay'
  }
}
resource workspaceName_perfcounter23 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter23'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'User Input Delay per Session'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Max Input Delay'
  }
}
resource workspaceName_perfcounter24 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter24'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'RemoteFX Network'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Current TCP RTT'
  }
}
resource workspaceName_perfcounter25 'Microsoft.OperationalInsights/workspaces/datasources@2015-11-01-preview' = {
  parent: logAnalytics
  name: 'perfcounter25'
  kind: 'WindowsPerformanceCounter'
  properties: {
    objectName: 'RemoteFX Network'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Current UDP Bandwidth'
  }
}






// @description('Location for all resources.')
// param events string = resourceGroup().location

// var evtObj = json(events)

// resource workspaceName_evtObj_deployedName 'Microsoft.OperationalInsights/workspaces/datasources@2020-08-01' = [for item in evtObj: {
//   name: '${logAnalytics.name}/${item.deployedName}'
//   kind: 'WindowsEvent'
//   properties: {
//     eventLogName: item.name
//     eventTypes: item.types
//   }
//   dependsOn: [
//     logAnalytics
//   ]
// }]
