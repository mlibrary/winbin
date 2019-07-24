$user, $verb, $groups = $args

if (!$user) {
  Write-Output 'usage: userer USER [add|del GROUP ...]'
  Write-Output ''
  Write-Output 'userer USER: search for groups named GROUP, print members if exact match found'
  Write-Output 'userer USER add GROUP ...: add USER to GROUP (or list of groups)'
  Write-Output 'userer USER del GROUP ...: delete USER from GROUP (or list of groups)'
  Write-Output ''
  exit
}

$user_obj = $false
try {
  $user_obj = Get-ADUser $user
}
catch {
  # no luck
}

if ($user_obj) {
  if ($verb) {
    # add or remove member if we have a command to do so
    foreach ($group in $groups) {
      switch -regex ( $verb ) {
        '^add$' {
          Add-ADGroupMember $group $user_obj
        }
        '^(del(ete)?|rem(ove)?)$' {
          Remove-ADGroupMember $group $user_obj -Confirm:$false
        }
      }
    }
  } else {
    # only print membership when we aren't making changes, as Get-ADPrincipalGroupMembership
    # output won't be consistant until several seconds after running Add-ADGroupMember
    Get-ADPrincipalGroupMembership $user | Sort-Object SamAccountName | Select-Object SamAccountName
  }
} else {
  # no exact match, print what groups we could find
  Get-ADUser -Filter "SamAccountName -like '$user*'" | Select-Object SamAccountName
}
