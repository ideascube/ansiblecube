import json

import pytest


def test_json_file(json_file):
    try:
        with open(json_file, mode='rb') as f:
            json.load(f, encoding='utf-8')

    except Exception as e:
        pytest.fail('%s is not valid JSON:\n%s' % (json_file, e))
