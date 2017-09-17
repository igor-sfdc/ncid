/*
 * nciddhangup.c - This file is part of ncidd.
 *
 * Copyright (c) 2005-2016
 * by John L. Chmielewski <jlc@users.sourceforge.net>
 *
 * ncidd is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * ncidd is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with ncidd.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "ncidd.h"

/* globals */
int pickup = 1;
int regex, wflag;
char *blacklist = BLACKLIST, *listname;
char *whitelist = WHITELIST;
char *audiofmt  = XPRESS;
char *strdate();
struct list *blkHead = NULL, *blkCurrent = NULL,
            *whtHead = NULL, *whtCurrent = NULL;

int doList(), onList(), hangupCall(), doHangup(), onBlackWhite();

void addEntry(), nextEntry(), rmEntries(), checkWhitelist();

#ifndef __CYGWIN__
    extern char *strsignal();
#endif

/*
 * Process the blacklist or whitelist file
 * Returns: 0 - no errors
 *          # of errors
 */
int doList(char *filename, list_t **listHead, list_t **listCurrent)
{
    char input[BUFSIZ], word[BUFSIZ], msgbuf[BUFSIZ], *inptr, *ptr;
    struct list *node, *nextnode;
    int lc, i, bl;
    int max_temp = 0, max_entry = 0;
    FILE *fp;

    bl = !strcmp(blacklist, filename) ? 1 : 0;

    if ((fp = fopen(filename, "r")) == NULL)
    {
        sprintf(msgbuf, "%s file missing: %s\n",
                bl ? "Blacklist" : "Whitelist", filename);
        logMsg(LEVEL1, msgbuf);
        return 1;
    }
    fnptr = filename;

    /* read each line of file, one line at a time */
    for (lc = 1; fgets(input, BUFSIZ, fp) != NULL; lc++)
    {
        /* line containing only <NL> or <CR><NL> or is a comment line*/
        if (input[0] == '\n' || input[0] == '\r' || input[0] == '#') continue;

        /* remove '\n' and '\r' if there */
        if ((ptr = strchr(input, (int) '\n'))) *ptr = '\0';
        if ((ptr = strchr(input, (int) '\r'))) *ptr = '\0';

        inptr = getWord(fnptr, input, word, lc);

        /* get search strings on line */
        addEntry(inptr, word, lc, listHead, listCurrent);
    }
    (void) fclose(fp);
    sprintf(msgbuf, "Processed %s file: %s\n",
            bl ? "blacklist" : "whitelist", filename);
    logMsg(LEVEL1, msgbuf);

    sprintf(msgbuf, "%s Table:\n", bl ? "Blacklist" : "Whitelist");
    logMsg(LEVEL1, msgbuf);

    if (!errorStatus && *listHead)
    {
        node = *listHead;
        for (i = 0; node != NULL; i++)
        {
            nextnode = node->next;
            node = nextnode;
        }

        sprintf(msgbuf, "    Number of Entries: %d\n", i);
        logMsg(LEVEL1, msgbuf);

        /*
         * Make the List display pretty by determining maximum column width.
         */

        node = *listHead;
        while(node != NULL)
        {
            nextnode = node->next;
            max_temp = strlen(node->entry);
            if (max_temp > max_entry) max_entry = max_temp;
            node = nextnode;
        }

        sprintf(msgbuf, "    %-4s %s%-*s %s\n",
            "SLOT",
            "ENTRY", max_entry - (int) strlen("ENTRY") + 2, "",
            "MATCH NAME");
        logMsg(LEVEL7, msgbuf);
        sprintf(msgbuf, "    %-4s %s%-*s %s\n",
            "----",
            "-----", max_entry - (int) strlen("ENTRY" + 2), "",
            "----------");

        logMsg(LEVEL7, msgbuf);

        node = *listHead;
        for (i = 0; node != NULL; i++)
        {
            nextnode = node->next;
            sprintf(msgbuf, "    %-4.3d \"%s\"%-*s ",
            i,
            node->entry,
            max_entry - (int) strlen(node->entry), "");

            if (strlen(node->newname))
                strcat(strcat(strcat(msgbuf, "\""), node->newname), "\"");
            strcat(msgbuf, NL);

            logMsg(LEVEL7, msgbuf);
            node = nextnode;
        }
    }
    else
    {
        sprintf(msgbuf, "    Number of Entries: 0\n");
        logMsg(LEVEL1, msgbuf);
    }

    return errorStatus;
}

