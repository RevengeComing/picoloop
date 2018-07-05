import os
import pathlib
import re

from sys import platform
from setuptools import Extension, setup
from setuptools.command.build_ext import build_ext as build_ext
from setuptools.command.sdist import sdist as sdist

here = pathlib.Path(__file__).parent
txt = (here / 'picoloop' / '__version__.py').read_text()
version = re.findall(r"^__version__ = '([^']+)'\r?$", txt, re.M)[0]

CFLAGS = ['-O3']
PICOEV_DIR = os.path.join(os.path.dirname(__file__), 'picoev')

if platform.startswith("linux"):
    picoev = os.path.join(PICOEV_DIR, "picoev_epoll.c")
elif platform == "darwin":
    picoev = os.path.join(PICOEV_DIR, "picoev_kqueue.c")
else:
    picoev = os.path.join(PICOEV_DIR, "picoev_select.c")

setup(
    name='picoloop',
    version='0.0.1',
    description='',
    author='Sepehr Hamzehlouy',
    author_email='s.hamzelooy@gmail.com',
    license='MIT',
    url='https://github.com/RevengeComing/picoloop',
    packages=['picoloop'],
    ext_modules=[
        Extension(
            'picoloop.loop',
            [
                "picoloop/loop.c",
                picoev
            ],
            include_dirs=['.']
        )
    ],
    include_package_data=True
)