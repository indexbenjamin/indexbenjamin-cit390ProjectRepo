import os
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.mgmt.web import WebSiteManagementClient

# Replace these with your info
KEYVAULT_NAME = " cit390vault2"
RESOURCE_GROUP = "cit390"
APP_SERVICE_NAME = "signupapp"
SUBSCRIPTION_ID = "3c00eb82-5b11-4edf-87a6-7d524c4879c8" #your tenant ID

# Build the vault URL
KV_URI = f"https://{KEYVAULT_NAME}.vault.azure.net/"

# Authenticate with default Azure credential
credential = DefaultAzureCredential()

# Create a Key Vault client
secret_client = SecretClient(vault_url=KV_URI, credential=credential)

# Create the Web Apps management client
web_client = WebSiteManagementClient(credential, SUBSCRIPTION_ID)

# Get the current app settings
app_settings = web_client.web_apps.list_application_settings(RESOURCE_GROUP, APP_SERVICE_NAME)
current_settings = app_settings.properties or {}

# List secrets in the Key Vault
secret_properties = secret_client.list_properties_of_secrets()

for secret_prop in secret_properties:
    original_name = secret_prop.name
    # Convert from dash to underscore and uppercase
    env_var_name = original_name.replace("-", "_").upper()

    # Get the secret value
    secret = secret_client.get_secret(original_name)
    secret_value = secret.value

    print(f"Setting {env_var_name} for secret {original_name}")

    # Update the app settings dictionary
    current_settings[env_var_name] = secret_value

# Update the App Service with new settings
web_client.web_apps.update_application_settings(RESOURCE_GROUP, APP_SERVICE_NAME, {"properties": current_settings})

print("All secrets synced to App Service environment variables.")
