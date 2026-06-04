// == PARAMETERS ==

@description('Application Prefix')
@maxLength(3)
param paramApplicationPrefix string

@description('Resource Location')
param paramLocation string

@description('Environment')
@maxLength(3)
param paramEnvironment string

// == VARIABLES ==

var functionAppName = 'cosmosdb-connection-westus3'
var virtualNetworkName = 'corp-${paramEnvironment}-vnet-${paramLocation}'
var virtualNetworkSubnetName = '${paramApplicationPrefix}-${paramEnvironment}-snet-${paramLocation}'

// == RESOURCES ==                 

// function app vnet integration
module functionAppVnetIntegrationModule './function-app-vnet-integration.bicep' = {
  name: 'functionAppVnetIntegrationModule-${functionAppName}'
  params: {
    paramFunctionAppName: functionAppName
    paramLocation: paramLocation
    paramVirtualNetworkName: virtualNetworkName
    paramVirtualNetworkSubnetName: virtualNetworkSubnetName
  }
}
