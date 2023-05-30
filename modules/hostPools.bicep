param name string
param tags object
param location string
param aadJoin bool
@allowed([
  'Personal'
  'Pooled'
])
param hostPoolType string
param maxSessionLimit int
param baseTime string = utcNow('u')

var expirationTime = dateTimeAdd(baseTime, 'PT48H')

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-03-09-preview' = {
  name: 'vdpool-${name}'
  location: location
  tags: tags
  properties: {
    hostPoolType: hostPoolType
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
    maxSessionLimit: maxSessionLimit
    startVMOnConnect: true
    validationEnvironment: false
    customRdpProperty: 'drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:1;${(aadJoin ? 'targetisaadjoined:i:1' : '')}'
    registrationInfo: {
      expirationTime: expirationTime
      token: null
      registrationTokenOperation: 'Update'
    }
  }
} 
output id string = hostPool.id
output Name string = hostPool.name
