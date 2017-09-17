<!-- Log.md - Removable HEADER Start -->

Last edited: Sep 5, 2016

<!-- Removable HEADER End -->

## <a name="log_top"></a> Log Files

> [Table of Contents](#doc_top)

> [Requirement](#log_req)

> [Description](#log_des)

> [Yearly Logs](#log_year)

### <a name="log_req"></a> Requirement

> - **logrotate**  
  
>  NCID uses **logrotate** to prune its log files each month.  When it prunes the
   log, it saves a backup.  Up to five backups are saved.

>  Another system log rotation program can be used but it must be configured 
   to zero (empty) the log each month in order to use the **ncid-yearlog**
   program.
    

### <a name="log_des"></a> Description

> Here is an alphabetical list of NCID log files stored in /var/log:
>>
Log file name |Log type|Description
--------------|--------|:----------
cidcall.log   | server |Calls and messages
ciddata.log   | server |Raw data received by ncidd server as captured from modems and gateways*
lcdncid.log   | client |LCDproc client activity
ncid2ncid.log | gateway|NCID-to-NCID gateway activity
ncidd.log     | server |Server activity
obi2ncid.log  | gateway|OBihai gateway activity
rn2ncid.log   | gateway|Remote Notifier gateway activity
sip2ncid.log  | gateway|SIP gateway activity
wc2ncid.log   | gateway|Whozz Calling gateway activity


> *Note: If /var/log/ciddata.log exists, ncidd will write to it. It must be manually created prior to launching ncidd:

>            sudo touch /var/log/ciddata.log

> Each month **logrotate** uses /etc/logrotate.d/ncid to prune files as required in
  /etc/ncid/ncidrotate.conf.  Only two variables are expected to change: *RotateOff* &nbsp;and *Lines2keep*.
  
> If the user does not want a log rotated, set *RotateOff=1*.  This will let the log keep growing until the operating system decides it is too large.

> The default for *Lines2keep* is 0.  Some users like to keep some lines in the log when
  it is pruned.  If you would like to keep the last 10 lines at the start of the month, set
  *Lines2keep=10*

> If you turned rotation off or do not prune a log to zero each month, you should backup
  the log to someplace that is not /var.

### <a name="log_year"></a> Yearly Logs

> NCID can keep yearly logs automatically in $HOME/ncid/log/ by running
  /usr/share/ncid/sys/ncid-yearlog on the first of every month from the user's crontab.

> If **ncidrotate.conf** has *RotateOff=0* and *Lines2keep=0*, you can enable **ncid-yearlog**
  by creating or editing a crontab and adding this line
  (NOTE: /usr/share can be /usr/local/share on some operating systems):

>            11 5 1 * * /usr/share/ncid/sys/ncid-yearlog
