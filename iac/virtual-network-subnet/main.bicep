// == PARAMETERS ==

@description('Application Prefix')
@maxLength(3)
param paramApplicationPrefix string

@description('Resource Location')
param paramLocation string

@description('Environment')
@maxLength(3)
param paramEnvironment string

@description('Address Spaces')
param paramAddressSpaces array

// == VARIABLES ==

var virtualNetworkName = 'corp-${paramEnvironment}-vnet-${paramLocation}'
var virtualNetworkSubnetName = '${paramApplicationPrefix}-${paramEnvironment}-snet-${paramLocation}'

// == MODULES ==

// virtual network subnet
module virtualNetworkSubnetModule './virtual-network-subnet.bicep' = {
  name: 'virtualNetworkSubnetModule-${virtualNetworkSubnetName}'
  params: {
    paramVirtualNetworkName: virtualNetworkName
    paramVirtualNetworkSubnetName: virtualNetworkSubnetName
    paramAddressSpaces: paramAddressSpaces
  }
}
