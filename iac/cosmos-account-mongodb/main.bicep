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

var virtualNetworkName = 'corp-${paramEnvironment}-vnet-${paramLocation}'
var virtualNetworkSubnetName = '${paramApplicationPrefix}-${paramEnvironment}-snet-${paramLocation}'

// == RESOURCES ==                 

// cosmos mongodb account
module cosmosAccountMongoDbModule './mongo-database-account.bicep' = {
  name: 'cosmosAccountMongoDbModule-${paramApplicationPrefix}-${paramEnvironment}-cosmos-mongodb-001'
  params: {
    location: paramLocation
    mongoDatabaseAccountName: '${paramApplicationPrefix}-${paramEnvironment}-cosmos-mongodb-001'
    totalThroughputLimit: 1000
    backupIntervalInMinutes: 240
    backupRetentionIntervalInHours: 96
    tags: {
      environment: paramEnvironment
      application: paramApplicationPrefix
    }
    paramVirtualNetworkName: virtualNetworkName
    paramVirtualNetworkSubnetName: virtualNetworkSubnetName
  }
}
