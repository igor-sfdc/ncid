#!/bin/bash

# Last edited: Jul 20, 2016

# Server hangup extension to play messages for specific callers.
# Provides a separate recorded message for each caller listed.

# Script is not called if caller number or name is in ncidd.whitelist.

# This hangup script is REPLACED whenever NCID is updated.
# Make a copy of this script by removing "-skel" from the name.
# The name of your modified script will then be hangup-message.
# Be sure your new script has the execute permission set.
# Make sure you 'set hupmode = 3' in ncidd.conf.

# Add or remove callers and messages using the two arrays.
# The caller and message array elements should be on the same line.
# The index for caller and message must be the same and start at 1.
caller[1]="3215551212"  message[1]="CallingDeposit.rmd"
caller[2]="4075551212"  message[2]="CannotBeCompleted.rmd"

########################
# Function Definitions #
########################

usage() {
   cat |more <<EOF

Usage: $script [options] <string>

       Server hangup extension to play messages for specific callers.
       Provides a separate recorded message for each caller listed.
       
       Input: The server passes one <string> to this script:

       *DATE*<mmddyyyy>*TIME*<hhmm>*LINE*<lineid>*NMBR*<number>*NAME*<name>*

              <number> and <name> have already been changed to aliases 
              if applicable.

              There is NO guarantee that the order of the field pairs will
              remain the same in future NCID versions (e.g., *LINE*<lineid>* 
              might be moved to the end of the string). Your code must 
              take this into account. This example script handles this
              properly.
              
              When testing, just use the input fields needed. This 
              example script only requires the NMBR field. The <string> 
              must be enclosed in double quotes.

              For example:
                  $script "*NMBR*4075551212*"
                                                      
       Output: (if call will be hung up) Recording:<file name or full path>
               hangup | OK
       
Options are only used for manual testing and are NEVER SENT by the server:

       [-h] [-v] 

       -h = show this help
       
       -v = turns verbose on and sends additional data to STDOUT for 
            troubleshooting
            
EOF
exit 1
}

###############################
# End of function definitions #
###############################

script=`basename $0`

# Options on command line
while getopts :hv opt ; do
    case $opt in
        h) usage;;
        v) verbose=1;;
        :) echo "Option -$OPTARG requires an argument."; usage;;
        *) echo "Invalid option: -$OPTARG"; usage;;
    esac
done
shift $((OPTIND-1)) # skip over command line args (if any)

# All passed fields from the server are parsed below, use only fields needed.
tmp=${1#*NAME?}; NAME=${tmp%%\**}
tmp=${1#*NMBR?}; NMBR=${tmp%%\**}
tmp=${1#*LINE?}; LINE=${tmp%%\**}
tmp=${1#*DATE?}; DATE=${tmp%%\**}
tmp=${1#*TIME?}; TIME=${tmp%%\**}

: ${NMBR:=_nmbr_} # default value if null
: ${NAME:=_name_} # default value if null

if [ -n "$verbose" ]
then
    echo "NAME:  $NAME"
    echo "NMBR:  $NMBR"
    echo "LINE:  $LINE"
    echo "DATE:  $DATE"
    echo "TIME:  $TIME"
    for ((i=1; i<= ${#caller[@]}; i++))
        do echo "$i: ${caller[$i]} ${message[$i]}"
    done
fi

for ((i=1; i<= ${#caller[@]}; i++))
do
    if [ "${NMBR}" = "${caller[$i]}" ]
    then
        pos=$i
        break
    fi
done

if [ "${NMBR}" = "${caller[$pos]}" ]
then
    echo "Recording: ${message[$pos]}"
    echo "hangup"
else
    echo "OK"
fi
