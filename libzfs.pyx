# cython: c_string_type=unicode, c_string_encoding=ascii
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

import enum
import datetime
import cython
cimport libzfs
cimport zfs
cimport nvpair
from libc.stdint cimport uintptr_t
from libc.string cimport memset, strncpy
from libc.stdlib cimport free


include "nvpair.pxi"


class DatasetType(enum.IntEnum):
    FILESYSTEM = zfs.ZFS_TYPE_FILESYSTEM
    VOLUME = zfs.ZFS_TYPE_VOLUME
    SNAPSHOT = zfs.ZFS_TYPE_SNAPSHOT


class Error(enum.IntEnum):
    SUCCESS = libzfs.EZFS_SUCCESS
    NOMEM = libzfs.EZFS_NOMEM
    BADPROP = libzfs.EZFS_BADPROP
    PROPREADONLY = libzfs.EZFS_PROPREADONLY
    PROPTYPE = libzfs.EZFS_PROPTYPE
    PROPNONINHERIT = libzfs.EZFS_PROPNONINHERIT
    PROPSPACE = libzfs.EZFS_PROPSPACE
    BADTYPE = libzfs.EZFS_BADTYPE
    BUSY = libzfs.EZFS_BUSY
    EXISTS = libzfs.EZFS_EXISTS
    NOENT = libzfs.EZFS_NOENT
    BADSTREAM = libzfs.EZFS_BADSTREAM
    DSREADONLY = libzfs.EZFS_DSREADONLY
    VOLTOOBIG = libzfs.EZFS_VOLTOOBIG
    INVALIDNAME = libzfs.EZFS_INVALIDNAME
    BADRESTORE = libzfs.EZFS_BADRESTORE
    BADBACKUP = libzfs.EZFS_BADBACKUP
    BADTARGET = libzfs.EZFS_BADTARGET
    NODEVICE = libzfs.EZFS_NODEVICE
    BADDEV = libzfs.EZFS_BADDEV
    NOREPLICAS = libzfs.EZFS_NOREPLICAS
    RESILVERING = libzfs.EZFS_RESILVERING
    BADVERSION = libzfs.EZFS_BADVERSION
    POOLUNAVAIL = libzfs.EZFS_POOLUNAVAIL
    DEVOVERFLOW = libzfs.EZFS_DEVOVERFLOW
    BADPATH = libzfs.EZFS_BADPATH
    CROSSTARGET = libzfs.EZFS_CROSSTARGET
    ZONED = libzfs.EZFS_ZONED
    MOUNTFAILED = libzfs.EZFS_MOUNTFAILED
    UMOUNTFAILED = libzfs.EZFS_UMOUNTFAILED
    UNSHARENFSFAILED = libzfs.EZFS_UNSHARENFSFAILED
    SHARENFSFAILED = libzfs.EZFS_SHARENFSFAILED
    PERM = libzfs.EZFS_PERM
    NOSPC = libzfs.EZFS_NOSPC
    FAULT = libzfs.EZFS_FAULT
    IO = libzfs.EZFS_IO
    INTR = libzfs.EZFS_INTR
    ISSPARE = libzfs.EZFS_ISSPARE
    INVALCONFIG = libzfs.EZFS_INVALCONFIG
    RECURSIVE = libzfs.EZFS_RECURSIVE
    NOHISTORY = libzfs.EZFS_NOHISTORY
    POOLPROPS = libzfs.EZFS_POOLPROPS
    POOL_NOTSUP = libzfs.EZFS_POOL_NOTSUP
    INVALARG = libzfs.EZFS_POOL_INVALARG
    NAMETOOLONG = libzfs.EZFS_NAMETOOLONG
    OPENFAILED = libzfs.EZFS_OPENFAILED
    NOCAP = libzfs.EZFS_NOCAP
    LABELFAILED = libzfs.EZFS_LABELFAILED
    BADWHO = libzfs.EZFS_BADWHO
    BADPERM = libzfs.EZFS_BADPERM
    BADPERMSET = libzfs.EZFS_BADPERMSET
    NODELEGATION = libzfs.EZFS_NODELEGATION
    UNSHARESMBFAILED = libzfs.EZFS_UNSHARESMBFAILED
    SHARESMBFAILED = libzfs.EZFS_SHARESMBFAILED
    BADCACHE = libzfs.EZFS_BADCACHE
    ISL2CACHE = libzfs.EZFS_ISL2CACHE
    VDEVNOTSUP = libzfs.EZFS_VDEVNOTSUP
    NOTSUP = libzfs.EZFS_NOTSUP
    SPARE = libzfs.EZFS_ACTIVE_SPARE
    LOGS = libzfs.EZFS_UNPLAYED_LOGS
    RELE = libzfs.EZFS_REFTAG_RELE
    HOLD = libzfs.EZFS_REFTAG_HOLD
    TAGTOOLONG = libzfs.EZFS_TAGTOOLONG
    PIPEFAILED = libzfs.EZFS_PIPEFAILED
    THREADCREATEFAILED = libzfs.EZFS_THREADCREATEFAILED
    ONLINE = libzfs.EZFS_POSTSPLIT_ONLINE
    SCRUBBING = libzfs.EZFS_SCRUBBING
    SCRUB = libzfs.EZFS_NO_SCRUB
    DIFF = libzfs.EZFS_DIFF
    DIFFDATA = libzfs.EZFS_DIFFDATA
    POOLREADONLY = libzfs.EZFS_POOLREADONLY
    UNKNOWN = libzfs.EZFS_UNKNOWN


class PropertySource(enum.IntEnum):
    NONE = zfs.ZPROP_SRC_NONE
    DEFAULT = zfs.ZPROP_SRC_DEFAULT
    TEMPORARY = zfs.ZPROP_SRC_TEMPORARY
    LOCAL = zfs.ZPROP_SRC_LOCAL
    INHERITED = zfs.ZPROP_SRC_INHERITED
    RECEIVED = zfs.ZPROP_SRC_RECEIVED


class VDevState(enum.IntEnum):
    UNKNOWN = zfs.VDEV_STATE_UNKNOWN
    CLOSED = zfs.VDEV_STATE_CLOSED
    OFFLINE = zfs.VDEV_STATE_OFFLINE
    REMOVED = zfs.VDEV_STATE_REMOVED
    CANT_OPEN = zfs.VDEV_STATE_CANT_OPEN
    FAULTED = zfs.VDEV_STATE_FAULTED
    DEGRADED = zfs.VDEV_STATE_DEGRADED
    HEALTHY = zfs.VDEV_STATE_HEALTHY
    
    
class VDevAuxState(enum.IntEnum):
    NONE = zfs.VDEV_AUX_NONE
    OPEN_FAILED = zfs.VDEV_AUX_OPEN_FAILED
    CORRUPT_DATA = zfs.VDEV_AUX_CORRUPT_DATA
    NO_REPLICAS = zfs.VDEV_AUX_NO_REPLICAS
    BAD_GUID_SUM = zfs.VDEV_AUX_BAD_GUID_SUM
    TOO_SMALL = zfs.VDEV_AUX_TOO_SMALL
    BAD_LABEL = zfs.VDEV_AUX_BAD_LABEL
    VERSION_NEWER = zfs.VDEV_AUX_VERSION_NEWER
    VERSION_OLDER = zfs.VDEV_AUX_VERSION_OLDER
    UNSUP_FEAT = zfs.VDEV_AUX_UNSUP_FEAT
    SPARED = zfs.VDEV_AUX_SPARED
    ERR_EXCEEDED = zfs.VDEV_AUX_ERR_EXCEEDED
    IO_FAILURE = zfs.VDEV_AUX_IO_FAILURE
    BAD_LOG = zfs.VDEV_AUX_BAD_LOG
    EXTERNAL = zfs.VDEV_AUX_EXTERNAL
    SPLIT_POOL = zfs.VDEV_AUX_SPLIT_POOL
    #ASHIFT_TOO_BIG = zfs.VDEV_AUX_ASHIFT_TOO_BIG


class PoolState(enum.IntEnum):
    ACTIVE = zfs.POOL_STATE_ACTIVE
    EXPORTED = zfs.POOL_STATE_EXPORTED
    DESTROYED = zfs.POOL_STATE_DESTROYED
    SPARE = zfs.POOL_STATE_SPARE
    L2CACHE = zfs.POOL_STATE_L2CACHE
    UNINITIALIZED = zfs.POOL_STATE_UNINITIALIZED
    UNAVAIL = zfs.POOL_STATE_UNAVAIL
    POTENTIALLY_ACTIVE = zfs.POOL_STATE_POTENTIALLY_ACTIVE


