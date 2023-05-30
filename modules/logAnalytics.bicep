param appgroupName string
param location string


resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01'={
  name: 'monitoring-${appgroupName}'
  location: location
}

output logID string = logAnalytics.id
