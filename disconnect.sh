#!/bin/bash

### MySQL Remote Server side
DatabaseHost='209.159.147.190';
DatabaseName='routervp_routervp';
DatabaseUser='routervp_routervp';
DatabasePass='KuD%2fsq4I+l';
DatabasePort='3306';
#####################
#####################

connection_status="offline"
username="$common_name"
mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "UPDATE vgax_users SET connection_status='$connection_status' WHERE username='$username'"
