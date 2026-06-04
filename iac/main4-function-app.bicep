var varLocation = 'westus3'
var varEnvironment = 'npr'
var varApplicationPrefix = 'pwy'

module functionAppModule './function-app/main.bicep' = {
  name: 'functionAppModule-${varApplicationPrefix}-${varLocation}-${varEnvironment}'
  params: {
    paramApplicationPrefix: varApplicationPrefix
    paramLocation: varLocation
    paramEnvironment: varEnvironment
  }
}
