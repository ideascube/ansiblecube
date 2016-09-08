#!/bin/bash

OLD_PATH=/usr/local/share/kiwix/data

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
        folder_name=`echo $i | cut -d "/" -f3 | cut -d "_" -f1-2 |
        nameWithDate=$new_name-0000-00-00

        index_folder_full_path=`find ./ -type d -name "$folder_name*"`
        index_folder=`find ./ -type d -name "$folder_name*"` -printf '%f\n'

        echo "$new_name" >> $OLD_PATH/list.txt

        mkdir -p $OLD_PATH/packages/$nameWithDate/data/{content,index,library}

        is_several_files=`echo $i | grep zimaa`

        if [ -n $is_several_files ]; then
                cp ${i%?}* $OLD_PATH/packages/$nameWithDate/data/content/
        else
                cp $i $OLD_PATH/packages/$nameWithDate/data/content/
        fi

        if [ -n $index_folder_full_path ]; then
                cp $index_folder_full_path $OLD_PATH/packages/$nameWithDate/data/index

                cd $OLD_PATH/packages/$nameWithDate/data/library/

                /usr/local/bin/kiwix-manage library.xml add ../content/$i -i=../index/$index_folder         
        else
                cd $OLD_PATH/packages/$nameWithDate/data/library/

                /usr/local/bin/kiwix-manage library.xml add ../content/$i
        fi 

        cd $OLD_PATH/packages/$nameWithDate/
        zip -r "$new_name-0000-00-00" data

        mv "$new_name-0000-00-00" /var/cache/ideascube/catalog/packages/$new_name-0000-00-00
        cd $OLD_PATH

done

rm -rf $OLD_PATH/packages