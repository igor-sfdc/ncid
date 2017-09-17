#!/bin/bash

# Last edited: Jul 20, 2016

# server hangup extension skeleton

# Script is not called if caller number or name is in ncidd.whitelist.
  
# This hangup script is REPLACED whenever NCID is updated.
# Make a copy of this script by replacing "skel" with your name.
# Name your new script in the form: hangup-<name>
# Be sure your new script has the execute permission set.
# Make sure you 'set hupmode' to be non-zero in ncidd.conf.
#
# To cause ncidd to hangup on this call, you must send "hangup"
# (without quotes) to STDOUT.  
#
# If you do not want to hangup this call, send "OK" to STDOUT.
# The ncidd.log, at verbose level 2 or above, will show either
# "OK" or "hangup" each time your script is executed.
#
# You may also send a recording file name to play before the hangup.
# The general way to do this is as follows:
#    - make sure you 'set hupmode = 3' in ncidd.conf,
#    - specify a voice file by sending this to STDOUT: Recording:<name>
#      (it must be sent to STDOUT before the "hangup" line)
# PLAYREC and RECORDING are provided as a convenience below and
# will ensure "Recording:" and "hangup" are sent to STDOUT in the
# required order.

# Change to whatever recording you want to be played when
# this script indicates hangup.  Normally not needed because it will
# default to the 'set announce' value in ncidd.conf.
RECORDING="CannotBeCompleted.rmd"

# Set PLAYREC to play the above RECORDING for this
# extension instead of the recording set in ncidd.conf
PLAYREC=""   # Do not return a recording file name, use 'set announce' instead
#PLAYREC=1   # Return a recording file name

# Choose to hangup on either either NMBR or NAME.  Default is NMBR.
CHECK='$NMBR'    # hangup on a number
#CHECK='$NAME'   # hangup on a name

check_target() {
    # Code goes here to set TARGET instead of using value 0000000000
    # if $TARGET = $CHECK, "hangup" is returned
    TARGET="0000000000"
}

########################
# Function Definitions #
########################

usage() {
   cat |more <<EOF

Usage: $script [options] <string>

       Skeleton code/example to demonstrate a server hangup extension.
       
       Input: The server passes one <string> to this script:

       *DATE*<mmddyyyy>*TIME*<hhmm>*LINE*<lineid>*NMBR*<number>*NAME*<name>*

              <number> and <name> have already been changed to aliases 
              if applicable. To test this example script, alias a number
              to be "0000000000".

              There is NO guarantee that the order of the field pairs will
              remain the same in future NCID versions (e.g., *LINE*<lineid>* 
              might be moved to the end of the string). Your code must 
              take this into account. This example script handles this
              properly.
              
              When testing, just use the input fields needed. This 
              example script only requires the NMBR field; it can be
              modified to use the NAME field. The <string> must be
              enclosed in double quotes.

              For example:
                  $script "*NAME*SCAMMER*"
                                                      
       Output: (optional) Recording:<file name or full path>
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

eval "CHECK=$CHECK"

check_target

if [ -n "$verbose" ]
then
    echo "NAME:      $NAME"
    echo "NMBR:      $NMBR"
    echo "LINE:      $LINE"
    echo "DATE:      $DATE"
    echo "TIME:      $TIME"
    echo "CHECK:     $CHECK"
    echo "TARGET:    $TARGET"
    [ -n "$PLAYREC" ] echo "Recording: $RECORDING"
fi

if [ "${CHECK}" = "${TARGET}" ]
then
    if [ -n "$PLAYREC" ]; then echo "Recording: $RECORDING"; fi
    echo "hangup"
else
    echo "OK"
fi
