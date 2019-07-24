# winbin
Windows utility scripts

## grouper and userer
Search AD from groups and users. Add and remove users from AD groups.

### find user jdoe
* Lists all users w/ prefix: `userer jd`
* Lists group membership for user w/ exact match: `userer jdoe`

### add jdoe to some groups
* `userer jdoe add group1 group2 group3`
* And confirm it worked: `userer jdoe`

### find group "mygroup"
* Lists all groups w/ prefix: `grouper myg`
* Lists group membership for exact match: `grouper mygroup`

### add several users to mygroup
* `grouper mygroup add user1 user2 user3`

### remove users from group
* `grouper mygroup del user1 user2 user3`
* `userer myuser del group1 group2 group3`
