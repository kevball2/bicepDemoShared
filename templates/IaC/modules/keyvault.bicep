@description('Key Vault name')
param keyvaultName string
@description('Resource Group required for deployment of the Key Vault')
param location string
@description('Key Vault Sku level')
param sku string
@description('Tenant Id is required for deployment of the Key Vault')
param tenant string
@description('Enable Key Vault to be used during VM deployment')
param enabledForDeployment bool
@description('Configure Key Vault to be used during ARM Template deployment')
param enabledForTemplateDeployment bool
@description('Configure Key Vault to be used for Disk Encryption tasks ')
param enabledForDiskEncryption bool
@description('Configure Key Vault to use RBAC permissions structure')
param enableRbacAuthorization bool
@description('Configure Key Vault to use the soft delete feature')
param enableSoftDelete bool
@description('Configure Soft Delete feature retention')
param softDeleteRetentionInDays int
@description('Configure Key Vault purge protection')
param enablePurgeProtection bool
@description('Configure Network ACLS for Key Vault if required')
param networkAcls object
@description('list of users and groups to assign to the keyvault')
param userAssignment array
@description('list of secrets to assign to the keyvault')
param keyVaultSecrets array
@description('Tags to be applied to resources')
param tagValues object

/*
RoleDefinition Id's for use in the parameter file, Other ID's can be used as well. 
NOTE: Custome Roles will have non-standard ID's that will be different per subscription. 
KeyVault Secrets Officer: b86a8fe4-44ce-4948-aee5-eccb2c155cd7
KeyVault Secrets User: 4633458b-17de-408a-b874-0445c86b69e6
KeyVault Reader: 21090545-7ca7-4776-b22c-e363652d74d2
*/


resource keyvault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyvaultName
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enableRbacAuthorization: enableRbacAuthorization
    tenantId: tenant
    sku: {
      name: sku
      family: 'A'
    }
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    networkAcls: networkAcls
  }
  resource keyVaultSecret 'secrets' = [for secret in keyVaultSecrets:  {
    name: '${secret.name}'
    properties: {
      value: secret.value
      contentType: 'text/plain'
    }
  }]
  tags: tagValues
}

output kvId string = keyvault.id

/* Old way
resource kvSecrets 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = [for secret in keyVaultSecrets:  {
  name: '${keyvault.name}/${secret.name}'
  properties: {
    value: secret.value
    contentType: 'text/plain'

  }
  
}]

*/
resource roleassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for user in userAssignment: {
  name: guid(user.roleDefinitionId, resourceGroup().id)
  properties: {
    principalType: user.principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', user.roleDefinitionId)
    principalId: user.groupObjId
  }
}]
