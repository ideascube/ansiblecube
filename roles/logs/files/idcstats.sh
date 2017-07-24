#!/bin/bash

# idcstats -- quick'n'dirty stats from ideascube
# Don't edit this script localy, it will be overwritten by ansiblecube anyway.


#
# conf / vars
#

DB=/var/ideascube/main/default.sqlite



#
# functions
#

# squery -- queries the sqlite database
#   Usage: squery $query
squery() {
    sqlite3 $DB "$@"
}

# sqcount -- counts entries from a table
#   Usage: sqcount $table
sqcount() {
    squery "select count(*) from $1"
}



#
# main
#

users=$(  sqcount ideascube_user )
medias=$( sqcount mediacenter_document )
tags=$(   sqcount taggit_tag )
books=$(  sqcount library_book )
blog=$(   sqcount blog_content )

# send this to syslog - no need of a separated file, use grep/awk/whatever
logger --tag idcstats "$users users, $medias medias, $tags tags, $blog blogposts, $books books"

