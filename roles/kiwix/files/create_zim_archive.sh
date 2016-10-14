#!/bin/bash

OLD_PATH=/usr/local/share/kiwix/data

apt-get install -y zip

cd $OLD_PATH
mkdir -p $OLD_PATH/packages/
mkdir -p /var/cache/ideascube/catalog/packages

find ./ -type f -regextype posix-extended -regex "^.*zim$|^.*zima{2}" -print0 | while IFS= read -r -d $'\0' i; do

        zim_file=`echo $i | cut -d "/" -f3`

        echo "[+] Create archive for $i"

        new_name=`echo $i | cut -d "/" -f3 | cut -d "_" -f1-2 | sed 's/_/./'`
        folder_name=`echo $i | cut -d "/" -f3 | cut -d "_" -f1-2`
        nameWithDate=$new_name-0000-00-00

        index_folder_full_path=`find ./ -type d -name "$folder_name*"`
        index_folder=`find ./ -type d -name "$folder_name*" -printf '%f\n'`

        echo "$new_name" >> $OLD_PATH/list.txt

        mkdir -p $OLD_PATH/packages/$nameWithDate/data/{content,index,library}

        is_several_files=`echo "$i" | grep zimaa`

        if [ -n "$is_several_files" ]; then
                cp ${i%?}* $OLD_PATH/packages/$nameWithDate/data/content/
        else
                cp $i $OLD_PATH/packages/$nameWithDate/data/content/
        fi

        if [ -n "$index_folder_full_path" ]; then
                cp -r "$index_folder_full_path" $OLD_PATH/packages/$nameWithDate/data/index

                cd $OLD_PATH/packages/$nameWithDate/data/library/

                /usr/local/bin/kiwix-manage $zim_file.xml add ../content/$zim_file -i=../index/$index_folder         
        else
                cd $OLD_PATH/packages/$nameWithDate/data/library/

                /usr/local/bin/kiwix-manage $zim_file.xml add ../content/$zim_file
        fi 

        cd $OLD_PATH/packages/$nameWithDate/
        zip -r "$new_name-0000-00-00" data

        mv "$new_name-0000-00-00" /var/cache/ideascube/catalog/packages/$new_name-0000-00-00
        cd $OLD_PATH
done

rm -rf $OLD_PATH/packages