targetScope = 'subscription'
param location string = 'eastus'
param tags object = {
  Ambiente:'Azure Virtual Desktop'
}
param vnPrefix string ='10.0.0.0/23'
param snetPrefix string ='10.0.0.0/24'
param RemoteVnetName string = 'vnet-tech-hub'
// param RemoteRgName string = 'rg-tech-srv'
//param subID string = '6e14122b-c3a3-4468-b9d6-2d6883f0b369'

resource rghub 'Microsoft.Resources/resourceGroups@2020-06-01' existing = {
  name: 'rg-tech-srv'
}

resource rg_tech_avd 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: 'rg-tech-avd'
  location: location
  tags: {
    Ambiente: 'Azure Virtual Desktop'
  }
  properties: {
  }
}
module nsg 'modules/networkSecurityGroup.bicep'={
  scope: rg_tech_avd
  name: 'nsg-deploy'
  params: {
    location: location
    name: 'tech-avd'
    tags: tags
  }
}
module network 'modules/virtualNetwork.bicep'={
  scope: rg_tech_avd
  name: 'virtualnetwork-deploy'
  params: {
    location: location
    name: 'tech-avd'
    networkSecurityGroupId: nsg.outputs.id
    snetAddressPrefix: snetPrefix
    tags: tags
    vnetAddressPrefix: vnPrefix
  }
  dependsOn:[
    nsg
  ]
}

module peerlocal 'modules/peering-local.bicep'={
  scope: rg_tech_avd
  name: 'peer-deploy-local'
  params: {
    existingRemoteVirtualNetworkResourceGroupName: rghub.name
    peer01: network.outputs.name
    peer02: RemoteVnetName
  }
  dependsOn:[
    network
  ]
}

module peerRemote 'modules/peering-remote.bicep'={
  scope: rghub
  name: 'peer-deploy-remote'
  params: {
    existingRemoteVirtualNetworkResourceGroupName: rg_tech_avd.name
    peer01: network.outputs.name
    peer02: RemoteVnetName
  }
  dependsOn:[
    network
  ]
}
