**Prerequisites:**

- An Azure account with an active subscription.
- Permissions to manage applications, specifically to update permissions.
- Required Microsoft Entra roles: Application Administrator, Application Developer, Cloud Application Administrator.
- Understanding of managed identities for Azure resources.
- A user-assigned managed identity assigned to the Azure compute resource hosting your workload.
- An app registration in Microsoft Entra ID belonging to the same tenant as the managed identity.

![image](https://github.com/user-attachments/assets/48cb2241-30cc-45e0-bfe2-1987e85379ce)

1. Azure Resource Requests Token from Managed Identity Endpoint: The Azure resource initiates a request to the managed identity endpoint to obtain a token.
2. Managed Identity Endpoint Issues Token: The managed identity endpoint issues a token to the Azure resource.
3. Azure Resource Uses Token to Access Microsoft Entra Protected Resources: The Azure resource uses the issued token to access Microsoft Entra protected resources.
4. Microsoft Entra ID Validates Token and Issues Access Token: Microsoft Entra ID validates the token and issues an access token.
5. Azure Resource Uses Access Token to Access Resources: The Azure resource uses the access token to access the required resources.
6. Access Granted or Denied Based on Authorization Rules: Access is granted or denied based on the authorization rules defined in Microsoft Entra ID.

***Important Considerations and Restrictions:***

The account performing the action must have the Application Administrator, Application Developer, Cloud Application Administrator, or Application Owner role.
The microsoft.directory/applications/credentials/update permission is required to update a federated identity credential.
A maximum of 20 federated identity credentials can be added to an application or user-assigned managed identity.
Key pieces of information needed to set up the trust relationship: issuer and subject.
The combination of issuer and subject must be unique on the app.
When the Azure workload requests Microsoft identity platform to exchange the Managed Identity token for an access token, the issuer and subject values of the federated identity credential are checked against the issuer and subject claims provided in the Managed Identity token. If the validation check passes, Microsoft identity platform issues an access token to the external software workload

References:

- [Workload identity federation with managed identity](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-config-app-trust-managed-identity?toc=%2Fentra%2Fidentity%2Fmanaged-identities-azure-resources%2Ftoc.json&tabs=microsoft-entra-admin-center)
- [API invocation with managed identity](https://github.com/AzureAD/microsoft-identity-web/wiki/calling-apis-with-managed-identity)
- [Invoking entra protected apis with managed identity](https://blog.marcelmichau.dev/microsoft-entra-id-call-protected-apis-using-managed-identities)
- [Authentication with managed identity](https://laurakokkarinen.com/authenticate-to-entra-id-protected-apis-with-managed-identity-no-key-vault-required/)
