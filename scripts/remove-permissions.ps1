# Replace with your tenant ID
$tenantId = "<tenant id>"
# Replace with your managed identity object ID
$managedIdentityId = "<managed identity id>"

# The app ID of the API which permissions you want to manage
$appId = "<app id>"

# The app IDs of the Microsoft APIs are the same in all tenants
# Microsoft Graph: 00000003-0000-0000-c000-000000000000
# SharePoint Online: 00000003-0000-0ff1-ce00-000000000000

# For a custom API, specify its Entra ID app ID

# Replace with the API permissions you want to remove
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

foreach ($permission in $permissions) {
    $appRole = $app.AppRoles | Where-Object Value -eq $permission | Select-Object -First 1
    if ($null -eq $appRole) {
        Write-Host -ForegroundColor Red "Permission $permission does not exist on app $appId"
        continue
    }
    $roleAssignment = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $managedIdentityId | Where-Object AppRoleId -eq $appRole.Id | Select-Object -First 1
    if ($null -eq $roleAssignment) {
        Write-Host -ForegroundColor Yellow "Role assignment $permission does not exist. Nothing to remove."
        continue
    }
    Remove-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $managedIdentityId -AppRoleAssignmentId $roleAssignment.Id
    Write-Host -ForegroundColor Green "Successfully removed the following permission: $permission"
}

Read-Host "Press Enter to exit"