/*
 * Process blacklist or whitelist file lines
 */
void addEntry(char *inptr, char *wdptr, int lc, list_t
              **listHead, list_t **listCurrent)
{
    int err;
    char errbuf[80], *cptr, *eptr;

    /* process the blacklist or whitelist words */
    do
    {
        /*
         * If inQuotes = 1, the word is inside "" and is not a comment.
         * Allows an entry in the blacklist or whitelist to begin with a "#".
         */
        if (!inQuotes && *wdptr == '#')    break; /* rest of line is comment */
        nextEntry(listHead, listCurrent);
        if (strlen(wdptr) > ENTRYSIZE - 1)
            configError(cidalias, lc, wdptr, ERRLONG);
        strcpy((*listCurrent)->entry, wdptr);
        if ((cptr = strstr(inptr, "#=")))
        {
            cptr += 2;
            eptr = cptr;

            /* remove any leading spaces */
            while (*cptr && *cptr == ' ') ++cptr;

            /* remove any trailing spaces */
            while (*eptr) eptr++;
            for (--eptr; *eptr && *eptr == ' '; --eptr) *eptr = 0;

            strncpy((*listCurrent)->newname, cptr, CIDSIZE - 1);
        }
        else (*listCurrent)->newname[0] = '\0';

        if (regex)
        {
          err = regcomp(&(*listCurrent)->preg, wdptr, REG_EXTENDED|REG_NOSUB);
          if (err)
          {
            regerror(err, &(*listCurrent)->preg, errbuf, sizeof(errbuf));
            configError(cidalias, lc, wdptr, errbuf);
          }
        }
    }
    while ((inptr = getWord(fnptr, inptr, wdptr, lc)) != 0);
}

/*
 * Adds a node to the list for a new entry
 */
void nextEntry(list_t **listHead, list_t **listCurrent)
{
    list_t *node;

    if (!(node = (list_t *) malloc(sizeof(list_t)))) errorExit(-1, name, 0);
    node->next = NULL;
    if (*listHead == NULL) *listHead = node;
    else (*listCurrent)->next = node;
    *listCurrent = node;
}

/*
 * Frees all list nodes
 */
void rmEntries(list_t **listHead, list_t **listCurrent)
{
    struct list *node = *listHead;
    struct list *nextnode;

    while (node != NULL)
    {
        nextnode = node->next;
        if (regex) regfree(&node->preg);
        free(node);
        node = nextnode;
    }

    *listHead = NULL;
    *listCurrent = NULL;
}

/*
 * Check if call is in whitelist file
 *
 * cflag == 0 if call not in whitelist
 * cflag == 1 if call is in whitelist
 *
 * if cflag == 0 call doHangup()
 *
 */

void checkWhitelist(char *namep, char *nmbrp)
{
    if (!onList(namep, nmbrp, 0, &whtHead)) wflag = 0;
    else wflag = 1;
}

/*
 * Check if call is in blacklist file
 *
 * A blacklist match must never be on the whitelist.
 *
 * Must call checkWhitelist() first to make sure call
 * is not on the whitelist.
 *
 * Hangup phone if match in blacklist file
 *
 * return = 0 if call not terminated
 * return = 1 if call terminated
 */

int doHangup(char *namep, char *nmbrp)
{
    int ret;

    logMsg(LEVEL5, "Processing hangup request\n");

    if (onList(namep, nmbrp, 0, &blkHead))
    {
        /* blacklist match */

        /* try to hangup a call */
        ret = hangupCall(hangup, annpath);

        /* normal hangup, return must be 0 */
        if (!ret) return 1;
    }

return 0;
}

/*
 * Hangup Call
 * return = 0  success
 * return != 0 error
 */
