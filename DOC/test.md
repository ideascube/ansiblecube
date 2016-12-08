# Tests

The repo is plugged to some [Travis CI](https://travis-ci.org/ideascube/ansiblecube). 

You may want to use the tests localy:

```

$ sudo apt-get install libssl-dev

$ virtualenv ~/.virtualenv/pytest-ansible

$ . ~/.virtualenv/pytest-ansible/bin/activate(pytest-ansible) 

$ cd ~/dev/ansiblecube(pytest-ansible) 

$ pip install -r tests/requirements-dev.txt

```

From now on, you can run the tests against the repo:

```

(pytest-ansible) ~/dev/ansiblecube 

$ py.test[...tests run...]

```

You can even set this tests run as a pre-push git hook, so you cannot push crazy YAML indentation and no invalid Jinja2 templates:

```

~/dev/ansiblecube 

$ cat .git/hooks/pre-push#!/bin/sh${HOME}/.virtualenv/pytest-ansible/bin/py.test

```

