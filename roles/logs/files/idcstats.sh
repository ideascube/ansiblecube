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
staff=$(  squery "select count(*) from ideascube_user where is_staff = 1" )

medias=$( sqcount mediacenter_document )
tags=$(   sqcount taggit_tag )

books=$(  sqcount library_book )

blogposts=$(     sqcount blog_content )
blogdrafts=$(    squery "select count(*) from blog_content where status = 1" )
blogpublished=$( squery "select count(*) from blog_content where status = 2" )
blogdeleted=$(   squery "select count(*) from blog_content where status = 3" )

# send this to syslog - no need of a separated file, use grep/awk/whatever
logger --tag idcstats "$users users, $staff staffs, $medias medias, $tags tags, $blogposts blogposts, $blogdrafts blogdrafts, $blogpublished blogpublished, $blogdeleted blogdeleted, $books books"
