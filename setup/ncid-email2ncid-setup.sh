#!/bin/bash

# ncid-email2ncid-setup

# Setup script for the .procmailrc file needed for the email2ncid gateway.

# Last Modified: Sep 30, 2016

procmailrc() {
   cat <<EOF
# .procmailrc file recipes for email2ncid

MAILDIR=$HOME/Mail      # make sure it exists

# The following recipe checks the subject line and if there's a match
# a copy of the entire email is sent to email2ncid. email2ncid 
# then extracts the complete body of the email and sends it as a one
# line message to the NCID server.
:0c
* ^Subject: +NCID Message
| email2ncid

# The following recipe checks the "From:" email address and if there's 
# a match a copy of the entire email is sent to email2ncid. email2ncid 
# then extracts only the subject line and sends it as a message to the
# NCID server.
#
# change who@from.com to the correct email address leave: * ^From.*
# :0c
# * ^From.*who@from.com
# | email2ncid --notify
#
# The following recipe requires outgoing email.  If you can send email
# and your email address is not this one, then uncomment the recipe
# to forward the email to yourself.
#
# change who@from.com and nobody@nowhere.com to the correct email addresses
# leave: * ^From.*
# :0c
# * ^From.*who@from.com
# ! nobody@nowhere.com
EOF
}

#main_prog has been exported by ncid-setup and is available for use
prog=`basename $0 .sh`

ID=`id -u`
if [ $ID = 0 ]
then
    echo "$main_prog: must execute as a normal user and not as 'root'"
    exit 0
fi

FILE=$HOME/.procmailrc

[ -d $HOME/Mail ] || mkdir $HOME/Mail

if [ -f $FILE ]
then
    if grep "| email2ncid" $FILE > /dev/null 2>&1
    then
        echo "$FILE already configured for email2ncid"
    else
        procmailrc | grep -v ".procmailrc file" >> $FILE
        echo "Appended the email2ncid .procmailrc file to $FILE"
    fi
else
    procmailrc > $FILE
    echo "Created $FILE"
fi

echo "See the email2ncid gateway section in the NCID User Manual"
echo "for the complete requirements."

exit 0
