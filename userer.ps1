$user, $verb, $groups = $args

function usage {
  Write-Output 'usage: userer USER [add|del GROUP ...]'
  Write-Output ''
  Write-Output 'userer USER: search for users named USER, print group membership if exact match found'
  Write-Output 'userer USER add GROUP ...: add USER to GROUP (or list of groups)'
  Write-Output 'userer USER del GROUP ...: delete USER from GROUP (or list of groups)'
  Write-Output ''
  exit
}

function announce($label, $data){
  if($data){ echo "${label}: $data" }
}

if (!$user) {
  usage
}

$user_obj = $false
try {
  $user_obj = Get-AdUser -Identity $user -Properties *
}
catch {
  # no luck
}

if ($user_obj) {
  if ($verb) {
    # add or remove member if we have a command to do so
    if ( ! $groups ) {
      usage
    }
    foreach ($group in $groups) {
      switch -regex ( $verb ) {
        '^add$' {
          Add-ADGroupMember $group $user_obj
        }
        '^(del(ete)?|rem(ove)?)$' {
          Remove-ADGroupMember $group $user_obj -Confirm:$false
        }
        default {
          usage
        }
      }
    }
  } else {
    # only print info about user when we aren't making changes, as Get-ADPrincipalGroupMembership
    # output won't be consistant until several seconds after running Add-ADGroupMember
    $groups = Get-ADPrincipalGroupMembership $user | Sort-Object SamAccountName | Select-Object SamAccountName
    $groups = $groups.SamAccountName

    announce "accountname    " $user_obj.SamAccountName
    announce "name           " $user_obj.Name
    announce "description    " $user_obj.Description
    announce "displayname    " $user_obj.DisplayName
    announce "cannonicalname " $user_obj.CanonicalName
    Write-Output "Groups: "
    foreach($group in $groups){
      Write-Output "  $group"
    }
  }
} else {
  # no exact match, print what groups we could find
  $users = (Get-ADUser -Filter "SamAccountName -like '$user*'" | Select-Object SamAccountName).SamAccountName
  if($users){
    Write-Output "No match for '$user', listing prefix matches:"
    foreach($uname in (Get-ADUser -Filter "SamAccountName -like '$user*'" | Select-Object SamAccountName).SamAccountName){
      Write-Output "  $uname"
    }
  }
  else{
    Write-Output "No match for '$user'"
  }
}