class ScanFunction(enum.IntEnum):
    NONE = zfs.POOL_SCAN_NONE
    SCRUB = zfs.POOL_SCAN_SCRUB
    RESILVER = zfs.POOL_SCAN_RESILVER


class PoolStatus(enum.IntEnum):
    CORRUPT_CACHE = libzfs.ZPOOL_STATUS_CORRUPT_CACHE
    MISSING_DEV_R = libzfs.ZPOOL_STATUS_MISSING_DEV_R
    MISSING_DEV_NR = libzfs.ZPOOL_STATUS_MISSING_DEV_NR
    CORRUPT_LABEL_R = libzfs.ZPOOL_STATUS_CORRUPT_LABEL_R
    CORRUPT_LABEL_NR = libzfs.ZPOOL_STATUS_CORRUPT_LABEL_NR
    BAD_GUID_SUM = libzfs.ZPOOL_STATUS_BAD_GUID_SUM
    CORRUPT_POOL = libzfs.ZPOOL_STATUS_CORRUPT_POOL
    CORRUPT_DATA = libzfs.ZPOOL_STATUS_CORRUPT_DATA
    FAILING_DEV = libzfs.ZPOOL_STATUS_FAILING_DEV
    VERSION_NEWER = libzfs.ZPOOL_STATUS_VERSION_NEWER
    HOSTID_MISMATCH = libzfs.ZPOOL_STATUS_HOSTID_MISMATCH
    IO_FAILURE_WAIT = libzfs.ZPOOL_STATUS_IO_FAILURE_WAIT
    IO_FAILURE_CONTINUE = libzfs.ZPOOL_STATUS_IO_FAILURE_CONTINUE
    BAD_LOG = libzfs.ZPOOL_STATUS_BAD_LOG
    UNSUP_FEAT_READ = libzfs.ZPOOL_STATUS_UNSUP_FEAT_READ
    UNSUP_FEAT_WRITE = libzfs.ZPOOL_STATUS_UNSUP_FEAT_WRITE
    FAULTED_DEV_R = libzfs.ZPOOL_STATUS_FAULTED_DEV_R
    FAULTED_DEV_NR = libzfs.ZPOOL_STATUS_FAULTED_DEV_NR
    VERSION_OLDER = libzfs.ZPOOL_STATUS_VERSION_OLDER
    FEAT_DISABLED = libzfs.ZPOOL_STATUS_FEAT_DISABLED
    RESILVERING = libzfs.ZPOOL_STATUS_RESILVERING
    OFFLINE_DEV = libzfs.ZPOOL_STATUS_OFFLINE_DEV
    REMOVED_DEV = libzfs.ZPOOL_STATUS_REMOVED_DEV
    #NON_NATIVE_ASHIFT = libzfs.ZPOOL_STATUS_NON_NATIVE_ASHIFT
    OK = libzfs.ZPOOL_STATUS_OK


class ScanState(enum.IntEnum):
    NONE = zfs.DSS_NONE
    SCANNING = zfs.DSS_SCANNING
    FINISHED = zfs.DSS_FINISHED
    CANCELED = zfs.DSS_CANCELED
    
    
class ZIOType(enum.IntEnum):
    NONE = zfs.ZIO_TYPE_NULL
    READ = zfs.ZIO_TYPE_READ
    WRITE = zfs.ZIO_TYPE_WRITE
    FREE = zfs.ZIO_TYPE_FREE
    CLAIM = zfs.ZIO_TYPE_CLAIM
    IOCTL = zfs.ZIO_TYPE_IOCTL


class FeatureState(enum.Enum):
    DISABLED = 0
    ENABLED = 1
    ACTIVE = 2


class SendFlag(enum.Enum):
    VERBOSE = 0
    REPLICATE = 1
    DOALL = 2
    FROMORIGIN = 3
    DEDUP = 3
    PROPS = 4
    DRYRUN = 5
    PARSABLE = 6
    PROGRESS = 7
    LARGEBLOCK = 8
    EMBED_DATA = 9


IF ZOL_VERSION >= 640:
    class SendFlags(enum.IntEnum):
        EMBED_DATA = libzfs.LZC_SEND_FLAG_EMBED_DATA


class ZFSException(RuntimeError):
    def __init__(self, code, message):
        super(ZFSException, self).__init__(message)
        self.code = code


