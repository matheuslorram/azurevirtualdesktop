param name string
param tags object
param location string
param hostPoolId string

resource applicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2021-03-09-preview' = {
  name: 'vdag-${name}'
  location: location
  tags: tags
  properties: {
    applicationGroupType: 'Desktop'
    hostPoolArmPath: hostPoolId
  }
}

output id string = applicationGroup.id
output Name string = applicationGroup.name

