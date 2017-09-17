<!-- Message.md - Removable HEADER Start -->

Last edited: November 3, 2016

<!-- Removable HEADER End -->

## <a name="message_top"></a> NCID Messages

> [Table of Contents](#doc_top)

> [Description](#mesg_des)  

### <a name="mesg_des"></a> Description

> NCID supports three different types of messages.  All messages must be
  a single line. All messages must begin with either a <font color="red">MSG:</font>, 
  <font color="red">NOT:</font>, or <font color="red">RLY:</font> label.

> #### <font color="red">MSG:</font>

>> The server accepts a single line text message from a client and
   broadcasts it to all connected clients. All messages must
   begin with the <font color="red">MSG:</font> label.

>> Gateways can send <font color="red">MSG:</font> lines, too. For example,
>> ncid2ncid will send <font color="red">MSG:</font> lines to indicate the
>> connection status as it passes caller ID data between two or more NCID
>> servers.

>> Programs external to NCID, such as netcat (a.k.a. nc and ncat), can be
>> used to send a message. Telnet is not recommended. If netcat is used,
>> please note there are different versions with different options.

>> This shell script example creates a 10 minute food timer. The -w1 is a 
one second idle timeout to wait before disconnect: 

>> `sleep 600; echo "MSG: Food Ready" | nc -w1 localhost 3333 > /dev/null`

>> An equivalent batch file using netcat for Windows would be:
   
>> `CHOICE /T 600 /C AB /N /D A > NUL`
>> `echo MSG: Food Ready | nc -w1 192.168.1.100 3333 > NUL`

>>> Note: The recommended netcat version for Windows is the security-safe
>>> version by Jon Craton. It is available for download from his website
>>> [here](https://joncraton.org/files/nc111nt_safe.zip). When extracting,
>>> use the password "nc" (without quotes).

>> You can send a <font color="red">HELLO: CMD: no_log</font> line
  prior to a <font color="red">MSG:</font> line. This can improve performance
  because it forces the server not to send the call log before processing the
  <font color="red">MSG:</font>.
  
>> Unix:  
  
>> `sleep 600; echo -e "HELLO: IDENT: client food timer 1.1\nHELLO: CMD: no_log\nMSG: Food Ready" | nc -w1 localhost 3333 > /dev/null`

>> Windows batch file:
   
>> `CHOICE /T 600 /C AB /N /D A > NUL`
>> `(echo HELLO: IDENT: client food timer 1.1&echo HELLO: CMD: no_log&echo MSG: Food Ready) | nc -w1 192.168.1.100 3333 > NUL`

> #### <font color="red">NOT:</font>

>> Utilizing the same format as <font color="red">MSG:</font>,
>> when a smartphone gateway (e.g., NCID Android) sends a copy of an SMS
   text message received or sent by a smartphone, it uses the 
   <font color="red">NOT:</font> line label.

> #### <font color="red">RLY:</font>

>> When a client (e.g., NCIDpop) sends a message to be forwarded over the
   cellular network, it uses the <font color="red">RLY:</font> label to
   send it to a smartphone gateway (e.g., NCID Android). It uses a very 
   different format compared to <font color="red">MSG:</font>
   and <font color="red">NOT:</font>.
