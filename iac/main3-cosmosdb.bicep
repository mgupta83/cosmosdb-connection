var varLocation = 'westus3'
var varEnvironment = 'npr'
var varApplicationPrefix = 'pwy'

module cosmosdbMongoDbModule './cosmos-account-mongodb/main.bicep' = {
  name: 'cosmosdbMongoDbModule-${varLocation}-${varEnvironment}'
  params: {
    paramApplicationPrefix: varApplicationPrefix
    paramLocation: varLocation
    paramEnvironment: varEnvironment
  }
}
