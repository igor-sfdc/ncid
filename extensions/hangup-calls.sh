#!/bin/bash

# Last edited: Jul 20, 2016

# Hangup on all calls not in the whitelist.
# Script is not called if caller number or name is in ncidd.whitelist.

# If hangup mode 3 set, it plays either the default recording or the
# recording set in ncidd.conf before it hangs up.
  
# This hangup script is REPLACED whenever NCID is updated.

echo "hangup"
