// == PARAMETERS ==

@description('Resource Location')
param paramLocation string

@description('Virtual Network name')
@maxLength(80)
param paramVirtualNetworkName string

@description('Address Spaces')
param paramAddressSpaces array

// == RESOURCES ==

// virtual network
resource virtualNetworkResource 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: paramVirtualNetworkName
  location: paramLocation
  properties: {
    addressSpace: {
      addressPrefixes: paramAddressSpaces
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    privateEndpointVNetPolicies: 'Disabled'
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}
