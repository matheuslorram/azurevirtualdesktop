@description('Set the local VNet name')
param peer01 string

@description('Set the remote VNet name')
param peer02 string

@description('Sets the remote VNet Resource group')
param existingRemoteVirtualNetworkResourceGroupName string

resource existingLocalVirtualNetworkName_peering_to_remote_vnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${peer02}/peering-to-avd-vnet'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId(existingRemoteVirtualNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', peer01)
    }
  }
}



