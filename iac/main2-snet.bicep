var varLocation = 'westus3'
var varEnvironment = 'npr'
var varApplicationPrefix = 'pwy'

module virtualNetworkSubnetModule './virtual-network-subnet/main.bicep' = {
  name: 'virtualNetworkSubnetModule-${varLocation}-${varEnvironment}'
  params: {
    paramApplicationPrefix: varApplicationPrefix
    paramLocation: varLocation
    paramEnvironment: varEnvironment
    paramAddressSpaces: [
      '10.1.0.0/24'
    ]
  }
}