cdef class ZFS(object):
    cdef libzfs.libzfs_handle_t* handle
    cdef int history
    cdef char *history_prefix

    def __cinit__(self, history=False, history_prefix=''):
        self.handle = libzfs.libzfs_init()
        if isinstance(history, bool):
            self.history = history
        else:
            raise ZFSException(Error.BADTYPE, 'history is a boolean parameter')

        if self.history:
            if isinstance(history_prefix, str):
                self.history_prefix = history_prefix
            else:
                raise ZFSException(Error.BADTYPE, 'history_prefix is a string parameter')

    def __dealloc__(self):
        libzfs.libzfs_fini(self.handle)

    def __getstate__(self):
        return [p.__getstate__() for p in self.pools]

    @staticmethod
    cdef int __iterate_pools(libzfs.zpool_handle_t *handle, void *arg) nogil:
        with gil:
            pools = <object>arg
            pools.append(<uintptr_t>handle)

    cdef object get_error(self):
        return ZFSException(
            Error(libzfs.libzfs_errno(self.handle)),
            libzfs.libzfs_error_description(self.handle)
        )

    cdef ZFSVdev make_vdev_tree(self, topology):
        cdef ZFSVdev root
        root = ZFSVdev(self, 'root')
        root.children = topology.get('data', [])

        if 'cache' in topology:
            root.nvlist['l2cache'] = [(<ZFSVdev>i).nvlist for i in topology['cache']]

        if 'spare' in topology:
            root.nvlist['spares'] = [(<ZFSVdev>i).nvlist for i in topology['spare']]

        if 'log' in topology:
            for i in topology['log']:
                (<ZFSVdev>i).nvlist['is_log'] = 1L
                root.add_child_vdev(i)

        return root

    property errno:
        def __get__(self):
            return Error(libzfs.libzfs_errno(self.handle))

    property errstr:
        def __get__(self):
            return libzfs.libzfs_error_description(self.handle)

    property pools:
        def __get__(self):
            cdef ZFSPool pool

            pools = []
            libzfs.zpool_iter(self.handle, self.__iterate_pools, <void*>pools)

            for h in pools:
                pool = ZFSPool.__new__(ZFSPool)
                pool.root = self
                pool.handle = <libzfs.zpool_handle_t*><uintptr_t>h
                if pool.name == '$import':
                    continue


                yield pool

    property datasets:
        def __get__(self):
            for p in self.pools:
                try:
                    yield p.root_dataset
                    for c in p.root_dataset.children_recursive:
                        yield c
                except ZFSException:
                    continue

    property snapshots:
        def __get__(self):
            for p in self.pools:
                try:
                    for c in p.root_dataset.snapshots_recursive:
                        yield c
                except ZFSException:
                    continue

    def get(self, name):
        cdef libzfs.zpool_handle_t* handle = libzfs.zpool_open_canfail(self.handle, name)
        cdef ZFSPool pool

        if handle == NULL:
            raise ZFSException(Error.NOENT, 'Pool {0} not found'.format(name))

        pool = ZFSPool.__new__(ZFSPool)
        pool.root = self
        pool.handle = handle
        return pool

    def find_import(self, cachefile=None):
        cdef ZFSImportablePool pool
        cdef libzfs.importargs_t iargs
        cdef char* paths = "/dev"
        cdef nvpair.nvlist_t* result

        iargs.path = &paths
        iargs.paths = 1
        iargs.poolname = NULL
        iargs.guid = 0
        iargs.cachefile = NULL

        if cachefile:
            iargs.cachefile = cachefile

        with nogil:
            result = libzfs.zpool_search_import(self.handle, &iargs)

        if result is NULL:
            return

        nv = NVList(nvlist=<uintptr_t>result)
        for name, config in nv.items(raw=True):
            pool = ZFSImportablePool.__new__(ZFSImportablePool)
            pool.name = name
            pool.free = False
            pool.nvlist = config
            yield pool

    def import_pool(self, ZFSImportablePool pool, newname, opts):
        cdef const char *command = 'zpool import'
        cdef NVList copts = NVList(otherdict=opts)

        if libzfs.zpool_import_props(
            self.handle,
            pool.nvlist.handle,
            newname,
            copts.handle,
            False
        ) != 0:
            raise self.get_error()
        self.write_history(command, str(pool.guid), newname if newname else pool.name)

    def export_pool(self, ZFSPool pool):
        cdef const char *command = 'zpool export'
        if libzfs.zpool_disable_datasets(pool.handle, True) != 0:
            raise self.get_error()

        if libzfs.zpool_export(pool.handle, True, "export") != 0:
            raise self.get_error()
        self.write_history(command, str(pool.name))

    def get_dataset(self, name):
        cdef libzfs.zfs_handle_t* handle = libzfs.zfs_open(self.handle, name, zfs.ZFS_TYPE_FILESYSTEM|zfs.ZFS_TYPE_VOLUME)
        cdef ZFSPool pool
        cdef ZFSDataset dataset
        if handle == NULL:
            raise ZFSException(Error.NOENT, 'Dataset {0} not found'.format(name))

        pool = ZFSPool.__new__(ZFSPool)
        pool.root = self
        pool.free = False
        pool.handle = libzfs.zfs_get_pool_handle(handle)
        dataset = ZFSDataset.__new__(ZFSDataset)
        dataset.root = self
        dataset.pool = pool
        dataset.handle = handle
        return dataset

    def get_snapshot(self, name):
        cdef libzfs.zfs_handle_t* handle = libzfs.zfs_open(self.handle, name, zfs.ZFS_TYPE_SNAPSHOT)
        cdef ZFSPool pool
        cdef ZFSSnapshot snap
        if handle == NULL:
            raise ZFSException(Error.NOENT, 'Snapshot {0} not found'.format(name))

        pool = ZFSPool.__new__(ZFSPool)
        pool.root = self
        pool.free = False
        pool.handle = libzfs.zfs_get_pool_handle(handle)
        snap = ZFSSnapshot.__new__(ZFSSnapshot)
        snap.root = self
        snap.pool = pool
        snap.handle = handle
        return snap

    def get_object(self, name):
        try:
            return self.get_dataset(name)
        except ZFSException, err:
            if err.code == Error.NOENT:
                return self.get_snapshot(name)

            raise err

    def create(self, name, topology, opts, fsopts):
        cdef NVList root = self.make_vdev_tree(topology).nvlist
        cdef NVList copts = NVList(otherdict=opts)
        cdef NVList cfsopts = NVList(otherdict=fsopts)
        cdef const char *command = 'zpool create'

        if libzfs.zpool_create(
            self.handle,
            name,
            root.handle,
            copts.handle,
            cfsopts.handle) != 0:
            raise ZFSException(self.errno, self.errstr)

        if self.history:
            hopts = self.generate_history_opts(opts, '-o')
            hfsopts = self.generate_history_opts(fsopts, '-O')
            self.write_history(
                command,
                hopts,
                hfsopts,
                name,
                self.history_vdevs_list(topology)
            )

        return self.get(name)

    def destroy(self, name):
        cdef libzfs.zpool_handle_t* handle = libzfs.zpool_open(self.handle, name)
        if handle == NULL:
            raise ZFSException(Error.NOENT, 'Pool {0} not found'.format(name))

        if libzfs.zpool_destroy(handle, "destroy") != 0:
            raise ZFSException(self.errno, self.errstr)

    def receive(self, name, fd, force=False, nomount=False, resumable=False, props=None, limitds=None):
        cdef libzfs.libzfs_handle_t *handle = self.handle,
        cdef libzfs.recvflags_t flags;
        cdef NVList props_nvl = None
        cdef NVList limitds_nvl = None

        memset(&flags, 0, sizeof(libzfs.recvflags_t))

        if force:
            flags.force = True

        if nomount:
            flags.nomount = True

        # Zfs recv should prefetch indirect blocks (IllumOS #5960)
        # https://github.com/zfsonlinux/zfs/commit/fcff0f35bd522076bdda7491c88a91cc0aa531a3
        #
        #IF ZOL_VERSION >= XXX:
        #    if resumable:
        #        flags.resumable = True

        #IF ZOL_VERSION >= XXX:
        #    if props:
        #        props_nvl = NVList(otherdict=props)
        #    if libzfs.zfs_receive(handle, name, props_nvl.handle if props_nvl else NULL,
        #        &flags, fd, NULL) != 0:
        #        raise self.get_error()
        #ELSE:
        if libzfs.zfs_receive(handle, name, &flags, fd, NULL) != 0:
            raise self.get_error()

    def write_history(self, *args):
        history_message = ""

        def eval_arg(argument):
            if isinstance(argument, str):
                return eval_str(argument)
            if isinstance(argument, dict):
                return eval_dict(argument)
            if isinstance(argument, tuple):
                return eval_tuple(argument)
            if isinstance(argument, list):
                return eval_list(argument)
            if isinstance(argument, ZFSVdev):
                return eval_zfsvdev(argument)

        def eval_str(argument):
            return " " + argument

        def eval_dict(argument):
            out = ""
            for tup in arg.items():
                out += eval_arg(tup)
            return out

        def eval_tuple(argument):
            if len(argument) == 2:
                if isinstance(argument[1], str):
                    return " " + str(argument[0]) + '=' + str(argument[1])

            out = ""
            for i in argument:
                out += eval_arg(i)
            return out

        def eval_list(argument):
            out = ""
            for i in argument:
                out += eval_arg(i)
            return out

        def eval_zfsvdev(argument):
            disks = argument.disks
            if len(disks):
                out = " " + str(argument.type)
                for disk in disks:
                    out += " " + disk
                return  out
            else:
                return ""

        if self.history:
            history_message = self.history_prefix
            for arg in args:
                history_message += eval_arg(arg)

            libzfs.zpool_log_history(self.handle, history_message)

    def generate_history_opts(self, opt_dict, prefix):
        keys = []
        out_dict = {}
        if isinstance(opt_dict, dict):
            for key in opt_dict.keys():
                keys.append(key)

            for key in keys:
                out_dict[prefix + ' ' + key] = opt_dict[key]

        return out_dict

    def history_vdevs_list(self, topology):
        out = []
        if self.history:
            data_vdevs = topology.get('data', None)
            if data_vdevs:
                if data_vdevs[0].type == 'disk':
                    data_vdevs = data_vdevs[0].disks[0]

                out.append(data_vdevs)

            if topology.get('cache', False):
                out.append('cache')
                out.append(topology.get('cache'))

            if topology.get('log', False):
                out.append('log')
                out.append(topology.get('log'))

        return out

    # Resumable send/recv (OpenZFS #2605)
    # https://github.com/zfsonlinux/zfs/commit/47dfff3b86c67c6ae184c2b7166eaa529590c2d2
    #
    #IF ZOL_VERSION >= XXX:
    #    def send_resume(self, fd, token, flags=None):
    #        cdef libzfs.sendflags_t cflags

    #        memset(&cflags, 0, cython.sizeof(libzfs.sendflags_t))

    #        if flags:
    #            convert_sendflags(flags, &cflags)

    #        if libzfs.zfs_send_resume(self.handle, &cflags, fd, token) != 0:
    #            raise ZFSException(self.errno, self.errstr)

    #    def describe_resume_token(self, token):
    #        cdef nvpair.nvlist_t *nvl

    #        nvl = libzfs.zfs_send_resume_token_to_nvlist(self.handle, token)
    #        if nvl == NULL:
    #            raise ZFSException(self.errno, self.errstr)

    #        return dict(NVList(<uintptr_t>nvl))


