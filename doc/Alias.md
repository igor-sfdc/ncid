<!-- Alias.md - Removable HEADER Start -->

Last edited: Jul 29, 2016

<!-- Removable HEADER End -->

## <a name="alias_top"></a>Aliases

> [Table of Contents](#doc_top)

<!--
[### Alias Index]
-->

### Alias Index

> [Alias Overview](#alias_ov)  
> [Alias Types](#alias_types)  

>>  [number alias](#alias_nmbr)  
>>  [name alias](#alias_name)  
>>  [number & name alias](#alias_both)  
>>  [number if name alias](#alias_if_name)  
>>  [name if number alias](#alias_if_nmbr)  
>>  [line alias](#alias_line)  

> [Alias Expressions](#alias_exp)

<!--
[### Alias Overview]
-->

### <a name="alias_ov"></a>Alias Overview

> The name, number, and telephone line of a call are checked for an 
  alias. If a match is found it will be replaced by its alias 
  before the call is added to the call log and before the call 
  information is sent to the clients.

> A leading *#* is allowed in a name or number provided it is enclosed in double quotes.
  Sometimes a spoofed number starts with one or more *#* to prevent it from being blacklisted. 
     
> Alias names can be a maximum of 50 characters.

> You can manually edit the **ncidd.alias** file to create, edit, or 
  remove entries using an editor.
    
> When the alias file is modified, **ncidd** needs to be informed.  It
  will reload the alias table when it receives a SIGHUP signal.

>> One way to send the reload signal to **ncidd**:

>>> **pkill --signal SIGHUP ncidd**

>> You can also just restart **ncidd**.

> Aliases can also be created, edited, or removed by these NCID clients.
  They provide ways to force the server to reload the alias table.

> - [ncid](#clients_ncid)  
> - [NCIDpop](#clients_pop)  
> - <strike>NCID Android</strike> <font color="dimgray">Alias maintenance not available</font>

> In addition, when running the NCID server in the US or Canada, the 
  **ignore1** option can be set in **ncidd.conf** to ignore a leading 1
  in the Caller ID number or the alias number.

<!--
[### Alias Types]
-->
  
### <a name="alias_types"></a>Alias Types
  
> The three general formats for entries in **ncidd.alias** are:

> - alias "**received data**" = "**replacement data**"  
> - alias "**TYPE**" "**received data**" = "**replacement data**"  
> - alias "**TYPE**" "**\***" = "**replacement data**" if "**depends**"
>
<!-- 
To generate proper bullets in ReText, the lines beginnning with 'Where'
and 'When' need a completely blank line under them. Otherwise, ReText
can't seem to generate proper bullets. An alternative work around is to
use &bull;, which is smaller than normal, so make it bold with **&bull;**
-->


> Where:  

> - **TYPE** is NAME, NMBR, or LINE  
> - **received data** or **depends** is the name or number to change to 
    an alias  
> - **replacement data** is the alias

> When **TYPE** is NAME and **depends** is present: 

> - **depends** is the <u>received number</u> to match against when 
    setting the alias to be **replacement name**. The position normally
    used for **received data** must be an **\***.
    
> When **TYPE** is NMBR and **depends** is present:

> - **depends** is the <u>received name</u> to match against when 
    changing **received number** to **replacement number**. The position
    normally used for **received data** must be an **\***.    
>  
> When **TYPE** is missing, the NMBRNAME rule applies:  

> - if **received number** matches <u>received data</u>, it will be 
    changed to **replacement data**

>> ...and/or...

> - if **received name** matches <u>received data</u>, it will be
    changed to **replacement data**
  
> The three general formats allow for six types of aliases:

<!-- 
there is a long sequence of &nbsp; in the Type header column so 
that the Type cell contents won't wrap 
-->

>> Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| Format  
>> :--------------|--------  
 number         | alias NMBR "received number" = "replacement number" 
 name           | alias NAME "received name" = "replacement name" 
 number & name  | alias "received data" = "replacement data"
 number if name | alias NMBR = "\*" = "replacement number" if&nbsp;"depends"
 name if number | alias NAME = "\*" = "replacement name" if&nbsp;"depends"
 lineid         | alias LINE = "received call lineid" = "replacement lineid"

<!--
[#### Number Alias]
--> 
 
> #### <a name="alias_nmbr"></a>Number Alias

> The **number alias** changes the number of the caller to an alias.  The number can be a word.

>> Format: **alias NMBR "received number" = "replacement number"**

>> Example: **alias NMBR "4075550000" = "4075551212"**

<!--
[#### Name Alias]
--> 
 
> #### <a name="alias_name"></a>Name Alias
    
> The **name alias** changes the name of the caller to an alias.

>> Format: **alias NAME "received name" = "replacement name"**

>> Example: alias NAME "John Bright" = "Big Bad John"

<!--
[#### Number and Name Alias]
--> 
 
> #### <a name="alias_both"></a>Number and Name Alias

> The **number and name alias** checks both the caller number and caller name for a match.
  If either matches, it is replaced by the alias.

> This alias type is useful when both the name and number are the same.
  For example, if the name and number are both "OUT-OF-AREA".

> Another use is if you do not care if the string you are looking for is a
  name or number.  You want it replaced if it is either a name or number.

>> Format: **alias "received data" = "replacement data"**

>> Example: **alias "OUT-OF-AREA" = "UNAVAILABLE"**

<!--
[#### Number if Name Alias]
--> 
 
> #### <a name="alias_if_name"></a>Number if Name Alias

> The **number if name alias** changes the number of the caller if the 
  name matches **depends**. Quotes around the "**\***" are optional.
  
>> Format **alias NMBR "\*" = "replacement number" if "depends"**

>> Example: **alias NMBR \* = "secret" if "Bond James"**

<!--
[#### Name if Number Alias]
--> 
 
> #### <a name="alias_if_nmbr"></a>Name if Number Alias

> The **name if number alias** is the most popular alias.  It changes
  the name of the caller if the number matches **depends**. Quotes
  around the "**\***" are optional.

>> Format **alias NAME "\*" = "replacement name" if "depends"**

>> Example: **alias NAME \* = "john on cell" if "4075556767"**

<!--
[#### Line Alias]
--> 
 
> #### <a name="alias_line"></a>Line Alias

> The **line alias** changes the telephone line tag to an alias.

>> Format **alias LINE "received call lineid" = "replacement lineid"**

>> Example: **alias LINE "-" = "POTS"**

<!--
[### Alias Expressions]
--> 
 
### <a name="alias_exp"></a>Alias Expressions

> Simple expressions (**set regex = 0** in **ncidd.conf**)
> 
>> These are permitted in either:

>>> the **depends** section of an alias line 

>>> ...or...  

>>> the **received data** section, if the alias line does not contain 
    **depends**

>> The allowed expressions are:

>> - **received data** and **depends** can contain a **^** or **\*** or
     **1?** at the beginning:

>>> ^ = partial match from beginning  
    \* = partial match after the \*  
    ^1? = optional leading 1 for US/Canada numbers

>> - **received data** and **depends** can contain an **\*** at the end:

>>> \* = partial match from beginning to before the \*

>> - **received data** can contain a single \* to match anything

> Regular Expressions (**set regex = 1** in **ncidd.conf**)
> 
>> They are used in place of Simple Expressions. The syntax for Simple
   Expressions is not compatible with Regular Expressions except for
   **^**, **^1?**, and **1?**.

>> The [POSIX Extended Regular Expression syntax](https://en.wikipedia.org/wiki/Regular_expression#POSIX_basic_and_extended)
    is used. It is a section in [Regular Expression](https://en.wikipedia.org/wiki/Regular_expression).

>> If you are new to Regular Expressions, see [Regular-Expressions.info](http://www.regular-expressions.info/quickstart.html)
    for an introduction.
