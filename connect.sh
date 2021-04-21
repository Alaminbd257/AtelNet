#!/bin/bash

HOST='89.39.104.48'
USER='routervp_routervp'
PASS='KuD%2fsq4I+l'
DB='routervp_routervp'

connection_status="Online"
username="$common_name"
mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "UPDATE vgax_users SET connection_status='$connection_status', connection_start='yes' WHERE username='$username'"