cdef class ZPoolProperty(object):
    cdef int propid
    cdef readonly ZFSPool pool

    def __init__(self):
        raise RuntimeError('ZPoolProperty cannot be instantiated by the user')

    def __getstate__(self):
        return {
            'value': self.value,
            'rawvalue': self.rawvalue,
            'source': self.source.name
        }

    def __str__(self):
        return "<libzfs.ZPoolProperty name '{0}' value '{1}'>".format(self.name, self.value)

    def __repr__(self):
        return str(self)

    property name:
        def __get__(self):
            return libzfs.zpool_prop_to_name(self.propid)

    property value:
        def __get__(self):
            cdef char cstr[libzfs.ZPOOL_MAXPROPLEN]
            if libzfs.zpool_get_prop(self.pool.handle, self.propid, cstr, sizeof(cstr), NULL) != 0:
                return '-'

            return cstr

        def __set__(self, value):
            cdef const char *command = 'zpool set'
            if libzfs.zpool_set_prop(self.pool.handle, self.name, value) != 0:
                raise self.pool.root.get_error()
            self.pool.root.write_history(command, (self.name, str(value)), self.pool.name)

    property rawvalue:
        def __get__(self):
            cdef char cstr[libzfs.ZPOOL_MAXPROPLEN]
            if libzfs.zpool_get_prop(self.pool.handle, self.propid, cstr, sizeof(cstr), NULL) != 0:
                return '-'

            return cstr

    property source:
        def __get__(self):
            cdef zfs.zprop_source_t src
            libzfs.zpool_get_prop(self.pool.handle, self.propid, NULL, 0, &src)
            return PropertySource(src)

    property allowed_values:
        def __get__(self):
            return libzfs.zfs_prop_values(self.propid)

    def reset(self):
        pass


cdef class ZPoolFeature(object):
    cdef readonly ZFSPool pool
    cdef NVList nvlist
    cdef zfs.zfeature_info_t *feature

    def __getstate__(self):
        return {
            'name': self.name,
            'guid': self.guid,
            'description': self.description,
            'state': self.state.name
        }

    property name:
        def __get__(self):
            return self.feature.fi_uname

    property guid:
        def __get__(self):
            return self.feature.fi_guid

    property description:
        def __get__(self):
            return self.feature.fi_desc

    property state:
        def __get__(self):
            if self.guid not in self.nvlist:
                return FeatureState.DISABLED

            if self.nvlist[self.guid] == 0:
                return FeatureState.ENABLED

            if self.nvlist[self.guid] > 0:
                return FeatureState.ACTIVE

    def enable(self):
        cdef const char *command = 'zpool set'
        name = "feature@{0}".format(self.name)
        if libzfs.zpool_set_prop(self.pool.handle, name, "enabled") != 0:
            raise self.pool.root.get_error()
        self.pool.root.write_history(command, (self.name, 'enabled'), self.pool.name)


cdef class ZFSProperty(object):
    cdef readonly ZFSDataset dataset
    cdef int propid

    def __init__(self):
        raise RuntimeError('ZFSProperty cannot be instantiated by the user')

    def __getstate__(self):
        return {
            'value': self.value,
            'rawvalue': self.rawvalue,
            'source': self.source.name if self.source else None
        }

    def __str__(self):
        return "<libzfs.ZFSProperty name '{0}' value '{1}'>".format(self.name, self.value)

    def __repr__(self):
        return str(self)

    property name:
        def __get__(self):
            return libzfs.zfs_prop_to_name(self.propid)

    property value:
        def __get__(self):
            cdef char cstr[1024]

            if libzfs.zfs_prop_get(self.dataset.handle, self.propid, cstr, 1023, NULL, NULL, 0, False) != 0:
                return None

            return cstr

        def __set__(self, value):
            cdef const char *command = 'zfs set'
            if libzfs.zfs_prop_set(self.dataset.handle, self.name, str(value)) != 0:
                raise self.dataset.root.get_error()
            self.dataset.root.write_history(command, (self.name, str(value)), self.dataset.name)

    property rawvalue:
        def __get__(self):
            cdef char cstr[1024]
            if libzfs.zfs_prop_get(self.dataset.handle, self.propid, cstr, 1023, NULL, NULL, 0, True) != 0:
                return None

            return cstr

    property source:
        def __get__(self):
            cdef char val[1024]
            cdef char cstr[256]
            cdef zfs.zprop_source_t source
            if libzfs.zfs_prop_get(self.dataset.handle, self.propid, val, 1023, &source, cstr, 255, True) != 0:
                return None

            return PropertySource(<int>source)

    property allowed_values:
        def __get__(self):
            return libzfs.zfs_prop_values(self.propid)

    def inherit(self, recursive=False, received=False):
        cdef const char *command = 'zfs inherit'
        cdef ZFSDataset dset

        dsets = [self.dataset]
        if recursive:
            dsets = dsets.extend(list(self.dataset.children_recursive))

        for d in dsets:
            dset = <ZFSDataset>d
            if libzfs.zfs_prop_inherit(dset.handle, self.name, received) != 0:
                raise self.dataset.root.get_error()

        self.dataset.root.write_history(command, '-r' if recursive else '', self.dataset.name)


cdef class ZFSUserProperty(ZFSProperty):
    cdef dict values
    cdef readonly name

    def __init__(self, value):
        self.values = {"value": value}

    def __str__(self):
        return "<libzfs.ZFSUserProperty name '{0}' value '{1}'>".format(self.name, self.value)

    def __repr__(self):
        return str(self)

    property value:
        def __get__(self):
            return self.values.get('value')

        def __set__(self, value):
            if self.dataset:
                if libzfs.zfs_prop_set(self.dataset.handle, self.name, str(value)) != 0:
                    raise self.dataset.root.get_error()

    property rawvalue:
        def __get__(self):
            return self.value

    property source:
        def __get__(self):
            src = self.values.get('source')
            if not src:
                return None

            if src == self.dataset.name:
                return PropertySource.LOCAL

            if src == '$recvd':
                return PropertySource.RECEIVED

            return PropertySource.INHERITED


cdef class ZFSVdevStats(object):
    cdef NVList nvlist

    def __getstate__(self):
        return {
            'timestamp': self.timestamp,
            'read_errors': self.read_errors,
            'write_errors': self.write_errors,
            'checksum_errors': self.checksum_errors,
            'ops': self.ops,
            'bytes': self.bytes,
            'size': self.size,
            'allocated': self.allocated,
            'configured_ashift': self.configured_ashift,
            'logical_ashift': self.logical_ashift,
            'physical_ashift': self.physical_ashift,
            'fragmentation': self.fragmentation
        }

    property timestamp:
        def __get__(self):
            return self.nvlist['vdev_stats'][0]

    property size:
        def __get__(self):
            return self.nvlist['vdev_stats'][4]

    property allocated:
        def __get__(self):
            return self.nvlist['vdev_stats'][3]

    property read_errors:
        def __get__(self):
            return self.nvlist['vdev_stats'][21]

    property write_errors:
        def __get__(self):
            return self.nvlist['vdev_stats'][22]

    property checksum_errors:
        def __get__(self):
            return self.nvlist['vdev_stats'][23]

    property ops:
        def __get__(self):
            return self.nvlist['vdev_stats'][8:13]

    property bytes:
        def __get__(self):
            return self.nvlist['vdev_stats'][14:19]

    property configured_ashift:
        def __get__(self):
            return self.nvlist['vdev_stats'][26]

    property logical_ashift:
        def __get__(self):
            return self.nvlist['vdev_stats'][27]

    property physical_ashift:
        def __get__(self):
            return self.nvlist['vdev_stats'][28]

    property fragmentation:
        def __get__(self):
            return self.nvlist['vdev_stats'][29]


