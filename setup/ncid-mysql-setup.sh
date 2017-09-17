#!/bin/bash

# ncid-mysql-setup

# Last Modified: Sep 5, 2016

# Creates necessary MySQL or MariaDB database, table and user for module
# ncid-mysql. If the database and/or user already exist, they will be removed.

# Requires:
# Network access to a MySQL or MariaDB database server.
# A MySQL or MariaDB user name with administrative privileges (usually 'root').
# The MySQL or MariaDB command line client 'mysql'.

usage() {
   cat <<EOF

Usage: $prog <authentication>

       where <authentication> is passed directly to the 'mysql' command
       line utility. It must specify a user and password (if needed)
       that has administrative privileges. This is usually a MySQL or
       MariaDB user called 'root'. This is not the same as the 'root'
       login for this machine.

       Typically you would type: $prog -u root
                             or: $prog -u root -p<password>
                             or: $prog -u root --password=<password>

       If a password is required for the administrative login, you must
       specify it on the command line.

EOF
       
   exit 1
}

doSql() {
   printf "%-76s" "$action"
   ignoreError=0
   if [ "$1" = "ignoreError" ]
      then
      ignoreError=1
      shift
   fi
   stdout=`echo $sql | mysql -h $db_host -P $db_port $* 2>&1`
   rc=$?
   error=`echo $stdout|cut -f1 -d' '`
   if [ $ignoreError -eq 0 ]
      then
      if [ $rc -ne 0 -o "$error" = "ERROR" ]
         then
         echo -e "FAIL\n"
         echo "Return code: $rc"
         echo "SQL: $sql"
         echo "Output: $stdout"
         exit 1
      else
         echo "OK"
      fi
   else
      echo "OK"
   fi
}

###############################
# End of function definitions #
###############################

ConfigDir=/etc/ncid/conf.d
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

[ -f $ConfigFile ] && . $ConfigFile

#main_prog has been exported by ncid-setup and is available for use
prog=`basename $0`

if [ $# -eq 0 ]
   then
      usage
   else
      for x in $*
          do
            # The restriction of having the password on the command line is to prevent 'mysql' from
            # prompting for it every time doSql() is executed.
            if [ $x = "-p" ]
               then
                  echo "You must specify the password immediately after '-p' with no space(s)."
                  echo "E.G., -p1234"
                  exit 1
            elif [ $x = "--password" ]
                then
                  echo "An equal sign and the password must immediately follow '--password' with no space(s)."
                  echo "E.G., --password=1234"
                  exit 1
            fi
      done
fi

echo

action="Removing existing database '$db_name' on '$db_host' if it already exists..."
sql="DROP DATABASE IF EXISTS \`$db_name\` ;"
doSql $*

action="Creating database '$db_name' on '$db_host'..."
sql="CREATE DATABASE \`$db_name\` ;"
doSql $*

action="Creating table '$db_table'..."
sql="CREATE TABLE \`$db_table\` ( \
  \`CID\` int(11) NOT NULL AUTO_INCREMENT, \
  \`CIDDATE\` date DEFAULT NULL, \
  \`CIDTIME\` time DEFAULT NULL, \
  \`CIDNMBR\` varchar(25) DEFAULT NULL, \
  \`CIDNAME\` varchar(55) DEFAULT NULL, \
  \`CIDLINE\` varchar(25) DEFAULT NULL, \
  \`CIDTYPE\` varchar(10) DEFAULT NULL, \
  \`CIDMESG\` varchar(300) DEFAULT NULL, \
  \`CIDMTYPE\` varchar(7) DEFAULT NULL, \
  PRIMARY KEY (\`CID\`) \
  ) $db_create_options ;"
doSql $* $db_name

action="Removing old user '$db_user' if it exists..."
sql="DROP USER '$db_user'@'$db_host_allowed' ;"
doSql ignoreError $*

if [ -z "$db_pass" ]
   then
   action="Creating user '$db_user' with NO PASSWORD..."
   sql="CREATE USER '$db_user'@'$db_host_allowed' ;"
else
   action="Creating user '$db_user' with password '$db_pass'..."
   sql="CREATE USER '$db_user'@'$db_host_allowed' IDENTIFIED BY '$db_pass' ;"
fi
doSql $*

action="Granting user '$db_user' privileges '$db_grant' for database '$db_name'..."
sql="GRANT $db_grant ON \`$db_name\`.* TO '$db_user'@'$db_host_allowed' ;"
doSql $*

action="Reloading privileges from the grant tables..."
sql="FLUSH PRIVILEGES;"
doSql $*

action="Testing to make sure user '$db_user' can, at a minimum, add new rows..."
sql="INSERT INTO \`$db_table\` (CID,CIDNAME) VALUES (0,'SETUP TEST');"
doSql -u $db_user -p$db_pass $db_name 

action="Removing test record..."
# TRUNCATE TABLE resets auto_increment as well as
# removing all records in the file
sql="TRUNCATE TABLE \`$db_table\` ;"
doSql $* $db_name

echo
echo "Setup completed successfully."

exit 0
