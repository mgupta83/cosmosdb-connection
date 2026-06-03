var varLocation =  'northcentralus'
var varEnvironment = 'npr'

module virtualNetworkModule './virtual-network/main.bicep' = {
  name: 'virtualNetworkModule-${varLocation}-${varEnvironment}'
  params: {
    paramLocation: varLocation
    paramEnvironment: varEnvironment
    paramAddressSpaces: [
        '10.1.0.0/16'
      ]
  }
}
