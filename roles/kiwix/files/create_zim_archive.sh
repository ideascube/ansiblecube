#!/bin/bash

OLD_PATH=/usr/local/share/kiwix/

cd $OLD_PATH
mkdir -p tmp/

FOLDER=`find ./ -type f -regextype posix-extended -regex "^.*zim$|^.*zima{2}" -printf "%h\n" | uniq | cut -d "/" -f2`

echo "[+] Folder list..."
echo "  --> $FOLDER"

for i in $FOLDER
do
        y=0

        echo "[+] Value of this entry $i"

        LIBRARY_NAME=`find ./ -type f -name "*.xml" |grep "$i"`
        echo "[+] Library name..."
        echo "$LIBRARY_NAME"
        echo "[+] Folder name..."
        echo "$i"

        mkdir -p tmp/$i/data/{content,index,library}

        cp -r $LIBRARY_NAME tmp/$i/data/library
        cp -r $i/* tmp/$i/data/content/

        cd tmp/$i/

        zip -r $i.zip data

        mv $i.zip $OLD_PATH
        cd $OLD_PATH
        rm -rf tmp

        name=`echo $LIBRARY_NAME | cut -d "_" -f1-2 | sed 's/_/./'`
        echo "[+] Library name :  $name"
        title=`echo $LIBRARY_NAME | cut -d "_" -f1`

        sha256sum=`sha256sum $LIBRARY_NAME | cut -d " " -f1`

        echo "local_$name" >> $OLD_PATH/catalog.yml

        for node in version size title language description id
        do
                array[$y]=`xmllint --xpath //@$node $LIBRARY_NAME | cut -d "=" -f2`
                y=`expr $y + 1`
        done

        echo -e "version: ${array[0]}
  size: ${array[1]}
  url: \"$OLD_PATH$i.zip\"
  name: ${array[2]}
  language: ${array[3]}
  description: ${array[4]}
  id: ${array[5]}
  title: \"$title\"
  sha256sum: \"$sha256sum\"
  langid: \"$name\"
  type: zipped-zim
  handler: kiwix\n" >> $OLD_PATH/catalog.yml
done
