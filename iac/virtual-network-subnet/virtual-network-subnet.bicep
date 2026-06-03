// == PARAMETERS ==

@description('Virtual Network name')
@maxLength(80)
param paramVirtualNetworkName string

@description('Virtual Network Subnet name')
@maxLength(80)
param paramVirtualNetworkSubnetName string

@description('Address Spaces')
param paramAddressSpaces array

// == RESOURCES ==

// virtual network - existing
resource virtualNetworkResource 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: paramVirtualNetworkName
}

// virtual network subnet 
resource virtualNetworkSubnetResource 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  parent: virtualNetworkResource
  name: paramVirtualNetworkSubnetName
  properties: {
    addressPrefixes: paramAddressSpaces
    serviceEndpoints: [
      {
        service: 'Microsoft.AzureCosmosDB'
        locations: [
          '*'
        ]
      }
    ]
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworkResource
  ]
}
