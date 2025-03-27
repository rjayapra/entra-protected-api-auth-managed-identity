# Note :The user executing the script needs to have either Application administrator, Cloud application administrator or Global administrator role.

# Replace with your tenant ID
$tenantId = "<yenant id>"
# Replace with your managed identity object ID
$managedIdentityId = "<managed identity>"

# The app ID of the API where you want to assign the permissions
$appId = "<app id>"

# The app IDs of the Microsoft APIs are the same in all tenants:
# Microsoft Graph: 00000003-0000-0000-c000-000000000000
# SharePoint Online: 00000003-0000-0ff1-ce00-000000000000

# For a custom API, specify its Entra ID app ID

# Replace with the API permissions required by your app
$permissions = "Group.Read.All", "GroupMember.ReadWrite.All", "Team.ReadBasic.All", "User.Read.All"

# Prompt to install the required module if not yet installed
if ($null -eq (Get-Module -ListAvailable -name Microsoft.Graph.Applications)) {
    $response = Read-Host -Prompt "Running this script requires the Microsoft.Graph.Applications module which is not yet installed. Install now? (Y/N)"
    if ($response -eq "Y") {
        Install-Module -Name Microsoft.Graph.Applications -Scope CurrentUser -Force -AllowClobber
    }
    else {
        Write-Host "The script cannot continue without the Microsoft.Graph.Applications module. Exiting."
        exit
    }
}

# Interactive login via browser
Connect-MgGraph -TenantId $tenantId -Scopes @("AppRoleAssignment.ReadWrite.All", "Application.Read.All") -NoWelcome

$app = Get-MgServicePrincipal -Filter "AppId eq '$appId'"

foreach ($permission in $permissions)
{
    try {
        $appRole = $app.AppRoles | Where-Object Value -eq $permission | Select-Object -First 1
        $roleAssignment = @{
            PrincipalId = $managedIdentityId # To whom
            ResourceId  = $app.Id # For which API
            AppRoleId   = $appRole.Id # What permission
        }
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $managedIdentityId -BodyParameter $roleAssignment -ErrorAction Stop | Out-Null
        Write-Host -ForegroundColor Green "Successfully added the following permission: $permission"
    }
    catch {      
        if ($_.Exception.Message -like "*Permission being assigned already exists on the object*") {
            Write-Host -Foreground Yellow "The app already has the following permission: $permission"
        }
        else {
            throw $_
        }
    }
}

Read-Host "Press Enter to exit"
