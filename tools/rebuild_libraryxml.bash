#!/bin/bash

# Quick'n'dirty script to rebuild the library.xml file



ZIMSPATH=/var/ideascube/kiwix/data/content

[ -x /usr/local/bin/kiwix-manage ] || {
	wget http://filer.bsf-intranet.org/kiwix-manage-$( uname -m ) -O /usr/local/bin/kiwix-manage
	chmod +x /usr/local/bin/kiwix-manage
}



cd $ZIMSPATH

zims="$( ls -1 *.zim )"
zippedzims="$( ls -1 *.zimaa* )"

for i in $zippedzims ; do
	thiszim=${i%.*}
	echo "(re)Add ${thiszim}..."
	/usr/local/bin/kiwix-manage  /var/ideascube/kiwix/library.xml add ${ZIMSPATH}/${thiszim}.zima* --zimPathToSave=${ZIMSPATH}/${thiszim}.zim --indexPath=/var/ideascube/kiwix/data/index/${thiszim}.zim.idx
done
for i in $zims ; do
	echo "(re)Add ${i%.*}..."
	/usr/local/bin/kiwix-manage  /var/ideascube/kiwix/library.xml add ${ZIMSPATH}/${i} --zimPathToSave=${ZIMSPATH}/${i} --indexPath=/var/ideascube/kiwix/data/index/${i}.idx
done

echo "Restart kiwix-server..."
sudo service kiwix-server restart


echo "Done."
