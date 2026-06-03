var varLocation = 'northcentralus'
var varEnvironment = 'npr'
var varApplicationPrefix = 'pwy'

module virtualNetworkModule './virtual-network-subnet/main.bicep' = {
  name: 'virtualNetworkModule-${varLocation}-${varEnvironment}'
  params: {
    paramApplicationPrefix: varApplicationPrefix
    paramLocation: varLocation
    paramEnvironment: varEnvironment
    paramAddressSpaces: [
      '10.1.0.0/24'
    ]
  }
}
