import hashlib
import os
import sys
import yaml


CACHE_DIR = sys.argv[1]


with open('kiwix.yml', 'r') as f:
    data = yaml.safe_load(f.read())


new_data = {}


for pkgid, pkgdata in data.items():
    try:
        with open(os.path.join(CACHE_DIR, '%s-0000-00-00' % pkgid), 'rb') as f:
            sha = hashlib.sha256()

            while True:
                b = f.read(8192)

                if not b:
                    break

                sha.update(b)

            new_data[pkgid] = dict(list(pkgdata.items())[:])
            new_data[pkgid]['sha256sum'] = sha.hexdigest()
            new_data[pkgid]['version'] = "0000-00-00"

    except IOError:
        print('Ignoring %s: not found' % pkgid)


with open('catalog.yml', 'w') as f:
    f.write(yaml.safe_dump(new_data, default_flow_style=False))