param name string
param tags object
param location string

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-04-01' = {
  name: 'nsg-${name}'
  location: location
  properties: {
    securityRules: [
      {
        name:'AllowWACPort'
        properties:{
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'TCP'
          sourceAddressPrefix:'*'
          sourcePortRange:'*'
          destinationAddressPrefix:'*'
          destinationPortRange:'6516'
          priority: 100
        }
      }
      {
        name:'AllowWACPort'
        properties:{
          access: 'Allow'
          direction: 'Outbound'
          protocol: 'TCP'
          sourceAddressPrefix:'*'
          sourcePortRange:'*'
          destinationAddressPrefix:'*'
          destinationPortRange:'6516'
          priority: 100
        }
      }
    ]
  }
  tags: tags
}

output id string = networkSecurityGroup.id
