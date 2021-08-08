

param workspaceName string
param appInsightsName string
param location string
param tagValues object 
param keyVaultId string

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'Free'
    }
  }
  tags: tagValues
}
resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspace.id
  }
  tags: tagValues
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: last(split(keyVaultId, '/'))
  resource appInsightsSecret 'secrets' = {
    name: '${appInsightsName}-ConnectionString'
    properties: {
    value:  appInsights.properties.ConnectionString
   }
  }
}
