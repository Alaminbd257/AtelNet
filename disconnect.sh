#!/bin/bash
#!/bin/bash

#
#####################
### Configuration ###
#####################

### API Alias
Filename_alias='myvpn';

# MySQL Remote Server side
DatabaseHost='209.159.147.190';
DatabaseName='routervp_routervp';
DatabaseUser='routervp_routervp';
DatabasePass='KuD%2fsq4I+l';
DatabasePort='3306';


connection_status="offline"
username="$common_name"
$mysqli = new MySQLi($DB_host,$DB_user,$DB_pass,$DB_name -sN -e "UPDATE vgax_users SET connection_status='$connection_status' WHERE username='$username'"
