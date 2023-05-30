param location string = resourceGroup().location
param appgroupname string


resource stofslogics 'Microsoft.Storage/storageAccounts@2022-05-01'={
  name: 'sto${appgroupname}'
  location: location
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'FileStorage'
  properties:{
    accessTier:'Premium'
    allowBlobPublicAccess:true
    allowCrossTenantReplication:false
    allowedCopyScope:'PrivateLink'
    allowSharedKeyAccess:true
    largeFileSharesState:'Enabled'
  }
}

resource fileshare 'Microsoft.Storage/storageAccounts/fileServices@2022-05-01'={
  parent: stofslogics
  name: 'default'
  properties:{
  }
}

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-05-01'={
  parent: fileshare
  name: 'fslogics'
  properties:{
     accessTier:'Premium'
     enabledProtocols:'SMB'
     shareQuota: 30
  }
}

