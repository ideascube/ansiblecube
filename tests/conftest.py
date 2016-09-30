import os


def get_roles():
    return sorted(os.listdir('./roles'))


def pytest_generate_tests(metafunc):
    if 'role' in metafunc.fixturenames:
        metafunc.parametrize('role', get_roles())