int hangupCall(int mode, char *recording)
{
    int ret = 0, ttyflag = 0, msgfd, rcnt, wcnt, tcnt = 0;
    unsigned int hangupdelay;
    char msgbuf[BUFSIZ], voicebuf[BUFSIZ];
    FILE *lockptr;

    (void) wcnt;

    /* if lockfile present, nothing to do */
    if (CheckForLockfile()) return 1;

    /* Create TTY port lockfile */
    if ((lockptr = fopen(lockfile, "w")) == NULL)
    {
        sprintf(msgbuf, "%s: %s\n", lockfile, strerror(errno));
        logMsg(LEVEL1, msgbuf);
        return 1;
    }
    else
    {
        /* write process number to lockfile */
        fprintf(lockptr, "%d\n", getpid());

        fclose(lockptr);
    }

    /*
     * if modem not used, open port and initialize it
     */
    if (!ttyfd)
    {
        ttyflag = 1;
        if ((ttyfd = open(ttyport, O_RDWR | O_NOCTTY | O_NDELAY)) < 0)
        {
            sprintf(msgbuf, "Modem: %s\n", strerror(errno));
            logMsg(LEVEL1, msgbuf);
            ret = ttyfd;
            ttyfd = 0;
        }
        else if ((ret = fcntl(ttyfd, F_SETFL, fcntl(ttyfd, F_GETFL, 0)
                 & ~O_NDELAY)) < 0)
        {
            sprintf(msgbuf, "Modem: %s\n", strerror(errno));
            logMsg(LEVEL1, msgbuf);
        }
        else
        {
            ret = setTTY();
            ret = setModem();
        }
    }

    if (!ret)
    {
        /* put tty port in raw mode */
        if (!(ret = tcsetattr(ttyfd, TCSANOW, &rtty) < 0))
        {
           /* Send AT to get modem OK after switch to raw mode */
           (void) initModem(GETOK, HANGUPTRY);

            if (mode == 1)    /* hangup mode */
            {
                /* Pick up the call */
                ret = initModem(PICKUP, HANGUPTRY);
                sprintf(msgbuf, "hangup mode %d: PICKUP sent, return code is %d\n",mode,ret);
                logMsg(LEVEL5, msgbuf);

                /* set off-hook delay to make sure to hangup call */
                hangupdelay = HANGUPDELAY;
            }
            else if (mode == 2)   /* FAX hangup mode */
            {
                /* Set FAX mode */
                ret = initModem(FAXMODE, HANGUPTRY);    /* AT+FCLASS=1 */
                sprintf(msgbuf, "hangup mode %d: FAXMODE sent, return code is %d\n",mode,ret);
                logMsg(LEVEL5, msgbuf);

                if (pickup)
                {
                    /* PICKUP required for some (mostly USB) modems */
                    ret = initModem(PICKUP, HANGUPTRY);
                    sprintf(msgbuf, "hangup mode %d: PICKUP sent, return code is %d\n",mode,ret);
                    logMsg(LEVEL5, msgbuf);
                }

                /* generate FAX tones */
                ret = initModem(FAXANS, HANGUPTRY);
                sprintf(msgbuf, "hangup mode %d: FAXANS sent, return code is %d\n",mode,ret);
                logMsg(LEVEL5, msgbuf);

                /* set off-hook delay so caller hears annoying fax tones */
                hangupdelay = FAXDELAY;
            }
            else /* Voice Hangup Mode (mode == 3) */
            {
              /*
               *  Set Voice Mode:             AT+FCLASS=8  (return == 0) OK
               *  speaker volume normal:      AT+VGT=128   (return == 0) OK
               *  Select Compress Method:     AT+VSM=128   (return == 0) OK
               *  Answer Call:                AT+VLS=1     (return == 0) OK
               *  Select Voice Transfer Mode: AT+VTX       (return == 1) CONNECT
               *  send voice data to modem
               *  end of voice data:          <DLE><ETX>   (return == 0) OK
               *  Go off hook in data mode:   ATH          (return == 0) OK
               *
               *  NOTE: AT+VSM=128 is the default used for the CONEXANT
               *        CX93001 chipset used in a lot of modems.
               */

                ret = initModem(VOICEMODE, HANGUPTRY);  /* AT+FCLASS=8 */
                sprintf(msgbuf, "hangup mode %d: VOICEMODE sent, return code is %d\n",mode,ret);
                logMsg(LEVEL5, msgbuf);

                ret = initModem(SPKRVOL, HANGUPTRY);    /* AT+VGT=128 */
                ret = initModem(audiofmt, HANGUPTRY);   /* AT+VSM=130 */
                ret = initModem(ANSCALL, HANGUPTRY);    /* AT+VLS=1   */
                ret = initModem(NOECHO, HANGUPTRY);     /* Echo Off   */
                ret = initModem(VOICEXFR, HANGUPTRY);   /* AT+VTX     */
                /* send voice file */
                if ((msgfd = open(recording, O_RDONLY)) == -1)
                {
                    sprintf(msgbuf, "%d: %s\n", msgfd, strerror(errno));
                    logMsg(LEVEL1, msgbuf);
                }
                /*
                 * this needs better code for problems
                 * rcnt == BUFSIZ or remaining bytes of file at end
                 */
                sprintf(msgbuf, "Sending file %s, to modem in %d byte chunks\n", recording, BUFSIZ);
                logMsg(LEVEL3, msgbuf);
                do
                {
                    rcnt = read(msgfd, voicebuf, BUFSIZ);
                    if (rcnt > 0 ) wcnt = write(ttyfd, voicebuf, rcnt);
                    tcnt = tcnt + rcnt;
                }
                while (rcnt > 0);
                close(msgfd);
                sprintf(msgbuf, "Sent %d bytes to modem for announcement\n", tcnt);
                logMsg(LEVEL3, msgbuf);
                ret = initModem(DLEETX, HANGUPTRY); /* <DLE><ETX> */
                ret = initModem("ATE1", HANGUPTRY);   /* Echo On */
                ret = initModem(HANGUP, HANGUPTRY);

                /* short delay after announcement, may not be needed */
                hangupdelay = HANGUPDELAY;

            }

            /* off-hook delay for all hangup modes */
            usleep(hangupdelay * 1000000);
            sprintf(msgbuf, "off-hook for %d %s\n", hangupdelay, hangupdelay == 1 ? "second" : "seconds");
            logMsg(LEVEL3, msgbuf);

            /* Hangup the call */
            ret = initModem(HANGUP, HANGUPTRY);
            sprintf(msgbuf, "hangup mode %d: HANGUP sent, return code is %d\n", mode, ret);
                logMsg(LEVEL5, msgbuf);

            /* if Hangup does not indicate OK try 1 more time  */
            if (ret != 0)
            {
                /* Send AT to get modem OK */
                ret = initModem(GETOK, HANGUPTRY);
                sprintf(msgbuf, "hangup mode %d try 2: GETOK sent, return code is %d\n", mode, ret);
                logMsg(LEVEL5, msgbuf);

                /* Send HANGUP to get modem OK */
                ret = initModem(HANGUP, HANGUPTRY);
                sprintf(msgbuf, "hangup mode %d try 2: HANGUP sent, return code is %d\n", mode, ret);
                logMsg(LEVEL5, msgbuf);
            }

            if (mode != 1)    /* FAX or VOICE hangup mode */
            {
                /* set data mode */
                ret = initModem(DATAMODE, HANGUPTRY);
                sprintf(msgbuf, "hangup mode %d: DATAMODE sent, return code is %d\n", mode, ret);
                logMsg(LEVEL5, msgbuf);
            }

            /* take tty port out of raw mode */
            (void) tcsetattr(ttyfd, TCSAFLUSH, &ntty);
        }
    }

    if (ttyflag)
    {
        (void) close(ttyfd);
        ttyfd = 0;
    }

    /* remove TTY port lockfile */
    if (unlink(lockfile))
    {
        sprintf(msgbuf, "Failed to remove stale lockfile: %s\n", lockfile);
        logMsg(LEVEL1, msgbuf);
    }

return ret;
}

