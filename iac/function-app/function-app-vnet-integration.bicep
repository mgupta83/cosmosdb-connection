// @description('Resource group containing the Function App')
// param functionAppResourceGroup string

@description('Function App name')
param paramFunctionAppName string

// @description('VNet resource group')
// param vnetResourceGroup string

@description('Resource Location')
param paramLocation string

@description('Virtual Network name')
@maxLength(80)
param paramVirtualNetworkName string

@description('Virtual Network Subnet name')
@maxLength(80)
param paramVirtualNetworkSubnetName string

resource functionAppResource 'Microsoft.Web/sites@2023-12-01' existing = {
  // scope: resourceGroup(functionAppResourceGroup)
  name: paramFunctionAppName
}

resource virtualNetworkResource 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  // scope: resourceGroup(vnetResourceGroup)
  name: paramVirtualNetworkName
}

resource virtualNetworkSubnetResource 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  parent: virtualNetworkResource
  name: paramVirtualNetworkSubnetName
}

resource functionAppVnetIntegration 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppResource.name
  location: paramLocation

  properties: {
    virtualNetworkSubnetId: virtualNetworkSubnetResource.id
  }
}