cdef class ZFSVdev(object):
    cdef readonly ZFSPool zpool
    cdef readonly ZFS root
    cdef readonly ZFSVdev parent
    cdef readonly object group
    cdef NVList nvlist

    def __init__(self, ZFS root, typ, ZFSPool pool=None):
        self.root = root
        self.zpool = pool
        self.nvlist = NVList()
        self.type = typ

    def __str__(self):
        if self.path:
            return "<libzfs.ZFSVdev type '{0}', path '{1}'>".format(self.type, self.path)

        return "<libzfs.ZFSVdev type '{0}'>".format(self.type)

    def __repr__(self):
        return str(self)

    def __getstate__(self, recursive=True):
        ret = {
            'type': self.type,
            'path': self.path,
            'guid': str(self.guid),
            'status': self.status,
            'stats': self.stats.__getstate__()
        }

        if recursive:
            ret['children'] = [i.__getstate__() for i in self.children]

        return ret

    def add_child_vdev(self, ZFSVdev vdev):
        if 'children' not in self.nvlist:
            self.nvlist.set('children', [], nvpair.DATA_TYPE_NVLIST_ARRAY)

        self.nvlist['children'] = self.nvlist.get_raw('children') + [vdev.nvlist]

    def attach(self, ZFSVdev vdev):
        cdef const char *command = 'zpool attach'
        cdef ZFSVdev root

        if self.type not in ('mirror', 'disk', 'file'):
            raise ZFSException(Error.NOTSUP, "Can attach disks to mirrors and stripes only")

        if self.type == 'mirror':
            first_child = next(self.children)
        else:
            first_child = self

        root = self.root.make_vdev_tree({
            'data': [vdev]
        })

        if libzfs.zpool_vdev_attach(
            self.zpool.handle,
            first_child.path,
            vdev.path,
            root.nvlist.handle,
            False) != 0:
            raise self.root.get_error()

        self.root.write_history(command, self.zpool.name, first_child.path, vdev.path)

    def replace(self, ZFSVdev vdev):
        cdef const char *command = 'zpool replace'
        cdef ZFSVdev root

        if self.type == 'file':
            raise ZFSException(Error.NOTSUP, "Can replace disks only")

        if self.parent.type != 'mirror':
            raise ZFSException(Error.NOTSUP, "Can replace disks in mirrors only")

        root = self.root.make_vdev_tree({
            'data': [vdev]
        })

        if libzfs.zpool_vdev_attach(
            self.zpool.handle,
            self.path,
            vdev.path,
            root.nvlist.handle,
            True) != 0:
            raise self.root.get_error()

        self.root.write_history(command, self.zpool.name, self.path, vdev.path)

    def detach(self):
        cdef const char *command = 'zpool detach'
        if self.type not in ('file', 'disk'):
            raise ZFSException(Error.NOTSUP, "Cannot detach virtual vdevs")

        if self.parent.type != 'mirror':
            raise ZFSException(Error.NOTSUP, "Can detach disks from mirrors only")

        if libzfs.zpool_vdev_detach(self.zpool.handle, self.path) != 0:
            raise self.root.get_error()

        self.root.write_history(command, self.zpool.name, self.path)

    def remove(self):
        cdef const char *command = 'zpool remove'

        if libzfs.zpool_vdev_remove(self.zpool.handle, self.path):
            raise self.root.get_error()

        self.root.write_history(command, self.zpool.name, self.path)

    def offline(self, temporary=False):
        cdef const char *command = 'zpool offline'
        if self.type not in ('disk', 'file'):
            raise ZFSException(Error.NOTSUP, "Can make disks offline only")

        if libzfs.zpool_vdev_offline(self.zpool.handle, self.path, temporary) != 0:
            raise self.root.get_error()

        self.root.write_history(command, '-t' if temporary else '',self.zpool.name, self.path)

    def online(self, expand=False):
        cdef const char *command = 'zpool online'
        cdef int flags = 0
        cdef zfs.vdev_state_t newstate

        if self.type not in ('disk', 'file'):
            raise ZFSException(Error.NOTSUP, "Can make disks online only")

        if expand:
            flags |= zfs.ZFS_ONLINE_EXPAND

        if libzfs.zpool_vdev_online(self.zpool.handle, self.path, flags, &newstate) != 0:
            raise self.root.get_error()

        self.root.write_history(command, '-e' if expand else '',self.zpool.name, self.path)

    def degrade(self, aux):
        if libzfs.zpool_vdev_degrade(self.zpool.handle, self.guid, int(aux)):
            raise self.root.get_error()

    def fault(self, aux):
        if libzfs.zpool_vdev_fault(self.zpool.handle, self.guid, int(aux)):
            raise self.root.get_error()

    property type:
        def __get__(self):
            value = self.nvlist.get('type')
            if value == 'raidz':
                return value + str(self.nvlist.get('nparity'))

            return value

        def __set__(self, value):
            if value not in ('root', 'disk', 'file', 'raidz1', 'raidz2', 'raidz3', 'mirror'):
                raise ValueError('Invalid vdev type')

            self.nvlist['type'] = value

            if value.startswith('raidz'):
                self.nvlist['type'] = 'raidz'
                self.nvlist['nparity'] = long(value[-1])

    property guid:
        def __get__(self):
            return self.nvlist.get('guid')

    property path:
        def __get__(self):
            return self.nvlist.get('path')

        def __set__(self, value):
            self.nvlist['path'] = value

    property status:
        def __get__(self):
            stats = self.nvlist['vdev_stats']
            return libzfs.zpool_state_to_name(stats[1], stats[2])

    property size:
        def __get__(self):
            return self.nvlist['asize'] << self.nvlist['ashift']

    property stats:
        def __get__(self):
            cdef ZFSVdevStats ret

            ret = ZFSVdevStats.__new__(ZFSVdevStats)
            ret.nvlist = self.nvlist
            return ret

    property children:
        def __get__(self):
            cdef ZFSVdev vdev

            if 'children' not in self.nvlist:
                return

            for i in self.nvlist.get_raw('children'):
                vdev = ZFSVdev.__new__(ZFSVdev)
                vdev.nvlist = i
                vdev.zpool = self.zpool
                vdev.root = self.root
                vdev.parent = self
                yield vdev

        def __set__(self, value):
            self.nvlist['children'] = [(<ZFSVdev>i).nvlist for i in value]

    property disks:
        def __get__(self):
            if self.type == 'disk':
                return [self.path]
            elif self.type == 'file':
                return []
            else:
                result = []
                for i in self.children:
                    result += i.disks

                return result


cdef class ZPoolScrub(object):
    cdef readonly ZFS root
    cdef readonly ZFSPool pool
    cdef readonly object stat

    def __init__(self, ZFS root, ZFSPool pool):
        self.root = root
        self.pool = pool
        self.stat = None
        if 'scan_stats' in pool.config['vdev_tree']:
            self.stat = pool.config['vdev_tree']['scan_stats']

    property state:
        def __get__(self):
            if not self.stat:
                return None

            return ScanState(self.stat[1])

    property function:
        def __get__(self):
            if not self.stat:
                return None

            return ScanFunction(self.stat[0])

    property start_time:
        def __get__(self):
            if not self.stat:
                return None

            return datetime.datetime.fromtimestamp(self.stat[2])

    property end_time:
        def __get__(self):
            if not self.stat:
                return None

            return datetime.datetime.fromtimestamp(self.stat[3])

    property bytes_to_scan:
        def __get__(self):
            if not self.stat:
                return None

            return self.stat[4]

    property bytes_scanned:
        def __get__(self):
            if not self.stat:
                return None

            return self.stat[5]

    property errors:
        def __get__(self):
            if not self.stat:
                return None

            return self.stat[8]

    property percentage:
        def __get__(self):
            if not self.stat:
                return None

            if not self.bytes_to_scan:
                return 0

            return (<float>self.bytes_scanned / <float>self.bytes_to_scan) * 100

    def __getstate__(self):
        return {
            'function': self.function.name if self.function else None,
            'state': self.state.name if self.stat else None,
            'start_time': self.start_time,
            'end_time': self.end_time,
            'percentage': self.percentage,
            'bytes_to_process': self.bytes_scanned,
            'bytes_processed': self.bytes_to_scan,
            'errors': self.errors
        }


