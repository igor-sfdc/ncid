#! /bin/bash

#script to run configuration scripts

VERSION="(NCID) XxXxX"

SetupDir=/usr/local/share/ncid/setup

usage() {
cat <<EOF

Usage: $prog [-h] [-V] [name [option] [option] [...]]

Options: -h = show this help
         -V = display version

Arguments: none        - List available setup scripts and support files
           name        - The name part of the script name: ncid-<name>-setup
           name option - If option is needed by ncid-<name>-setup

EOF

exit 1
}

prog=`basename $0 .sh`

# Options on command line
while getopts :hV opt ; do
    case $opt in
        h) usage;;
        V) echo "$prog $VERSION"; exit 0;;
        :) echo "Option -$OPTARG requires an argument."; usage;;
        *) echo "Invalid option: -$OPTARG"; usage;;
    esac
done
shift $((OPTIND-1)) # skip over command line args (if any)

[ -d $SetupDir ] || \
{
    echo "$SetupDir: No setup scripts are available."
    exit 0;
}

[ "$#" -ge 1 ] || \
{
    ret="`ls $SetupDir | wc -l`"
    if [ $ret = 0 ]
    then echo "$SetupDir: No setup scripts are available."    
    else ls $SetupDir
    fi
    exit 0
}

name=$1; shift

script=$SetupDir/ncid-$name-setup

[ -f $script ] || \
{
    echo "Setup script not found: $script"
    exit 1
}

export main_prog=$prog

cd $SetupDir # in case setup directory contains helper files for $script
$script $*
