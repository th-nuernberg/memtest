from setuptools import setup

setup(
    name='manage_studykey',
    version='0.1',
    py_modules=['manage_studykey'],
    install_requires=[
        'Click',
    ],
    entry_points='''
        [console_scripts]
        manage-studykey=manage_studykey:manage_studykey
    ''',
)
