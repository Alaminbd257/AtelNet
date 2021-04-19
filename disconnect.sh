#!/bin/bash

HOST='89.39.104.48'
USER='openvpn_sk'
PASS='ASDe3434etdgDE'
DB='kerfuffle'

connection_status="offline"
username="$common_name"
mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "UPDATE vgax_users SET connection_status='$connection_status' WHERE username='$username'"