cdef class ZFSPool(object):
    cdef libzfs.zpool_handle_t* handle
    cdef bint free
    cdef readonly ZFS root

    def __cinit__(self):
        self.free = True

    def __init__(self):
        raise RuntimeError('ZFSPool cannot be instantiated by the user')

    def __dealloc__(self):
        if self.free:
            libzfs.zpool_close(self.handle)
            self.handle = NULL

    def __str__(self):
        return "<libzfs.ZFSPool name '{0}' guid '{1}'>".format(self.name, self.guid)

    def __repr__(self):
        return str(self)

    def __getstate__(self, datasets_recursive=True):
        try:
            root_ds = self.root_dataset.__getstate__(datasets_recursive)
        except (ZFSException, AttributeError):
            root_ds = None

        return {
            'name': self.name,
            'id': self.name,
            'guid': str(self.guid),
            'hostname': self.hostname,
            'status': self.status,
            'error_count': self.error_count,
            'root_dataset': root_ds,
            'properties': {k: p.__getstate__() for k, p in self.properties.items()} if self.properties else None,
            'features': [i.__getstate__() for i in self.features] if self.features else None,
            'scan': self.scrub.__getstate__(),
            'root_vdev': self.root_vdev.__getstate__(False),
            'groups': {
                'data': [i.__getstate__() for i in self.data_vdevs],
                'log': [i.__getstate__() for i in self.log_vdevs],
                'cache': [i.__getstate__() for i in self.cache_vdevs],
                'spare': [i.__getstate__() for i in self.spare_vdevs]
            },
        }

    @staticmethod
    cdef int __iterate_props(int proptype, void* arg) nogil:
        with gil:
            proptypes = <object>arg
            proptypes.append(proptype)
            return zfs.ZPROP_CONT

    property root_dataset:
        def __get__(self):
            cdef ZFSDataset dataset
            cdef libzfs.zfs_handle_t* handle

            handle = libzfs.zfs_open(
                self.root.handle,
                self.name,
                zfs.ZFS_TYPE_FILESYSTEM
            )

            if handle == NULL:
                raise ZFSException(Error.OPENFAILED, 'Cannot open root dataset')

            dataset = ZFSDataset.__new__(ZFSDataset)
            dataset.root = self.root
            dataset.pool = self
            dataset.handle = handle
            return dataset

    property root_vdev:
        def __get__(self):
            cdef ZFSVdev vdev
            cdef NVList vdev_tree = self.get_raw_config().get_raw('vdev_tree')

            vdev = ZFSVdev.__new__(ZFSVdev)
            vdev.root = self.root
            vdev.zpool = self
            vdev.nvlist = <NVList>vdev_tree
            return vdev

    property data_vdevs:
        def __get__(self):
            cdef ZFSVdev vdev
            cdef NVList vdev_tree = self.get_raw_config().get_raw('vdev_tree')

            if 'children' not in vdev_tree:
                return

            for child in vdev_tree.get_raw('children'):
                if not child['is_log']:
                    vdev = ZFSVdev.__new__(ZFSVdev)
                    vdev.root = self.root
                    vdev.zpool = self
                    vdev.nvlist = <NVList>child
                    vdev.group = 'data'
                    yield vdev

    property log_vdevs:
        def __get__(self):
            cdef ZFSVdev vdev
            cdef NVList vdev_tree = self.get_raw_config().get_raw('vdev_tree')

            if 'children' not in vdev_tree:
                return

            for child in vdev_tree.get_raw('children'):
                if child['is_log']:
                    vdev = ZFSVdev.__new__(ZFSVdev)
                    vdev.root = self.root
                    vdev.zpool = self
                    vdev.nvlist = <NVList>child
                    vdev.group = 'log'
                    yield vdev

    property cache_vdevs:
        def __get__(self):
            cdef ZFSVdev vdev
            cdef NVList vdev_tree = self.get_raw_config().get_raw('vdev_tree')

            if 'l2cache' not in vdev_tree:
                return

            for child in vdev_tree.get_raw('l2cache'):
                    vdev = ZFSVdev.__new__(ZFSVdev)
                    vdev.root = self.root
                    vdev.zpool = self
                    vdev.nvlist = <NVList>child
                    vdev.group = 'cache'
                    yield vdev

    property spare_vdevs:
        def __get__(self):
            cdef ZFSVdev vdev
            cdef NVList vdev_tree = self.get_raw_config().get_raw('vdev_tree')

            if 'spares' not in vdev_tree:
                return

            for child in vdev_tree.get_raw('spares'):
                    vdev = ZFSVdev.__new__(ZFSVdev)
                    vdev.root = self.root
                    vdev.zpool = self
                    vdev.nvlist = <NVList>child
                    vdev.group = 'spare'
                    yield vdev

    property groups:
        def __get__(self):
            return {
                'data': list(self.data_vdevs),
                'log': list(self.log_vdevs),
                'cache': list(self.cache_vdevs),
                'spare': list(self.spare_vdevs)
            }

    property name:
        def __get__(self):
            return libzfs.zpool_get_name(self.handle)

    property guid:
        def __get__(self):
            return self.config['pool_guid']

    property hostname:
        def __get__(self):
            return self.config.get('hostname')

    property status:
        def __get__(self):
            stats = self.config['vdev_tree']['vdev_stats']
            return libzfs.zpool_state_to_name(stats[1], stats[2])

    property error_count:
        def __get__(self):
            return self.config.get('error_count')

    property config:
        def __get__(self):
            return dict(self.get_raw_config())

    property properties:
        def __get__(self):
            cdef ZPoolProperty prop
            proptypes = []
            result = {}
            libzfs.zprop_iter(self.__iterate_props, <void*>proptypes, True, True, zfs.ZFS_TYPE_POOL)

            for x in proptypes:
                prop = ZPoolProperty.__new__(ZPoolProperty)
                prop.pool = self
                prop.propid = x
                result[prop.name] = prop

            return result

    property features:
        def __get__(self):
            cdef ZPoolFeature f
            cdef NVList features_nv
            cdef zfs.zfeature_info_t* feat
            cdef uintptr_t nvl;

            if self.status == 'UNAVAIL':
                return

            nvl = <uintptr_t>libzfs.zpool_get_features(self.handle)
            features_nv = NVList(nvl)

            for i in range(0, zfs.SPA_FEATURES):
                feat = &zfs.spa_feature_table[i]
                f = ZPoolFeature.__new__(ZPoolFeature)
                f.feature = feat
                f.pool = self
                f.nvlist = features_nv
                yield f


    property disks:
        def __get__(self):
            result = []
            for g in self.groups.values():
                for v in g:
                    result += v.disks

            return result

    property scrub:
        def __get__(self):
            return ZPoolScrub(self.root, self)

    cdef NVList get_raw_config(self):
        cdef uintptr_t nvl = <uintptr_t>libzfs.zpool_get_config(self.handle, NULL)
        return NVList(nvl)

    def create(self, name, fsopts, fstype=DatasetType.FILESYSTEM, sparse_vol=False):
        cdef NVList cfsopts = NVList(otherdict=fsopts)
        cdef uint64_t vol_reservation

        if fstype == DatasetType.VOLUME and not sparse_vol:
            vol_reservation = libzfs.zvol_volsize_to_reservation(
                nicestrtonum(self.root, cfsopts['volsize']),
                cfsopts.handle)

            cfsopts['refreservation'] = vol_reservation

        if libzfs.zfs_create(
            self.root.handle,
            name,
            fstype,
            cfsopts.handle) != 0:
            raise self.root.get_error()

    def destroy(self, name):
        pass

    def attach_vdevs(self, vdevs_tree):
        cdef const char *command = 'zpool add'
        cdef ZFSVdev vd = self.root.make_vdev_tree(vdevs_tree)

        if libzfs.zpool_add(self.handle, vd.nvlist.handle) != 0:
            raise self.root.get_error()

        self.root.write_history(command, self.name, self.root.history_vdevs_list(vdevs_tree))

    def vdev_by_guid(self, guid):
        def search_vdev(vdev, g):
            if vdev.guid == g:
                return vdev

            for i in vdev.children:
                ret = search_vdev(i, g)
                if ret:
                    return ret

            return None

        if guid == self.root_vdev.guid:
            return self.root_vdev

        for g in (self.data_vdevs, self.cache_vdevs, self.log_vdevs, self.spare_vdevs):
            for i in g:
                ret = search_vdev(i, guid)
                if ret:
                    return ret

    def delete(self):
        if libzfs.zpool_destroy(self.handle, "destroy") != 0:
            raise self.root.get_error()

    def start_scrub(self):
        cdef const char *command = 'zpool scrub'
        if libzfs.zpool_scan(self.handle, zfs.POOL_SCAN_SCRUB) != 0:
            raise self.root.get_error()
        self.root.write_history(command, self.name)

    def stop_scrub(self):
        cdef const char *command = 'zpool scrub -s'
        if libzfs.zpool_scan(self.handle, zfs.POOL_SCAN_NONE) != 0:
            raise self.root.get_error()
        self.root.write_history(command, self.name)

    def clear(self):
        cdef const char *command = 'zpool clear'
        cdef NVList policy = NVList()
        policy["rewind-request"] = zfs.ZPOOL_NO_REWIND
        self.root.write_history(command, self.name)

        return libzfs.zpool_clear(self.handle, NULL, policy.handle) == 0

    def upgrade(self):
        cdef const char *command = 'zpool upgrade'
        if libzfs.zpool_upgrade(self.handle, zfs.SPA_VERSION) != 0:
            raise self.root.get_error()

        for i in self.features:
            if i.state == FeatureState.DISABLED:
                i.enable()

        self.root.write_history(command, self.name)


