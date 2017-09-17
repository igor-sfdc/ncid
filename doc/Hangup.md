<!-- Hangup.md - Removable HEADER Start -->

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

Last edited: Jul 29, 2016

<!-- Removable HEADER End -->

## <a name="hangup_top"></a>Hangup

> [Table of Contents](#doc_top)

<!--
[### Hangup Index]
-->

### Hangup Index

> [Hangup Overview](#hangup_ov)  
> [Modem Configuration](#hangup_modem_config)  
> [Hangup Choices](#hangup_choices)

>>  [Normal Hangup](#hangup_norm)  
>>  [Fax Hangup](#hangup_fax)  
>>  [Announce Hangup](#hangup_ann)  

> [Blacklist and Alias Files Usage](#overview_blacklist)  
  [Whitelist File Usage](#overview_whitelist)  
  [Blacklist and Whitelist Expressions](#overview_expr)  

> [Hangup Appendix A: Server Log File Sample](#hangup_log)  
  [Hangup Appendix B: Creating a Voice File from Scratch](#hangup_scratch)  
  [Hangup Appendix C: Raw Modem Data Formats](#hangup_raw)  
  [Hangup Appendix D: Modem AT+VSM Command Explained](#hangup_vsm)  


<!--
[### Hangup Overview]
-->  

### <a name="hangup_ov"></a>Hangup Overview

> Hangup (a.k.a. call termination) is disabled/enabled by settings in 
  the server configuration file **ncidd.conf**. It requires a modem
  to be connected to the phone line so it can pickup and hangup the line.

> At a high-level, there are two sets of procedures available to hangup calls. 
  Both are optional, and one or both can be enabled at the same time. They are:

> * Internal Hangup. This is built in to the NCID server and uses the
    **ncidd.blacklist** and **ncidd.whitelist** files.

> * [Hangup Extension](#ext_hup). This lets you use an external script or program.  The
    **ncidd.whitelist** file is used to determine if the hangup script is called.

> When Caller ID is received from a modem, the following steps take
  place and in this order:
 
> - The server looks for matching data in the optional <u>alias</u> 
    file. This can result in the Caller ID name and/or number being
    changed.
 
> - The server looks for matching data in the optional 
    <u>whitelist</u> file. The data must be an alias, or if 
    there is no alias for the call, it must be from the Caller ID. 
    If there is a match then no hangup takes place.

> - The server looks for matching data in the <u>blacklist</u> file. 
    The data must be an alias, or if there is no alias for the 
    call, it must be from the Caller ID. If there is a match,
    hangup is automatic.

> You can manually edit the blacklist and whitelist files to create, 
  edit, or remove entries using an editor.

> When either file is modified, **ncidd** needs to be informed.  It
  will reload the blacklist and whitelist tables when it receives a
  SIGHUP signal.

>> One way to send the reload signal to **ncidd**:

>>>     sudo pkill --signal SIGHUP ncidd

>> You can also just restart **ncidd**.

> Blacklist and whitelist entries can also be created or removed by the
> following NCID clients. They provide ways to force the server to reload 
> the tables:

> - [ncid](#clients_ncid)  
> - [NCIDpop](#clients_pop)  
> - <strike>NCID Android</strike> <font color="dimgray">Blacklist/whitelist
    maintenance not available but the blacklist can be queried</font>

> In addition, when running the NCID server in the US or Canada, the 
  **ignore1** option can be set in **ncidd.conf** to ignore a leading 1
  in the Caller ID, alias, blacklist, or whitelist.

<!--
[### Modem Configuration]
-->
  
### <a name="hangup_modem_config"></a>Modem Configuration  

>  A modem is required to hangup the line.  Hangup is enabled and
>  configured in **ncidd.conf** by the **hangup** variable.
  
> Hangup is disabled by default, with and without a configuration file. 
  Hangup can also be disabled by the line:
  
>> **set hangup = 0**
  
> You may also need to set the **ttyport** variable if the correct one
> is not set in **ncidd.conf**.  For example, using Linux:

>> **set ttyport = /dev/ttyACM0**

> The location of **ncidd.conf** will vary depending on the operating
  system. It is typically found in either **/etc/ncid/** or 
  **/usr/local/etc/ncid/**. The **ncidd.conf** file location is also 
  shown in **/var/log/ncidd.log** when **ncidd** starts.  If 
  **ncidd.conf** is missing, **ncidd.log** will have an appropriate 
  message.

> Announce Hangup has some [additional requirements](#hangup_ann_conf)
  for modem configuration.  

<!--
[### Hangup Choices]
-->
  
### <a name="hangup_choices"></a>Hangup Choices

>> If enabled, there are three types of hangups:

>> - **Normal Hangup** - requires a modem that supports Caller ID  
>> - **FAX Hangup** - requires a modem that supports Caller ID and FAX  
>> - **Announce Hangup** - requires a modem that supports Caller ID, VOICE, and
     hardware flow control

>> If the type of hangup is not supported by the modem, **ncidd** will 
   change the hangup to **Normal Hangup**.

<!--
[#### Normal Hangup]
-->    
    
> #### <a name="hangup_norm"></a> Normal Hangup

> A normal hangup is configured in **ncidd.conf** by the line:

>> **set hangup = 1**  

> When **ncidd** receives a blacklisted Caller ID, it will immediately
  hangup.

<!--
[#### FAX Hangup]
-->

> #### <a name="hangup_fax"></a> FAX Hangup

> A FAX hangup will generate a FAX tone for 10 seconds and then hangup.
  It is configured in **ncidd.conf** by the line:

>> **set hangup = 2**

> Not all FAX modems are supported.  If no FAX tones are generated,
  set **pickup** to 0 in **ncidd.conf**.  It is usually needed for 
  older modems.

>> **set pickup = 0**

> After changing the pickup value, if it still does not work then the 
  modem is not supported for **FAX Hangup** by **ncidd**.

<!--
[#### Announce Hangup]
-->  
  
> #### <a name="hangup_ann"></a>Announce Hangup

> Announce Hangup will play a recorded message and then hangup.

>>  [Configuration](#hangup_ann_conf)    
>>  [Voice Files](#ann_voice)

>>>   [CX93001 Chipset Voice Files](#ann_cx)  
      [US Robotics USR5637 Voice Files](#ann_usr)  
      [Creating a Voice File from Scratch](#hangup_ann_rmd)  

<!--
[##### Configuration]
-->    
    
>> ##### <a name="hangup_ann_conf"></a>Configuration

>>> ##### Modem

>>> Make sure the modem supports hardware flow control and that it is 
    enabled. Look for the line **Modem ACTIVE PROFILE:** in 
    **ncidd.log**. For most modems, hardware flow control is indicated 
    by the presence of &K3 in the profile. You may need to set &K3 in 
    the active profile. If &K (or whatever is appropriate for your 
    modem) is not returned, then the modem is not supported by NCID.

>>> ##### ncidd.conf

>>>> Announce Hangup is configured by the line:

>>>>> **set hangup = 3**

>>>> In addition, two other variables, **announce** and **audiofmt**, 
    are used to configure the announcement file. For example:
    
>>>>> **set announce = NumberDisconnected.rmd**  
>>>>> **set audiofmt = "AT+VSM=130"**

>>>> If the announcement file is missing, **ncidd** will change
    **Announce Hangup** to **Normal Hangup**.  This will be indicated in
    **ncidd.log**.

>>>> The default voice file is for 8-bit unsigned PCM at an 8000 Hz 
    sample rate. It also seems to work for 8-bit LINEAR at an 8000 Hz 
    sample rate.

>>>> The **audiofmt** variable determines the voice file's compression
    method and sampling rate. The shorthand for this is 
    **Voice Sampling Method** or VSM.

>> ##### <a name="ann_voice"></a> Voice Files

>>> ##### <a name="ann_cx"></a> CX93001 Chipset Voice Files

>>>> The default voice file supplied, **NumberDisconnected.rmd**,  works
    for modems that use the **CX93001** chipset. See 
    the [Incomplete list of working modems](https://en.wikipedia.org/wiki/Network_Caller_ID)
    for known modems that use this chipset.

>>>> Variable **audiofmt** defaults to **AT+VSM=130** to work with this
    chipset.

>>> ##### <a name="ann_usr"></a> US Robotics USR5637 Voice Files

>>>> The default voice file will also work with the US Robotics USR5637
    modem, but it must have firmware 1.2.23 or newer, and **audiofmt** 
    must be changed. 
    
>>>> To check the firmware level, examine **ncidd.log** for this line:

>>>>> **Modem Identifier: U.S. Robotics 56K FAX USB V1.2.23**

>>>>  If you need to upgrade the firmware, download it from 
     the [US Robotics USR5637 support page](http://support.usr.com/support/product-template.asp?prod=5637).
    
>>>> The VSM line used is
    
>>>>> **128,"8-BIT LINEAR",(7200,8000,11025)**

>>>> It has () around the supported voice sampling rates with three 
    choices. You need to select 8000 for use with the default 
    **NumberDisconnected.rmd** file. Make the following change in
    **ncidd.conf**:
    
>>>>> **set audiofmt = "AT+VSM=128,8000"**

>>> ##### <a name="hangup_ann_rmd"></a>Creating a Voice File from Scratch
  
>>> This is a rather lengthy procedure so we have dedicated 
    [Hangup Appendix B: Creating a Voice File from Scratch](#hangup_scratch)
    to this topic.
  
<!--
[### Blacklist and Alias Files Usage]
-->

### <a name="overview_blacklist"></a> Blacklist and Alias Files Usage

> File **ncidd.blacklist** is a list of names and/or numbers that will
  be terminated using one of the Hangup Choices above. By making use of
  expressions and wildcards, you can achieve more complex matching logic
  with even fewer entries in the blacklist. See the
  the [ncidd.blacklist.5](http://ncid.sourceforge.net/man/ncidd.blacklist.5.html) 
  man page for more info.
   
> Comments are supported and must begin with a **#**. Comments can be 
  an entire line, or a comment can be at the end of an entry line.

> A leading *#* is allowed in a name or number provided it is enclosed in double quotes.
  Sometimes a spoofed number starts with one or more *#* to prevent it from being blacklisted.
   
> Beginning with NCID version 1.3, a **match name** is a special kind of
  comment that replaces the caller name or alias when it matches an 
  entry in either the blacklist or whitelist. It can only be at the end 
  of an entry line and must begin with **#=**. 
   
> All phone numbers below are intended to be fictitious.

> - Method 1: Using only blacklist file entries

<!--
Sometimes (only sometimes) Pandoc doesn't like a table row to end with 
nothing; Pandoc loses track of the fact that it is rendering a table.
So use '&nbsp;'. '&#32;' also works.
-->

>>> 
  **ncidd.blacklist**| Optional Comment
  -------------------|----------------------------
  2125550163         | # Free home security system
  2265196565         | &nbsp;
  2145559648         | # Win a free cruise
  3402090504         | &nbsp;
  8772954057         | # Acme Market Research
  9792201894         | # Political survey
  "#########8"       | # The quotes are required

> - Method 2: Using multiple alias entries and one blacklist entry

>> When a call comes in, NCID will apply any [alias](#alias_top) 
   transformations before checking the blacklist file. You can use this
   to your advantage to simplify the number of entries needed in
   **ncidd.blacklist**. Another advantage this gives you is that NCID 
   clients (e.g., NCIDpop) will show the caller name as 
   <u>TELEMARKETER</u> to indicate the reason for the hangup.

>>> 
  **ncidd.alias**              | Matching phone#
  -----------------------------|----------------
  alias NAME * = "TELEMARKETER"| if 2125550163
  alias NAME * = "TELEMARKETER"| if 2265196565
  alias NAME * = "TELEMARKETER"| if 2145559648
  alias NAME * = "TELEMARKETER"| if 3402090504
  alias NAME * = "TELEMARKETER"| if 8772954057
  alias NAME * = "TELEMARKETER"| if 9792201894
>>
<p>
>>> 
  **ncidd.blacklist**| &nbsp; 
  -------------------| - 
  "TELEMARKETER"     | &nbsp; 

> - Method 3: Using only blacklist file entries with a **match name**

>> Beginning with NCID version 1.3, Method 2 can be simplified further
   by using the blacklist line comment field to be a match name. This
   behaves like an alias but you don't need to make entries in
   **ncidd.alias**. The trick is to use the two characters ***#=***
   as a special comment line. Spaces are optional between ***#=*** 
   and the match name.
    
>> The blacklist match name overrides the incoming caller ID name and
   any **ncidd.alias** match that might exist.

>> 
>>> 
  **ncidd.blacklist**| Match Name in Comment
  -------------------|----------------------------
  2125550163         | #= Free home security system
  2265196565         | #= TELEMARKETER
  2145559648         | #= Win a free cruise
  3402090504         | #= TELEMARKETER
  8772954057         | #= Acme Market Research
  9792201894         | #= Political survey
  "#########8"       | #= Tried to avoid the blacklist

<!--
[#### Whitelist File Usage]
-->  
  
> #### <a name="overview_whitelist"></a> Whitelist File Usage

>> File **ncidd.whitelist** is a list of names and/or numbers that will
   prevent a blacklist entry from causing a hangup. By making use of
   expressions and wildcards, you can achieve more complex matching 
   logic with even fewer entries in the whitelist. See
   the [ncidd.whitelist.5](http://ncid.sourceforge.net/man/ncidd.whitelist.5.html)
   man page for more info.

>> Comments are supported and must begin with a **#**. Comments can be 
   an entire line, or a comment can be at the end of an entry line.

>> A leading *#* is allowed in a name or number provided it is enclosed in double quotes,
   just like in the blacklist.
   
>> The whitelist match name is entered the same way as a blacklist match 
   name, using ***#=***.

>> The whitelist match name overrides the incoming Caller ID name and 
   any **ncidd.alias** match that might exist.

>> This example shows how to blacklist an entire area code while 
   allowing specific numbers. It also shows how to indicate when there 
   is a match in the whitelist.

>>> 
  **ncidd.blacklist**| Match Name in Comment
  -------------------|:---------------------------
  "999"              | #= Blacklist area code 999
  "998"              | #= Blacklist area code 998
>>
<p>
>>>
  **ncidd.whitelist**| Match Name in Comment&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  -------------------|:----------------------
  9995556732         | #= WHT 999-555-6732
  9985550000         | #= WHT James Bond

<!--
[#### Blacklist and Whitelist Expressions]
-->  
  
> #### <a name="overview_expr"></a> Blacklist and Whitelist Expressions

>> The Blacklist and Whitelist can have either Simple Expressions or
   Regular Expressions (but not both) for an entry.

>> In addition, when running the NCID server in the US or Canada, the 
   **ignore1** option can be set in **ncidd.conf** to ignore a leading 1
   in the Caller ID, alias, blacklist, or whitelist.
   
>> Simple Expressions (**set regex = 0** in **ncidd.conf**):

>>> ^ = partial match from beginning  
    1? = optional leading 1 (for US/Canada numbers)

>> Regular Expressions (**set regex = 1** in **ncidd.conf**):

>>> Regular Expressions are used in place of Simple Expressions. The 
    syntax for Simple Expressions is not compatible with Regular 
    Expressions except for **^**, **^1?**, and **1?**.

>> - The [POSIX Extended Regular Expression syntax](https://en.wikipedia.org/wiki/Regular_expression#POSIX_basic_and_extended) is used.  
    It is a section in
    [Regular Expression](https://en.wikipedia.org/wiki/Regular_expression).

>> - If you are new to Regular Expressions, see
    [Regular-Expressions.info](http://www.regular-expressions.info/quickstart.html)
    for an introduction.


<!--
[### Hangup Appendix A: Server Log File Sample]
-->   
   
### <a name="hangup_log"></a>Hangup Appendix A: Server Log File Sample

> The **ncidd.log** is useful for indicating **ncidd** configuration settings,
  modem features, modem settings, and debugging information.

> This is a portion of the output for a tty port and an LB LINK USB Modem.
  The output is at the default verbose 1 level.  It is useful for reviewing
  the tty port parameters, the modem identifier, country code,
  **Voice Sampling Methods** supported, the VSM selected, and
  the setting of the hangup option:

>> TTY port opened: /dev/ttyACM0  
   TTY port speed: 115200  
   TTY lock file: /var/lock/lockdev/LCK..ttyACM0  
   TTY port control signals enabled  
   CallerID from AT Modem and optional gateways  
   Handles modem calls without Caller ID  
   Modem initialized.  
   Modem Identifier: CX93001-EIS_V0.2013-V92  
   Modem country code: B5 United States  
   Modem ACTIVE PROFILE:  
   B1 E1 L2 M1 N0 Q0 T V1 W0 X4 Y0 &C1 &D2 &G0 &J0 &K3 &Q5 &R1 &S0 &T5 &X0  
   S00:0 S01:0 S02:43 S03:13 S04:10 S05:8 S06:2 S07:50 S08:1 S09:6  
   S10:14 S11:85 S12:50 S18:0 S25:5 S26:1 S36:7 S38:20 S46:138 S48:7  
   S95:0  
   Modem supports Data Mode  
   Modem supports FAX Mode 1  
   Modem supports FAX Mode 2  
   Modem supports VOICE Mode  
   Hangup option = 3 - play an announcement then hangup on a blacklisted call  
   Internal Hangup recording file: /usr/share/ncid/recordings/NumberDisconnected.rmd  
   Manufacturer: CONEXANT  
   Modem Voice Sampling Methods:  
   0,"SIGNED PCM",8,0,8000,0,0  
   1,"UNSIGNED PCM",8,0,8000,0,0  
   129,"IMA ADPCM",4,0,8000,0,0  
   130,"UNSIGNED PCM",8,0,8000,0,0  
   131,"Mu-Law",8,0,8000,0,0  
   132,"A-Law",8,0,8000,0,0  
   133,"14 bit PCM",14,0,8000,0,0  
   Modem Voice Sampling Method selected: AT+VSM=130

<!--
[### Hangup Appendix B: Creating a voice file from scratch]
-->

### <a name="hangup_scratch"></a>Hangup Appendix B: Creating a Voice File from Scratch

> You may wish to check the [Network Caller ID page at Wikipedia](https://en.wikipedia.org/wiki/Network_Caller_ID) to see if
> someone has already documented the steps for your
modem.

> #### <a name="hangup_prereq"></a> Prerequisites

>> This procedure uses Linux to convert the files.  

>> The **sox** and **mgetty-voice** packages need to be installed.

>> An audio file, preferrably one channel (mono), a sample rate
>> of 8000 Hz (8 kHz), and a sample size of 8 bits. This file
>> can be either of the following:  

>> * An audio file in a format that **sox** supports. A .wav
>>   file is the most common. **Sox** does not support .mp3 files.
>>   
>> * A Portable Voice Format (.pvf) file. A few are supplied
>>   with NCID.

>> The chipset identifier returned by the modem's **ATI3** response.

>> * This will be in the startup section of /var/log/ncidd.log
>> with the line, "Modem Identifier: ...".

>> The **Voice Sampling Methods** returned by the modem's **AT+VSM=?**
>> response, and the directory to store the Raw Modem Data (.rmd) file.

>> * These are both in the startup section of /var/log/ncidd.log
>> where the lines start with, "Modem Voice Sampling Methods:&nbsp;..."
>> and "Internal Hangup voice file: ...".

>> * If you don't see these in the log file, you probably
>>   don't have Announce Hangup configured yet in ncidd.conf. 
>>   You can temporarily enable it by typing the following
>>   commands, and then examine ncidd.log:  

>>>       sudo pkill ncidd  
>>>       sudo ncidd -Dv1 -p 3334 -N1 -H3

> #### Examine the Modem's Voice Sampling Methods (VSM)

>> Your ultimate goal in creating a custom voice file is to take
>> a Portable Voice File (.pvf) and use the **pvftormd** command
>> line program to convert it to a Raw Modem Data (.rmd) file
>> that is specific to your modem type (chipset).

>> The tricky part is in trying find a compression method for
>> **pvftormd** that is comparable to one of the 
>> **Voice Sampling Methods** and codecs returned by the modem's
>> (often cryptic) **AT+VSM=?** response. Compounding the challenge
>> are the facts that:
>> 
>> * Different modem manufacturers often have their own codec
>>   naming convention when listing the VSMs.  

>> * Determining which **pvftormd** modem type is a match for
>>   your modem is sometimes not obvious.
>>  
>> In the discussion below, we'll see examples of this challenge
>> as we use one of the .pvf files supplied with NCID to create
>> the .rmd file that works on two different modem chipsets:
>> Conexant CX93001 and USR5637.

>> #### <u>Conexant CX93001</u>

>> The **pvftormd** tool requires a modem type. The supported
>> modem types and raw modem data formats are listed with the
>> **-L** option:

>>     pvftormd -L

>> Refer to [Hangup Appendix C: Raw Modem Data Formats](#hangup_raw). 
>> You'll notice that there's nothing listed in Column 1 that
>> has "Conexant" as part of its name.
>> 
>> So what modem type was used to create the .rmd files supplied
>> with NCID and why/how was it chosen? The answer to the first
>> part of the question is "V253modem" and the answer to the
>> second part is "by experimenting" (or perhaps, "luck").

>> If your modem isn't listed, which is highly *likely*, you
>> have to start somewhere so try something for an 8 bit PCM 
>> format:

>> * **V253modem 8** for linear *unsigned* PCM, or  
>> * **V253modem 9** for linear *signed* PCM.

>> Next, you want to look at the modem's VSM info to see if you
>> can find a match on 8 bit, linear, PCM, signed or unsigned.

>> Here's the VSM info from ncidd.log for a modem with a Conexant 
>> CX93001 chipset:
  
>>      0,"SIGNED PCM",8,0,8000,0,0
     1,"UNSIGNED PCM",8,0,8000,0,0  
     129,"IMA ADPCM",4,0,8000,0,0  
     130,"UNSIGNED PCM",8,0,8000,0,0  
     131,"Mu-Law",8,0,8000,0,0  
     132,"A-Law",8,0,8000,0,0  
     133,"14 bit PCM",14,0,8000,0,0

>> The line for 130 looks promising so we'll try that first. The
>> line for 1 might also work since it "looks" the same as line 130.
>> Probably the only reason 130 was chosen is that users
>> seem to have better luck with values 100 and greater.
  
>> In conclusion, we've decided to try these settings 
>> for the Conexant CX93001 chipset:  

>> * "V253modem 8" for the **pvftormd** tool to create the .rmd   
>> * "AT+VSM=130" as the **audiofmt** setting in ncidd.conf

>> #### <u>USR5637</u>
  
>> For the USR5637 chipset, it just so happens that trying the
>> .rmd for the Conexant CX93001 chipset works just fine, but
>> it does require a different VSM setting. Looking at ncidd.log
>> for this modem we see:

>>      128,"8-BIT LINEAR",(7200,8000,11025) 
     129,"16-BIT LINEAR",(7200,8000,11025)
     130,"8-BIT ALAW",(8000)
     131,"8-BIT ULAW",(8000)
     132,"IMA ADPCM",(7200,8000,11025)

>> The Conexant CX93001 codec we picked to try was "UNSIGNED PCM"
>> but as you can see, that's not an option for the USR5637.
>> We'll pick line 128, "8-BIT LINEAR" and hope it'll work.

>> A little more work needs to be done, though. The presence of
>> the () for line 128 means we have to specify one of the three
>> sampling rates, but which one? Recall the line we used for the
>> Conexant CX93001:

>>      130,"UNSIGNED PCM",8,0,8000,0,0  

>> The sampling rate is fixed at 8000 so we'll try that for the USR5637.

>> In conclusion, we've decided to try these settings 
>> for the USR5637 chipset:  

>> * "V253modem 8" for the **pvftormd** tool to create the .rmd
>> * "AT+VSM=128,8000" as the **audiofmt** setting in ncidd.conf
  
> #### <a name="hangup_pvf"></a> Creating a Portable Voice File (.pvf)

>> You would do the steps here if you want to use a .wav file or other
>> audio file format supported by **sox**.

>> You can either record an announcement or download a .wav
>  file from the internet. A good place to start is
>  [This Is a Recording](http://www.thisisarecording.com/).

>> Once you have the .wav file, you need to convert it to a .pvf.
>> We'll use the parameters listed under Prerequisites:
>> one channel (mono), a sample rate of 8000 Hz (8 kHz), and a
>> sample size of 8 bits.

>> Assuming the file is called **custom.wav**:

>>>     sox custom.wav -t pvf -c 1 -r 8000 -b 8 custom.pvf

>> You can use the **play** command to listen to it:

>>>     play custom.pvf

>> Make sure the playback is clear and no spoken words get dropped. If
>> the playback doesn't sound good as a .pvf, it is probably not going
>> to sound good when you convert it to an .rmd for playback through the
>> modem. You may need to use a different source .wav file and/or
>> you'll need to experiment with the **sox** parameters.

>>> Note: It is probably not going to work very well if you try the
>>> the **play** command on a virtual Linux machine because playing back
>>> audio can cause a performance hit on the virtual machine's CPU and
>>> other resources. Instead, you will want to **play** it on a physical
>>> machine. As an alternative to the **play** command, you could play 
>>> it back using cross-platform versions of 
>>> [Audacity](http://www.audacityteam.org/) or 
>>> [VideoLAN](http://www.videolan.org/).

>> Generally speaking, you only need to create a .pvf file once. It can
>> then be used to create .rmd files for multiple modem chipets.

>> If you need to examine the properties of a .pvf file, use the
>> **soxi** tool:

>>>
    $ soxi CallingDeposit.pvf
    Input File : 'CallingDeposit.pvf'
    Channels : 1
    Sample Rate : 8000
    Precision : 8-bit
    Duration : 00:00:09.90 = 79203 samples ~ 742.528 CDDA sectors
    File Size : 79.2k
    Bit Rate : 64.0k
    Sample Encoding: 8-bit Signed Integer PCM
    $

> #### <a name="hangup_rmd"></a> Creating a Raw Modem Data (.rmd) File

>> Once you have a .pvf file, you must convert it to an .rmd
>> that is specific for your modem's chipset.

>> Assuming the file is called **custom.wav**:

>>>     pvftormd V253modem 8 custom.pvf custom.rmd

>> The **NumberDisconnected.pvf** voice file was used to create
>> **NumberDisconnected.rmd**. The .pvf files for the distribution
>> are in the documentation directory which is usually:
  
>>> /usr/share/doc/ncid/recordings
>>> 
>>> or
>>> 
>>> /usr/local/share/doc/ncid/recordings

>> Use **NumberDisconnected.pvf** to create a **raw modem data (.rmd)** file
  for your modem  if the default one, **NumberDisconnected.rmd**, is not usable.

>> Convert it to .rmd:  
  
>>>     pvftormd V253modem 8 NumberDisconnected.pvf NumberDisconnected.rmd  
  
>> If you need to examine the properties of an .rmd file, use the
>> **rmdfile** tool:

>>>
    $ rmdfile CallingDeposit.rmd
    CallingDeposit.rmd: RMD1
    modem type is: "V253modem"
    compression method: 0x0008
    sample speed: 8000
    bits per sample: 8
    $
 
> #### <a name="hangup_scratch_conf"></a> Configuring NCID to use a Custom Voice File

>> Copy the custom .rmd file to the directory to store the
>> Raw Modem Data (.rmd) file (see [Prerequisites](#hangup_prereq)).

>> Edit **ncidd.conf** to enable Announce Hangup, indicate the
>> name of the custom .rmd file and the AT+VSM command to use.

>> Example:

>>>     set hangup = 3
>>>     set announce = custom.rmd
>>>     set audiofmt = "AT+VSM=128,8000"

> #### <a name="hangup_scratch_conf"></a> Testing a Custom Voice File

>> The best way to test a custom voice file is to temporarily add your
>> phone number to the blacklist file and call yourself. Use a handset
>> or headset to listen to the call and not speakerphone or handsfree 
>> mode. 

>> If you experience any of the following, you will need to experiment
>> with different parameters when running **pvftormd** and/or different
>> AT+VSM settings:

>> * dropped spoken words or words that are completely unrecognizable
>> * play back is too fast or too slow
>> * you hear static noise
 
<!--
[### Hangup Appendix C: Raw Modem Data Formats]
-->

### <a name="hangup_raw"></a> Hangup Appendix C: Raw Modem Data Formats

> You would probably refer to this appendix only if you're using the 
  Announce Hangup option.

> The **pvftormd** command line program requires a modem type. The supported
  raw modem data formats are listed with the **-L** option:

>> **pvftormd -L**

> Column headings added to chart for readability:
> 
> 1. Modem type or manufacturer.  
> 2. One or more numbers representing different compression methods
>    (these values are unique to **pvftormd** and have no relation to a modem's 
>    compression number in its **AT+VSM=?** reponse).  
> 3. Description of the compression method and usually lists the bit
>    levels supported by **pvftormd**.  

> Output of **pvftormd -L** follows:

>>       pvftormd experimental test release 0.9.32 / with duplex patch

>>       supported raw modem data formats:

>>> 
Column 1             | Column 2  | Column 3 
:--------------------|:----------|:-------------------------- 
- Digi          | 4         | G.711u PCM  
- Digi          | 5         | G.711A PCM  
- Elsa          | 2, 3, 4   | 2/3/4-bit Rockwell ADPCM  
- ISDN4Linux    | 2, 3, 4   | 2/3/4-bit ZyXEL ADPCM  
- ISDN4Linux    | 5         | G.711A PCM  
- ISDN4Linux    | 6         | G.711u PCM  
- Lucent        | 1         | 8 bit linear PCM  
- Lucent        | 2         | 16 bit linear PCM  
- Lucent        | 3         | G.711A PCM  
- Lucent        | 4         | G.711u PCM  
- Lucent        | 5         | 4 bit IMA ADPCM
- MT_2834       | 4         | 4 bit IMA ADPCM
- MT_5634       | 4         | bit IMA ADPCM
- Rockwell      | 2, 3, 4   | 2/3/4-bit Rockwell ADPCM
- Rockwell      | 8         | 8-bit Rockwell PCM
- UMC           | 4         | G.721 ADPCM
- US_Robotics   | 1         | USR-GSM
- US_Robotics   | 4         | G.721 ADPCM
- V253modem     | 2, 4      | 2/4-bit Rockwell ADPCM
- V253modem     | 5         | 4-bit IMA ADPCM
- V253modem     | 6         | G.711u PCM
- V253modem     | 7         | G.711A PCM
- V253modem     | 8         | 8-bit linear unsigned PCM
- V253modem     | 9         | 8-bit linear signed PCM
- V253modem     | 12        | 16-bit linear signed PCM Intel Order
- V253modem     | 13        | 16-bit linear unsigned PCM Intel Order
- ZyXEL_1496    | 2, 3, 4   | 2/3/4-bit ZyXEL ADPCM
- ZyXEL_2864    | 2, 3, 4   | 2/3/4-bit ZyXEL ADPCM
- ZyXEL_2864    | 81        | 8-bit Rockwell PCM
- ZyXEL_Omni56K | 4         | 4-bit Digispeech ADPCM (?)

>>       example:

>>               pvftormd Rockwell 4 infile.pvf outfile.rmd


<!--
[### Hangup Appendix D: Modem AT+VSM Command Explained]
-->   
   
### <a name="hangup_vsm"></a>Hangup Appendix C: Modem AT+VSM Command Explained

> Here is a breakdown of what each parameter means in the AT+VSM command:
> 
        Command: AT+VSM=? 
        Response: <cml>,<cmid>,<bps>,<tm>,<vsr>,<sds>,<sel>
>
        <cml> Decimal number identifying the compression method (1, 129,
              130, 140, or 141).
>
        <cmid> Alphanumeric string describing the compression method (UNSIGNED
               PCM, IMA ADPCM, UNSIGNED PCM, 2 Bit ADPCM, or 4 Bit ADPCM).
>
        <bps> Decimal number defining the average number of bits in the
              compressed sample not including silence compression (2, 4 or 8).
>
        <tm> Decimal number (0) reporting the time interval, in units of
             0.1 second, between timing marks. A value of 0 reports that
             timing marks are not supported.
>
        <vsr> <range of values> containing the supported range of voice
              samples per second of the analog signal (8000).
>
        <scs> <range of values> containing the supported range of sensitivity
              settings for voice receives (0). A 0 indicates not supported.
>
        <sel> <range of values> containing the supported range of expansion
              values for voice transmits (0). A 0 indicates not supported.
