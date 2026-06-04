@minLength(3)
@maxLength(44)
@description('name of the MongoDB account')
param mongoDatabaseAccountName string

@description('location of the MongoDB')
param location string

@description('totalThroughputLimit of the MongoDB')
param totalThroughputLimit int

@description('backupIntervalInMinutes of the MongoDB')
param backupIntervalInMinutes int

@description('backupRetentionIntervalInHours of the MongoDB')
param backupRetentionIntervalInHours int

@description('Tags')
param tags object

@description('Virtual Network name')
@maxLength(80)
param paramVirtualNetworkName string

@description('Virtual Network Subnet name')
@maxLength(80)
param paramVirtualNetworkSubnetName string

// == RESOURCES ==

// virtual network - existing
resource virtualNetworkResource 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: paramVirtualNetworkName
}

// virtual network subnet - existing
resource virtualNetworkSubnetResource 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  parent: virtualNetworkResource
  name: paramVirtualNetworkSubnetName
}

resource mongoDatabaseAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: mongoDatabaseAccountName
  location: location
  tags: tags
  kind: 'MongoDB'
  identity: {
    type: 'None'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: true
    enableClientTelemetry: false
    virtualNetworkRules: [
      {
        id: virtualNetworkSubnetResource.id
        ignoreMissingVNetServiceEndpoint: false
      }
    ]
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: false
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
      schemaType: 'FullFidelity'
    }
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'None'
    disableLocalAuth: false
    enablePartitionMerge: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    configurationOverrides: {
      EnableBsonSchema: 'True'
    }
    apiProperties: {
      serverVersion: '4.2'
    }
    locations: [
      {
        locationName: location
        // provisioningState: 'Succeeded'
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    cors: []
    capabilities: [
      {
        name: 'EnableMongo'
      }
      {
        name: 'DisableRateLimitingResponses'
      }
    ]
    ipRules: []
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: backupIntervalInMinutes
        backupRetentionIntervalInHours: backupRetentionIntervalInHours
        backupStorageRedundancy: 'Geo'
      }
    }
    networkAclBypassResourceIds: []
    capacity: {
      totalThroughputLimit: totalThroughputLimit
    }
    // keysMetadata: {
    // }
  }
}

output mongoDatabaseAccountName string = mongoDatabaseAccount.name
