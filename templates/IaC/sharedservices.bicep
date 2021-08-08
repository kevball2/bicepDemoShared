targetScope = 'subscription'

// Global Parameters
@description('Location for the resourceGroup')
param location string
@description('Current Environment being deployed too')
param env string
@description('Returns the current date for Tag updates')
param currentDate string = utcNow('yyyy-MM-dd')

// Resource Group Parameters
@description('resource group for deployment')
param resourceGroupName string

// Kevault Parameters 
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

// Variables
var tagValues = {
  createdBy: 'IaC-ResourceGroups'
  environment: env
  deploymentDate: currentDate
}

var keyvaultName = 'kv-${resourceGroupName}-${env}-${location}'

var workspaceName = 'log-${resourceGroupName}-${env}-${location}'
var applicationInsightsName = 'appi-${resourceGroupName}-${env}-${location}'


/*
module resourceGroupModule 'modules/resourcegroup.bicep' = {
  name: 'rg-${resourceGroupName}-${env}-${location}-deployment'
  params:{
    name: 'rg-${resourceGroupName}-${env}-${location}'
    location: location
    tagValues:tagValues
    env: env
  }
  
}
*/
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-${resourceGroupName}-${env}-${location}'
  location: location
  tags: tagValues
  
}

module applyLock 'modules/applylock.bicep' = if(env == 'prod') {
  scope: resourceGroup
  name: 'applyLock-${resourceGroup.name}'
  params: {
  }
}

module keyvaultModule 'modules/keyvault.bicep' = {
  scope: resourceGroup
  name: '${keyvaultName}-deployment'
  params: {
    keyvaultName: keyvaultName
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    location: location
    networkAcls: networkAcls
    sku: sku
    softDeleteRetentionInDays: softDeleteRetentionInDays
    tagValues: tagValues
    tenant: tenant
    userAssignment: userAssignment
    keyVaultSecrets: keyVaultSecrets
  }
  
}

module appInsightsModule 'modules/appinsights.bicep' = {
  scope: resourceGroup
  name: 'appi-${resourceGroupName}-${env}-${location}-deployment'
  params: {
    workspaceName: workspaceName
    appInsightsName: applicationInsightsName
    location: location
    tagValues: tagValues
    keyVaultId: keyvaultModule.outputs.kvId
  }
  
  
  
}
