#!/bin/bash

OLD_PATH=/usr/local/share/kiwix/

ZIM_LIST=`find ./ -type f -regextype posix-extended -regex "^.*zim$|^.*zima{2}"`

if [ -Z $ZIM_LIST ]; then
        exit 0;
fi

cd $OLD_PATH
mkdir -p $OLD_PATH/packages/
mkdir -p /var/cache/ideascube/catalog/packages

echo "[+] Zim list..."
echo "  --> $ZIM_LIST"

for i in $ZIM_LIST
do
        y=0

        echo "[+] Value of this entry $i"
        new_name=`echo $i | cut -d "/" -f3 | cut -d "_" -f1-2 | sed 's/_/./'`
        nameWithDate=$new_name-0000-00-00

        echo "$new_name" >> $OLD_PATH/list.txt

        mkdir -p $OLD_PATH/packages/$nameWithDate/data/{content,index,library}

        $OLD_PATH/kiwix-manage-x86_64 $OLD_PATH/packages/$nameWithDate/data/library/library.xml add $i

        is_several_files=`echo $i | grep zimaa`

        if [ -n $is_several_files ]; then
                cp ${i%?}* $OLD_PATH/packages/$nameWithDate/data/content/
        else
                cp $i $OLD_PATH/packages/$nameWithDate/data/content/
        fi    

        cd $OLD_PATH/packages/$nameWithDate/

        zip -r "$new_name-0000-00-00" data

        mv "$new_name-0000-00-00" /var/cache/ideascube/catalog/packages/$new_name-0000-00-00
        cd $OLD_PATH

done

rm -rf $OLD_PATH/packages