$group, $verb, $members = $args

if (!$group) {
  Write-Output 'usage: grouper GROUP [add|del USER ...]'
  Write-Output ''
  Write-Output 'grouper GROUP: search for groups named GROUP, print members if exact match found'
  Write-Output 'grouper GROUP add USER ...: add USER (or list of users) to GROUP, print final membership'
  Write-Output 'grouper GROUP del USER ...: delete USER (or list of users) from GROUP, print final membership'
  Write-Output ''
  exit
}

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