/*
 * Compare blacklist or whitelist strings to name and number
 *
 * If "flag" is zero, log a match message
 *   Return = 1  if the number or matches
 *   Return = 0  if no match
 *
 * If "flag" is one, never log a match message
 *   Return = 3  if the number matches
 *   Return = 1  if the name matches
 *   Return = 0  if no match
 */
int onList(char *namep, char *nmbrp, int flag, list_t **listHead)
{
    int ret = 0, i, pos, nbrMatch = 0;
    char msgbuf[BUFSIZ], *ptr, *listptr;
    list_t *node, *nextnode;

    listptr = (listHead == &blkHead ? "Blacklist" : "Whitelist");
    node = *listHead;
    if (!node)
    {
        sprintf(msgbuf, "%s empty\n", listptr);
        logMsg(LEVEL3, msgbuf);
        return ret;
    }
    
    sprintf(msgbuf, "Begin: Search %s file [%s]\n", listptr, strdate(ONLYTIME));
    logMsg(LEVEL4, msgbuf);
        
    for (i = 0; node != 0; i++)
    {
        nextnode = node->next;
        ptr = node->entry;
        pos = i;
        if (regex)
        {
          if (!regexec(&node->preg, namep, 0, NULL, 0)) { ret = 1; break; }
          if (!regexec(&node->preg, nmbrp, 0, NULL, 0)) { ret = 1, nbrMatch = 2; break; }
        }
        else
        {
          if (*namep == '?') ++namep; /* some phone systems do ?<name> */
          if (*ptr == '1')
          {
            if (strncmp(ptr, "1?", 2)) ++ptr;
            if (*nmbrp == '1') ++nmbrp;
          }
          if (*ptr == '^')
          {
            /* must match at start of string */
            ++ptr;
            if (!strncmp(ptr, "1?", 2))
            {
                ptr += 2;
            if (*nmbrp == '1') ++nmbrp;
            }
            if (!strncmp(ptr, namep, strlen(ptr))) { ret = 1; break; }
            if (!strncmp(ptr, nmbrp, strlen(ptr))) { ret = 1, nbrMatch = 2; break; }
          }
          else if (!strncmp(ptr, "1?", 2))
          {
            ptr += 2;
            if (*nmbrp == '1') ++nmbrp;
            if (!strncmp(ptr, nmbrp, strlen(ptr))) { ret = 1, nbrMatch = 2; break; }
          }
          else
          {
            /* can match anywhere in string */
            if (strstr(namep, ptr)) { ret = 1; break; }
            if (strstr(nmbrp, ptr)) { ret = 1; nbrMatch = 2; break; }
          }
        }
        node = nextnode;
    }

    sprintf(msgbuf, "End: Search %s file [%s]\n", listptr, strdate(ONLYTIME));
    logMsg(LEVEL4, msgbuf);
        
    sprintf(msgbuf, "Checked %s for match flag=%d ret=%d nmbrmatch=%d\n",
        listptr, flag, ret, nbrMatch);
    logMsg(LEVEL3, msgbuf);
    if (flag) return (ret + nbrMatch);
    if (ret)
    {
        if (ret) listname = node->newname;
        sprintf(msgbuf, "%s Match #%.2d: %s    number: %s    name: %s\n",
                listptr, pos, ptr, nmbrp, namep);
        logMsg(LEVEL3, msgbuf);
    }

    return ret;
}

/*
 * Check for a name or a number being in the black or white list
 *
 * Return = 0  not on either list
 * Return = 1  name is on the blacklist and not on the whitelist
 * Return = 5  number is on the blacklist and not on the whitelist
 * Return = 2  name is on the whitelist; may or may not be on the blacklist
 * Return = 6  number is on the whitelist; may or may not be on the blacklist
 *
 * Bits 0 and 1:
 *      0 - On neither list
 *      1 - Name or number on blacklist
 *      2 - Name or number on whitelist
 *
 * Bit 2:
 *      0 - Name is on the list
 *      1 - Number is on the list
 */
int onBlackWhite (char *namep, char *nmbrp)
{
    int ret;

    /* ret will be either 0, 1, or 3 */
    if ((ret = onList(namep, nmbrp, 1, &whtHead))) return 2 * ret;
    if ((ret = onList(namep, nmbrp, 1, &blkHead))) return 2 * ret - 1;
    return 0;
}
