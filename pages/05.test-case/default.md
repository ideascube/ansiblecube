# Tests

The repo is plugged in [Travis CI](https://travis-ci.org/ideascube/ansiblecube).

You may want to use the tests locally:

    $ sudo apt-get install libssl-dev
    $ virtualenv ~/.virtualenv/pytest-ansible
    $ . ~/.virtualenv/pytest-ansible/bin/activate
    (pytest-ansible) $ cd ~/dev/ansiblecube
    (pytest-ansible) $ pip install -r tests/requirements-dev.txt

From now on, you can run the tests against the repo:

    (pytest-ansible) ~/dev/ansiblecube $ py.test

You can even set these tests to run as a pre-pushed git hook, so you cannot push crazy YAML indentation and no invalid Jinja2 templates:

    (pytest-ansible) $ cat .git/hooks/pre-push
    #!/bin/sh
    ${HOME}/.virtualenv/pytest-ansible/bin/py.test


