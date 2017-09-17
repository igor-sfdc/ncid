#!/bin/bash

# ncid-mysql
# usage: ncid --no-gui --program ncid-mysql

# Last Modified: Jul 14, 2016

# Created by Randy Tarantino <tarantir@users.sf.net> on Fri Feb 13, 2015

# Copyright (c) 2015-2016 by
#   Randy Tarantino <tarantir@users.sf.net>
#   John L. Chmielewski <jlc@users.sourceforge.net>
#   Todd Andrews <tandrews@users.sourceforge.net>

# sends an NCID notification to a MySQL database

#
# input is always 8 lines
#
# if input is from a call:
# input: DATE\nTIME\nNUMBER\nNAME\nLINE\nTYPE\n""\n""\n
#
# if input is from a message
# input: DATE\nTIME\nNUMBER\nNAME\nLINE\nTYPE\nMESG\nMTYPE\n

ConfigDir=/usr/local/etc/ncid/conf.d
ConfigFile=$ConfigDir/ncid-mysql.conf

# defaults for all settings in $ConfigFile
db_types="BLK CID HUP MSG NOT OUT PID WID"
db_host="localhost"
db_host_allowed="%"
db_port="3306"
db_name="ncid"
db_table="ncid"
db_user="ncid"
db_pass="ncid"
db_date_field_order="M D Y"
db_grant="ALL"
#no default: db_create_options=
 
read DATE
read TIME
read NMBR
read NAME
read LINE
read TYPE
read MESG
read MTYPE

# Look for $TYPE
for i in $db_types
do
    [ $i = "$TYPE" ] && { found=1; break; }
done

# Exit if $TYPE not found
[ -z "$found" ] && exit 0

[ -f $ConfigFile ] && . $ConfigFile

# bash trick to parse date into individual variables
# $Y, $M, $D
IFS=" :-/" read $db_date_field_order <<<"$DATE"
DATE="${Y}-${M}-${D}"

# replace double quote with apostrophe
NAME=`echo "${NAME}" |tr \" \'`
MESG=`echo "${MESG}" |tr \" \'`

if [ -n "$NMBR" ];then
    echo "INSERT INTO $db_table (CID,CIDDATE,CIDTIME,CIDNMBR,CIDNAME,CIDLINE,CIDTYPE,CIDMESG,CIDMTYPE) VALUES (0,'$DATE','$TIME','$NMBR',\"$NAME\",'$LINE','$TYPE',\"$MESG\",'$MTYPE');" | mysql -h $db_host -P $db_port -u $db_user -p$db_pass $db_name 
fi

exit 0
