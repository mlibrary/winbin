$group, $verb, $members = $args

$found = $true
try {
  $null = Get-ADGroup $group
}
catch {
  $found = $false
}

if ($found) {
  # add or remove member if we have a command to do so
  foreach ($member in $members) {
    $user = (Get-ADUser $member)

    switch -regex ( $verb ) {
      '^add$' {
        Add-ADGroupMember $group $user
      }
      '^(del(ete)?|rem(ove)?)$' {
        Remove-ADGroupMember $group $user -Confirm:$false
      }
    }
  }

  # list final membership
  Get-ADGroupMember $group | Sort-Object SamAccountName | Select-Object SamAccountName
} else {
  # no exact match, print what groups we could find
  Get-ADGroup -Filter "SamAccountName -like '$group*'" | Select-Object SamAccountName
}
