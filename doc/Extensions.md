<!-- Extensions.md - Removable HEADER Start -->

<style>
th {
   white-space: nowrap;
}

table, th, td {
   padding: 6px 13px;
   border: 1px solid #DDD;
   border-collapse: collapse;
   border-spacing: 0px;
}
</style>

Last edited: Jul 23, 2016

<!-- Removable HEADER End -->

## <a name="ext_top"></a> Server Extensions

> [Table of Contents](#doc_top)

> [Description](#ext_des)  
> [Hangup Extension](#ext_hup)

### <a name="ext_des"></a> Description

> The ncidd server supports **Server Extensions**.  A Server Extension is an external script or
  program that is called by ncidd to perform a function and return a result. Server Extensions 
  are a way for users to add functionality to NCID without requiring changes to NCID itself.
  Server Extensions are isolated from the main NCID distribution, and because of this they
  do not normally require any changes when NCID is upgraded to a later version.

> You can use any scripting or programming language desired.  
  
### <a name="ext_hup"></a> Hangup Extension

> The first Server Extension distributed with NCID is the **Hangup Extension**. 

> A Hangup Extension can be used with and without using [Internal Hangup](hangup_top).
> (Internal Hangup is defined as call termination using the `ncidd.blacklist` and 
> `ncidd.whitelist` files.)

> It works like this:
> 
>> When Caller ID is received from a modem and it is not terminated
>> by the Internal Hangup logic and is not in 'ncidd.whitelist', the 
>> server will check to see if a Hangup Extension has been enabled.  If so, 
>> the server will pass the current call info to the Hangup Extension, execute it, and
>> wait for a response. If the Hangup Extension results in a
>> positive match by returning the word **hangup**, call
>> termination will take place automatically.

> Hangup Extensions use all of the same Internal Hangup modes (normal, fax, announce).
> Be sure to review the required [Modem Configuration](#hangup_modem_config) parameters.

> Three settings in ncidd.conf control Hangup Extensions:

>>>
 Setting         | Values 
 --------------  | :-----
set&nbsp;hupmode | <br> 0 = disabled <br> 1 = [Normal Hangup](#hangup_norm)   <br> 2 = [Fax Hangup](#hangup_fax) <br> 3 = [Announce Hangup](#hangup_ann) <br><br> default: 0 <br>&nbsp;
set&nbsp;hupname | <br> the name of the hangup script or program  <br><br> default: hangup-skel <br>&nbsp;
set&nbsp;huprmd  | <br> optional voice file to be played if hupmode = 3 <br><br> default: "announce" file used by Internal Hangup (usually **NumberDisconnected.rmd**) <br>&nbsp;

> When you enable a Hangup Extension, you also need to indicate the hangup script to use.  The
  default is **hangup-skel** which will run, but it will never trigger a hangup.  When testing
  your script you can give the full path name to where it is located.  When it's working OK,
  copy it to the path appropriate for your operating system:

>> **/usr/share/ncid/extensions** 

>> or 

>>  **/usr/local/share/ncid/extensions**

> Once the file is there you give the name of the script in ncidd.conf:

>> **set hupname = hangup-custom**

> You create your own Hangup Extension script/program external to NCID in whatever language 
> you would like. It can have whatever logic you wish for terminating a call. You can even
> have it return the name of a customized voice message file for
> individual phone numbers. It is not necessary for your Hangup Extension to check
> `ncidd.whitelist` because the NCID server already does this for you and will have
> automatically applied any Simple Expressions or Regular Expressions to the incoming call.

>  The technical details of creating a Hangup Extension are outside the
   scope of this document (see [NCID-API](http://ncid.sourceforge.net/doc/NCID-API.html)).
   
>  However, one ready-to-use Hangup Extension and three template Hangup Extensions are included with NCID. 
   Template Hangup Extensions have a file name ending in '-skel' (short for 
   "skeleton"). These will always be replaced when NCID is updated. Before customizing
   a template, it is essential that you copy or rename the template script so 
   that it does not end in '-skel'.

>  Below is a summary of the Hangup Extensions included with NCID:

> - The [hangup-calls](http://ncid.sourceforge.net/man/hangup-calls.1.html) extension hangs up
    on every call not in the whitelist.

> - The [hangup-skel](http://ncid.sourceforge.net/man/hangup-skel.1.html) extension is a very basic
    template to determine if the number or name received should tell ncidd to hangup. You might use
    this as a starting point, for example, to query an Internet site to determine if the
    call should be terminated. Or perhaps you have a local relational database with names or
    numbers of blacklisted callers.

> - The [hangup-message-skel](http://ncid.sourceforge.net/man/hangup-message-skel.1.html) script is a
    template that contains a sample list of phone numbers with their
    corresponding name of a recorded message (voice) file that is played before terminating the call.
    There are no provisions to record a message from the caller; NCID is not an answering machine.

> - The [hangup-closed-skel](http://ncid.sourceforge.net/man/hangup-closed-skel.1.html) script is
    a template for playing a recorded "we are closed" message prior to hanging up
    on calls within a specific time period. You need to customize the start and end times and record
    a message. It is recommended that your recorded message include the name of your business so
    callers can be sure they dialed the correct number.

  