cdef class ZFSImportablePool(ZFSPool):
    cdef NVList nvlist
    cdef public object name

    def __str__(self):
        return "<libzfs.ZFSImportablePool name '{0}' guid '{1}'>".format(self.name, self.guid)

    def __repr__(self):
        return str(self)

    property config:
        def __get__(self):
            return dict(self.nvlist)

    property properties:
        def __get__(self):
            return None

    property root_dataset:
        def __get__(self):
            return None

    property error_count:
        def __get__(self):
            return 0

    property features:
        def __get__(self):
            return None

    cdef NVList get_raw_config(self):
        return self.nvlist

    def create(self, *args, **kwargs):
        raise NotImplementedError()

    def destroy(self, name):
        raise NotImplementedError()

    def attach_vdev(self, vdev):
        raise NotImplementedError()


cdef class ZFSPropertyDict(dict):
    cdef ZFSDataset parent
    cdef object props

    @staticmethod
    cdef int __iterate_props(int proptype, void* arg) nogil:
        with gil:
            proptypes = <object>arg
            proptypes.append(proptype)
            return zfs.ZPROP_CONT

    def __repr__(self):
        return '{' + ', '.join(["'{0}': {1}".format(k, repr(v)) for k, v in self.items()]) + '}'

    def refresh(self):
        cdef ZFSProperty prop
        cdef ZFSUserProperty userprop
        cdef nvpair.nvlist_t *nvlist
        proptypes = []
        self.props = {}

        libzfs.zprop_iter(self.__iterate_props, <void*>proptypes, True, True, self.parent.type)
        nvlist = libzfs.zfs_get_user_props(self.parent.handle)
        nvl = NVList(<uintptr_t>nvlist)

        for x in proptypes:
            if not zfs.zfs_prop_valid_for_type(x, self.parent.type, False):
                continue

            prop = ZFSProperty.__new__(ZFSProperty)
            prop.dataset = self.parent
            prop.propid = x
            self.props[prop.name] = prop

        for k, v in nvl.items():
            userprop = ZFSUserProperty.__new__(ZFSUserProperty)
            userprop.dataset = self.parent
            userprop.name = k
            userprop.values = v
            self.props[userprop.name] = userprop

    def __delitem__(self, key):
        if key not in self.props:
            raise KeyError(key)

        self.props[key].inherit(recursive=True)

    def __getitem__(self, item):
        return self.props[item]

    def __setitem__(self, key, value):
        cdef ZFSUserProperty userprop
        cdef const char *command = 'zfs set'
        if key in self.props:
            raise KeyError('Cannot overwrite existing property')

        if type(value) is not ZFSUserProperty:
            raise ValueError('Value should be of type ZFSUserProperty')

        userprop = <ZFSUserProperty>value
        if userprop.dataset is None:
            # detached user property
            userprop.dataset = self.parent
            if libzfs.zfs_prop_set(self.parent.handle, key, userprop.value) != 0:
                raise self.parent.root.get_error()

        self.props[key] = userprop
        self.parent.root.write_history(command, (str(key), str(userprop.value)), self.parent.name)

    def __iter__(self):
        for i in self.props:
            yield  i

    def get(self, k, d=None):
        return self.props.get(k, d)

    def setdefault(self, k, d=None):
        pass

    def keys(self):
        return self.props.keys()

    def values(self):
        return self.props.values()

    def iterkeys(self):
        return self.props.iterkeys()

    def itervalues(self):
        return self.props.itervalues()

    def has_key(self, key):
        return key in self.props

    def items(self):
        return self.props.items()

    def update(self, E=None, **F):
        raise NotImplementedError()

    def __contains__(self, key):
        return key in self.props

cdef class ZFSDataset(object):
    cdef libzfs.zfs_handle_t* handle
    cdef readonly ZFS root
    cdef readonly ZFSPool pool

    def __init__(self):
        raise RuntimeError('ZFSDataset cannot be instantiated by the user')

    def __dealloc__(self):
        libzfs.zfs_close(self.handle)

    def __str__(self):
        return "<libzfs.ZFSDataset name '{0}' type '{1}'>".format(self.name, self.type.name)

    def __repr__(self):
        return str(self)

    def __getstate__(self, recursive=True):
        ret = {
            'id': self.name,
            'name': self.name,
            'pool': self.pool.name,
            'type': self.type.name,
            'mountpoint': self.mountpoint,
            'properties': {k: p.__getstate__() for k, p in self.properties.items()},
        }

        if recursive:
            ret['children'] = [i.__getstate__() for i in self.children]

        return ret

    @staticmethod
    cdef int __iterate_children(libzfs.zfs_handle_t* handle, void *arg) nogil:
        with gil:
            datasets = <object>arg
            datasets.append(<uintptr_t>handle)

    @staticmethod
    cdef int __iterate_snapshots(libzfs.zfs_handle_t* handle, void *arg) nogil:
        with gil:
            snapshots = <object>arg
            snapshots.append(<uintptr_t>handle)

    @staticmethod
    cdef int __iterate_dependents(libzfs.zfs_handle_t* handle, void *arg) nogil:
        with gil:
            dependents = <object>arg
            dependents.append(<uintptr_t>handle)

    property name:
        def __get__(self):
            return libzfs.zfs_get_name(self.handle)

    property type:
        def __get__(self):
            cdef zfs.zfs_type_t typ

            typ = libzfs.zfs_get_type(self.handle)
            return DatasetType(typ)

    property children:
        def __get__(self):
            cdef ZFSDataset dataset

            datasets = []
            libzfs.zfs_iter_filesystems(self.handle, self.__iterate_children, <void*>datasets)
            for h in datasets:
                dataset = ZFSDataset.__new__(ZFSDataset)
                dataset.root = self.root
                dataset.pool = self.pool
                dataset.handle = <libzfs.zfs_handle_t*><uintptr_t>h
                yield dataset

    property children_recursive:
        def __get__(self):
            for c in self.children:
                yield c
                for i in c.children_recursive:
                    yield i

    property snapshots:
        def __get__(self):
            cdef ZFSSnapshot snapshot

            snapshots = []
            libzfs.zfs_iter_snapshots(self.handle, False, self.__iterate_snapshots, <void*>snapshots)
            for h in snapshots:
                snapshot = ZFSSnapshot.__new__(ZFSSnapshot)
                snapshot.root = self.root
                snapshot.pool = self.pool
                snapshot.handle = <libzfs.zfs_handle_t*><uintptr_t>h
                if snapshot.snapshot_name == '$ORIGIN':
                    continue

                yield snapshot

    property snapshots_recursive:
        def __get__(self):
            for s in self.snapshots:
                yield s

            for c in self.children:
                for s in c.snapshots:
                    yield s
                for i in c.children_recursive:
                    for s in i.snapshots:
                        yield s

    property dependents:
        def __get__(self):
            cdef ZFSDataset dataset
            cdef ZFSSnapshot snapshot
            cdef zfs.zfs_type_t type

            dependents = []
            libzfs.zfs_iter_dependents(self.handle, False, self.__iterate_dependents, <void*>dependents)
            for h in dependents:
                type = libzfs.zfs_get_type(<libzfs.zfs_handle_t*><uintptr_t>h)

                if type == zfs.ZFS_TYPE_FILESYSTEM or type == zfs.ZFS_TYPE_VOLUME:
                    dataset = ZFSDataset.__new__(ZFSDataset)
                    dataset.root = self.root
                    dataset.pool = self.pool
                    dataset.handle = <libzfs.zfs_handle_t*><uintptr_t>h
                    yield dataset

                if type == zfs.ZFS_TYPE_SNAPSHOT:
                    snapshot = ZFSSnapshot.__new__(ZFSSnapshot)
                    snapshot.root = self.root
                    snapshot.pool = self.pool
                    snapshot.handle = <libzfs.zfs_handle_t*><uintptr_t>h
                    yield snapshot

    property properties:
        def __get__(self):
            cdef ZFSPropertyDict d

            d = ZFSPropertyDict.__new__(ZFSPropertyDict)
            d.parent = self
            d.refresh()
            return d

    property mountpoint:
        def __get__(self):
            cdef char *mntpt
            if libzfs.zfs_is_mounted(self.handle, &mntpt) == 0:
                return None

            result = mntpt
            free(mntpt)
            return result

    def rename(self, new_name, recurse=False, forceunmount=False):
        cdef const char *command = 'zfs rename'

        if libzfs.zfs_rename(self.handle, new_name, recurse, forceunmount) != 0:
            raise self.root.get_error()

        self.root.write_history(command, '-f' if forceunmount else '', self.name)

    def delete(self):
        if libzfs.zfs_destroy(self.handle, True) != 0:
            raise self.root.get_error()

    def destroy_snapshot(self, name):
        cdef const char *command = 'zfs destroy'
        if libzfs.zfs_destroy_snaps(self.handle, name, True) != 0:
            raise self.root.get_error()
        self.root.write_history(command, name)

    def mount(self):
        cdef const char *command = 'zfs mount'
        if libzfs.zfs_mount(self.handle, NULL, 0) != 0:
            raise self.root.get_error()
        self.root.write_history(command, self.name)

    def mount_recursive(self):
        if self.type != DatasetType.FILESYSTEM:
            return

        if self.properties['canmount'].value == 'on':
            self.mount()

        for i in self.children:
            i.mount_recursive()

    def umount(self, force=False):
        cdef const char *command = 'zfs umount'
        cdef int flags = 0

        if force:
            flags = zfs.MS_FORCE

        if libzfs.zfs_unmountall(self.handle, flags) != 0:
            raise self.root.get_error()
        self.root.write_history(command, '-f' if force else '', self.name)

    def umount_recursive(self, force=False):
        if self.type != DatasetType.FILESYSTEM:
            return

        self.umount(force)

        for i in self.children:
            i.umount_recursive(force)

    def send(self, fd, **kwargs):
        cdef int cfd = fd
        cdef int err
        cdef char *ctoname
        cdef char *cfromname = NULL
        cdef libzfs.sendflags_t cflags

        toname = kwargs.get('toname')
        fromname = kwargs.get('fromname')
        flags = kwargs.get('flags')
        memset(&cflags, 0, cython.sizeof(libzfs.sendflags_t))

        if not toname:
            raise ValueError('toname argument is required')

        ctoname = toname

        if fromname:
            cfromname = fromname

        if flags:
            convert_sendflags(flags, &cflags)

        with nogil:
            err = libzfs.zfs_send(self.handle, cfromname, ctoname, &cflags, cfd, NULL, NULL, NULL)

        if err != 0:
            raise self.root.get_error()

    def get_send_space(self, fromname=None):
        cdef const char *cfromname = NULL
        cdef uint64_t space

        if fromname:
            cfromname = fromname

        if libzfs.lzc_send_space(self.name, cfromname, &space) != 0:
            raise ZFSException(Error.FAULT, "Cannot obtain space estimate: ")

        return space

    def get_send_progress(self, fd):
        cdef zfs.zfs_cmd_t cmd

        memset(&cmd, 0, cython.sizeof(libzfs.zfs_cmd))

        cmd.zc_cookie = fd
        strncpy(cmd.zc_name, self.name, zfs.MAXPATHLEN)

        if libzfs.zfs_ioctl(self.root.handle, zfs.ZFS_IOC_SEND_PROGRESS, &cmd) != 0:
            raise ZFSException(Error.FAULT, "Cannot obtain send progress")

        return cmd.zc_cookie

    def promote(self):
        cdef const char *command = 'zfs promote'
        if libzfs.zfs_promote(self.handle) != 0:
            raise self.root.get_error()
        self.root.write_history(command, self.name)

    def snapshot(self, name, fsopts=None, recursive=False):
        cdef const char *command = 'zfs snapshot'
        cdef NVList cfsopts = NVList(otherdict=fsopts or {})

        if libzfs.zfs_snapshot(
            self.root.handle,
            name,
            recursive,
            cfsopts.handle) != 0:
            raise self.root.get_error()

        if self.root.history:
            hfsopts = self.root.generate_history_opts(fsopts, '-o')
            self.root.write_history(command, '-r' if recursive else '', hfsopts, name)

    def receive(self, fd, force=False, nomount=False, resumable=False, props=None, limitds=None):
        self.root.receive(
            self.name,
            fd,
            force=force,
            nomount=nomount,
            resumable=resumable,
            props=props,
            limitds=limitds
        )


