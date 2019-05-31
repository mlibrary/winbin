$user, $verb, $groups = $args

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
    Get-ADPrincipalGroupMembership $user | Sort-Object SamAccountName | Select-Object SamAccountName
  }
} else {
  # no exact match, print what groups we could find
  Get-ADUser -Filter "SamAccountName -like '$user*'" | Select-Object SamAccountName
}
