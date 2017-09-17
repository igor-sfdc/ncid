<!-- Tools.md - Removable HEADER Start -->

Last edited: Sep 29, 2016

<!-- Removable HEADER End -->

## <a name="tools_top"></a> Command Line Tools

> [Table of Contents](#doc_top)

### Tools Index

> [Overview](#tools_ov)  
  [cidalias](#tools_alias)  
  [cidcall](#tools_call)  
  [cidupdate](#tools_update)  
  [ncidutil](#tools_util)  
  [ncid-yearlog](#tools_yl)

### <a name="tools_ov"></a>Overview

> NCID has a few command line Perl scripts (also called tools) that can 
  list or modify the ncidd.alias, ncidd.blacklist, ncidd.whitelist, and
  cidcall.log files.  These scripts are in all distributions except the 
  TiVo distribution.  The TiVo does not support Perl.

> If you edit and modify ncidd.alias, ncidd.blacklist, or ncidd.whitelist
  with an editor:

> - (optional) Run cidupdate after modifying ncidd.alias to update the 
    cidcall.log file with the new aliases

> - Reload ncidd.alias, ncidd.blacklist, and ncidd.whitelist:

>>> sudo pkill --signal SIGHUP ncidd

> There are four tools: cidalias, cidcall, cidupdate, and ncidutil.

#### <a name="tools_alias"></a>cidalias

> The **cidalias** tool displays aliases in the alias file in one of 
  three different formats: raw, human readable, and delimited.
  
> See the [cidalias.1](http://ncid.sourceforge.net/man/cidalias.1.html) 
  man page for a complete description and all options.

#### <a name="tools_call"></a>cidcall

> The **cidcall** tool is used to view the cidcall.log file in one of 
  two different formats: raw and human readable.  The default is to 
  display BLK, CID, HUP, OUT, PID, and WID lines in a human readable 
  format. Messages and Smartphone Notes will be viewed when their option
  is selected.
  
> See the [cidcall.1](http://ncid.sourceforge.net/man/cidcall.1.html)
  man page for a complete description and all options.

> EXAMPLES:

>> To view all call types, but not message types: cidcall

>> To view messages and notes: cidcall --MSG --NOT

#### <a name="tools_update"></a>cidupdate

> The **cidupdate** tool is used to update the cidcall.log file with 
  newly created aliases. It is also used by the server whenever clients
  want the call logfile update.

> Command Line Usage:

> - Add one of more aliases to ncidd.alias

> - Run **cidupdate** to update cidcall.log for any calls that require 
    the new alias or aliases.

> - Reload ncidd.alias, ncidd.blacklist, and ncidd.whitelist:

>>> sudo pkill --signal SIGHUP ncidd
  
> See the [cidupdate.1](http://ncid.sourceforge.net/man/cidupdate.1.html) 
  man page for a complete description and all options.

#### <a name="tools_util"></a>ncidutil

> The **ncidutil** is only used by the server to add, modify, or remove
  entries from ncid.alias. It is also used by the server to add or 
  remove entries from ncidd.blacklist and ncidd.whitelist.
  
> See the [ncidutil.1](http://ncid.sourceforge.net/man/ncidutil.1.html) 
  man page for a complete description and all options.

#### <a name="tools_yl"></a>ncid-yearlog

> The **ncid-yearlog** tool automatically creates a yearly call log from the monthly call logs.  It is
  called from the user's crontab on the first of the month.
  Review [Yearly Logs](http://ncid.sourceforge.net/doc/NCID-UserManual.html#log_year) and
  [ncid-yearlog.1](http://ncid.sourceforge.net/man/ncid-yearlog.1.html)