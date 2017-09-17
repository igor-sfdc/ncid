#! /bin/sh

# archive the NCID monthly logs into a yearly log on the 1st of each month
# runs from a user cronatb

# uses logrotate to rotate log files
# user crontab entry:
# 11 3 1 * * test -f bin/ncid-yearlog && bin/ncid-yearlog

# Created by John L Chmielewski

VERSION="(NCID) XxXxX"

YEAR=`date '+%Y'`
MONTH=`date '+%m'`
DAY=`date '+%d'`
CIDCALL=cidcall
CIDDATA=ciddata
LOGDIR=/var/log
LOGSUFFIX=.log-$YEAR$MONTH$DAY
ZIP=.gz
ARCDIR=$HOME/NCID/log
ARCSUFFIX=.log

usage() {
   cat <<EOF

Usage: $prog [options]
       
Options:
       [-h] [-V]

       -h = show this help

       -V = display version
            
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



# create the archive directory if it does not exist
[ -d $ARCDIR ] || \
{
    mkdir -p $ARCDIR
    echo "Created the archive directory: $ARCDIR"
}

# must be run on the 1st day of the month
[ $DAY = 01 ] || \
{
    echo "Must be run one time, on the first day of the month"
    exit -1
}

# The archive on January 1 is for December of the prior year
[ $MONTH = 01 ] && YEAR=`expr $YEAR - 1`

# Look to add cidcall.log archive file created today
if [ -f $LOGDIR/$CIDCALL$LOGSUFFIX ]
then
    cat $LOGDIR/$CIDCALL$LOGSUFFIX >> $ARCDIR/$CIDCALL-$YEAR$ARCSUFFIX
elif [ -f $LOGDIR/$CIDCALL$LOGSUFFIX$ZIP ]
then
    zcat $LOGDIR/$CIDCALL$LOGSUFFIX$ZIP >> $ARCDIR/$CIDCALL-$YEAR$ARCSUFFIX
fi

# Look to add ciddata.log archive file created today
if [ -f $LOGDIR/$CIDDATA$LOGSUFFIX ]
then
    cat $LOGDIR/$CIDDATA$LOGSUFFIX >> $ARCDIR/$CIDDATA-$YEAR$ARCSUFFIX
elif [ -f $LOGDIR/$CIDDATA$LOGSUFFIX$ZIP ]
then
    zcat $LOGDIR/$CIDDATA$LOGSUFFIX$ZIP >> $ARCDIR/$CIDDATA-$YEAR$ARCSUFFIX
fi