cdef class ZFSSnapshot(ZFSDataset):
    def __str__(self):
        return "<libzfs.ZFSSnapshot name '{0}'>".format(self.name)

    def __repr__(self):
        return str(self)

    def __getstate__(self, recursive=True):
        ret = super(ZFSSnapshot, self).__getstate__(recursive)
        ret.update({
            'holds': self.holds,
            'snapshot_name': self.snapshot_name
        })
        return ret

    def rollback(self, force=False):
        cdef const char *command = 'zfs rollback'
        cdef ZFSDataset parent

        parent = <ZFSDataset>self.parent
        if libzfs.zfs_rollback(parent.handle, self.handle, force) != 0:
            raise self.root.get_error()

        self.root.write_history(command, '-f' if force else '', self.name)

    def bookmark(self, name):
        pass

    def clone(self, name, opts=None):
        cdef const char *command = 'zfs clone'
        cdef NVList copts = None
        if opts:
            copts = NVList(otherdict=opts)

        if libzfs.zfs_clone(
            self.handle,
            name,
            copts.handle if copts else NULL) != 0:
            raise self.root.get_error()
        if self.root.history:
            hopts = self.root.generate_history_opts(opts, '-o')
            self.root.write_history(command, hopts, self.name)

    def hold(self, tag, recursive=False):
        cdef const char *command = 'zfs hold'
        cdef ZFSDataset parent

        parent = <ZFSDataset>self.parent
        if libzfs.zfs_hold(parent.handle, self.snapshot_name, tag, recursive, -1) != 0:
            raise self.root.get_error()
        self.root.write_history(command, '-r' if recursive else '', tag, self.name)

    def release(self, tag, recursive=False):
        cdef const char *command = 'zfs release'
        cdef ZFSDataset parent

        parent = <ZFSDataset>self.parent
        if libzfs.zfs_release(parent.handle, self.snapshot_name, tag, recursive) != 0:
            raise self.root.get_error()
        self.root.write_history(command, '-r' if recursive else '', tag, self.name)

    def delete(self, recursive=False):
        cdef const char *command = 'zfs destroy'
        if not recursive:
            super(ZFSSnapshot, self).delete()
        else:
            self.parent.destroy_snapshot(self.snapshot_name)
        self.root.write_history(command, '-r' if recursive else '', self.name)

    def send(self, fd, **kwargs):
        fromname = kwargs.get('fromname')
        flags = kwargs.get('flags')
        return self.parent.send(fd, toname=self.snapshot_name, fromname=fromname, flags=flags)

    property snapshot_name:
        def __get__(self):
            return self.name.partition('@')[-1]

    property parent:
        def __get__(self):
            return self.root.get_dataset(self.name.partition('@')[0])

    property holds:
        def __get__(self):
            cdef nvpair.nvlist_t* ptr
            cdef NVList nvl

            if libzfs.zfs_get_holds(self.handle, &ptr) != 0:
                raise self.root.get_error()

            nvl = NVList(<uintptr_t>ptr)
            return dict(nvl)


cdef convert_sendflags(flags, libzfs.sendflags_t *cflags):
    if not isinstance(flags, set):
        raise ValueError('flags must be passed as a set')

    if SendFlag.VERBOSE in flags:
        cflags.verbose = 1

    if SendFlag.REPLICATE in flags:
        cflags.replicate = 1

    if SendFlag.DOALL in flags:
        cflags.doall = 1

    if SendFlag.FROMORIGIN in flags:
        cflags.fromorigin = 1

    if SendFlag.DEDUP in flags:
        cflags.dedup = 1

    if SendFlag.PROPS in flags:
        cflags.props = 1

    if SendFlag.DRYRUN in flags:
        cflags.dryrun = 1

    if SendFlag.PARSABLE in flags:
        cflags.parsable = 1

    if SendFlag.PROGRESS in flags:
        cflags.progress = 1

    if SendFlag.LARGEBLOCK in flags:
        cflags.largeblock = 1

    if SendFlag.EMBED_DATA in flags:
        cflags.embed_data = 1


def nicestrtonum(ZFS zfs, value):
    cdef uint64_t result

    if libzfs.zfs_nicestrtonum(zfs.handle, value, &result) != 0:
        raise ValueError('Cannot convert {0} to integer'.format(value))

    return result
