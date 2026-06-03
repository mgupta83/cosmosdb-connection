// == PARAMETERS ==

@description('Resource Location')
param paramLocation string

@description('Environment')
@maxLength(3)
param paramEnvironment string

@description('Address Spaces')
param paramAddressSpaces array


// == VARIABLES ==

var virtualNetworkName = 'corp-${paramEnvironment}-vnet-${paramLocation}'


// == MODULES ==

// virtual network
module virtualNetworkModule './virtual-network.bicep' = {
  name: 'virtualNetworkModule-${virtualNetworkName}'
  params: {
    paramLocation: paramLocation
    paramVirtualNetworkName: virtualNetworkName
    paramAddressSpaces: paramAddressSpaces
  }
}
                       