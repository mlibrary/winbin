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

function announce($label, $data){
  if($data){ echo "${label}: $data" }
}

$group_obj = $false
try {
  $group_obj = Get-ADGroup $group -Properties *
}
catch {
  # no luck
}

if ($group_obj) {
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
  $members = (Get-ADGroupMember $group | Sort-Object SamAccountName | Select-Object SamAccountName).SamAccountName
  announce "accountname    " $group_obj.SamAccountName
  announce "name           " $group_obj.Name
  announce "description    " $group_obj.Description
  announce "displayname    " $group_obj.DisplayName
  announce "cannonicalname " $group_obj.CanonicalName
  Write-Output "Members of ${group}:" 
  foreach($member in $members){
    Write-Output "  $member"
  }
}
else {
  # no exact match, print what groups we could find
  $groups = (Get-ADGroup -Filter "SamAccountName -like '$group*'" | Select-Object SamAccountName).SamAccountName
  Write-Output "No match for '$group', listing prefix matches:"
  foreach($matching_group in $groups){
    Write-Output "  $matching_group"
  }
}
