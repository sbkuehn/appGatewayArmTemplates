# The name of the Azure subscription to install the Key Vault into
$subscriptionName = 'Shannon Microsoft Azure Internal Consumption'

# The resource group that will contain the Key Vault to create to contain the Key Vault
$resourceGroupName = 'appGateway1'

# The name of the Key Vault to install
$keyVaultName = '{nameOfKeyVault}'

# The Azure data center to install the Key Vault to
$location = 'eastus'

# These are the Azure AD users that will have admin permissions to the Key Vault
$keyVaultAdminUser = {placeUpnHere}

# Login to Azure
Login-AzAccount

# Select the appropriate subscription
Select-AzSubscription -SubscriptionName $subscriptionName

# Make the Key Vault provider is available (commented out - if not registered, uncomment the line below):
# Register-AzureRmResourceProvider -ProviderNamespace Microsoft.KeyVault

# Create the Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create the Key Vault (enabling it for Disk Encryption, Deployment and Template Deployment)
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location $location `
    -EnabledForDiskEncryption -EnabledForDeployment -EnabledForTemplateDeployment

# Add the Administrator policies to the Key Vault
$ObjectId = (Get-AzADUser -UserPrincipalName $keyVaultAdminUser).Id

Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -ObjectId $ObjectId `
-PermissionsToKeys decrypt,encrypt,unwrapKey,wrapKey,verify,sign,get,list,update,create,import,delete,backup,restore,recover,purge `
–PermissionsToSecrets get,list,set,delete,backup,restore,recover,purge `
–PermissionsToCertificates get,list,delete,create,import,update,managecontacts,getissuers,listissuers,setissuers,deleteissuers,manageissuers,recover,purge,backup,restore `
-PermissionsToStorage get,list,delete,set,update,regeneratekey,getsas,listsas,deletesas,setsas,recover,backup,restore,purge 

# Adding secret to Key Vault
Set-AzKeyVaultSecret -VaultName $LabKVName -Name "VMPassword" -SecretValue (Get-Credential).Password
