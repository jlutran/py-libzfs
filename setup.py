#-
# Copyright (c) 2014 iXsystems, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

import os
import subprocess
from sys import exit
from distutils.core import setup
from Cython.Distutils.extension import Extension
from Cython.Distutils import build_ext


if "ZOL_SRC" not in os.environ:
    print 'Error : the ZOL_SRC env variable is not set'
    exit(1)

try:
    zol_version = subprocess.check_output("modinfo zfs -F version", shell=True).strip().split('-')[0]
    print 'ZOL version detected : %s' % zol_version
except:
    print 'Error : unable to get the ZFS module version'
    exit(1)

system_includes = [
    "/usr/include",
    "${ZOL_SRC}/include",
    "${ZOL_SRC}/lib/libspl/include",
]

system_includes = [os.path.expandvars(x) for x in system_includes]
zol_version = int(zol_version.replace('.', ''))

setup(
    name='libzfs',
    version='1.0',
    cmdclass={'build_ext': build_ext},
    ext_modules=[
        Extension(
            "libzfs",
            ["libzfs.pyx"],
            libraries=["nvpair", "zfs", "zfs_core", "uutil"],
            extra_compile_args=["-DNEED_SOLARIS_BOOLEAN", "-D_XPG6", "-g", "-O0"],
            cython_include_dirs=["./pxd"],
            cython_compile_time_env={'ZOL_VERSION': zol_version},
            include_dirs=system_includes,
            extra_link_args=["-g"],
        )
    ]
)
