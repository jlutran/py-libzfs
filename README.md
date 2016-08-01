py-libzfs
======

**Python bindings for libzfs**

py-libzfs is a fairly straight-forward set of Python bindings for libzfs for Linux.

**PRE-REQUISITES:**

- [ZFS on Linux](https://zfsonlinux.og) module
- Python2.7 + dev headers (untested with Python 3)
- Python modules : cython, enum34

**INSTALL:**

`git clone https://github.com/zfsonlinux/zfs.git
cd zfs
export ZOL_SRC=$(pwd)
git checkout tags/zfs-$(modinfo zfs -F version | cut -d- -f1)`

`git clone -b linux https://github.com/jlutran/py-libzfs
cd py-libzfs
python setup.py build
sudo -E python setup.py install`

**FEATURES:**

- Access to pools, datasets, snapshots, properties, pool disks
- Many others!

**QUICK HOWTO:**

`import libzfs`

Get a list of pools:

`pools = list(libzfs.ZFS().pools)`

Get help:

`help(libzfs)`


