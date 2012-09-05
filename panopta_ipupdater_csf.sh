#!/bin/bash
##################################################
### Panopta IP Updater for CSF
### This script reads Panopta Node IP list
### from API and updates CSF allow file
### This script should be run in a cron task
###
### Created by Eduardo G. <egrueda@gmail.com>
### Version 1.0.3 2012-08-17
###
### Note: check IGNORE_ALLOW value in csf.conf
##################################################

# File locations
CSFALLOW=/etc/csf/csf.allow

# Binary locations
CAT=`which cat`
CP=`which cp`
RM=`which rm`
SED=`which sed`
WGET=`which wget`
CSF_INITRD=/etc/init.d/csf
LFD_INITRD=/etc/init.d/lfd

##################################################
### Get IP List from API http request
##################################################
IPLIST=`$WGET -qO- https://api.panopta.com/metadata/getMonitoringLocationIPList | $SED 's/ /\n/g'`

##################################################
### Backup current csf.allow
##################################################
$CAT $CSFALLOW > $CSFALLOW.bak
$CP -p $CSFALLOW $CSFALLOW.new

##################################################
### Create new csf.allow
##################################################
$SED '/Panopta/d' $CSFALLOW > $CSFALLOW.new

##################################################
### Write Panopta rules into new csf.allow file
##################################################
echo "" >> $CSFALLOW.new
echo "## Panopta Whitelist Start" >> $CSFALLOW.new
for i in $(echo -e $IPLIST);
do echo "$i # Panopta node" >> $CSFALLOW.new;
done;
echo "## Panopta Whitelist End" >> $CSFALLOW.new

##################################################
### Update csf.allow file
##################################################
$CAT $CSFALLOW.new > $CSFALLOW
$RM -f $CSFALLOW.new

##################################################
### Restart CSF+LFS
##################################################
$CSF_INITRD restart > /dev/null
$LFD_INITRD restart > /dev/null

exit 0