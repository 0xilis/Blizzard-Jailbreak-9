//
//  blizzardJailbreak.c
//
//  Created by GeoSn0w on 8/10/20.
//  Copyright © 2022 GeoSn0w. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "blizzardJailbreak.h"
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <netinet/in.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <sys/mount.h>
#include <mach/mach.h>
#include <sys/mman.h>
#include <spawn.h>
#include "BlizzardLog.h"
#import "../Exploits/Phoenix Exploit/exploit.h"
#import "../PatchFinder/patchfinder.h"
#import "../Kernel Tools/KernMemory.h"

mach_port_t kern_task = 0;
#define KERNEL_HEADER_SIZE (0x1000)
kaddr_t text_vmaddr = 0;
size_t text_vmsize = 0;
kaddr_t text_text_sec_addr = 0;
size_t text_text_sec_size = 0;
kaddr_t text_const_sec_addr = 0;
size_t text_const_sec_size = 0;
kaddr_t text_cstring_sec_addr = 0;
size_t text_cstring_sec_size = 0;
kaddr_t text_os_log_sec_addr = 0;
size_t text_os_log_sec_size = 0;
kaddr_t data_vmaddr = 0;
size_t data_vmsize = 0;
kaddr_t KernelOffset(kaddr_t base, kaddr_t off);
kaddr_t allproc = 0;
static uint8_t *kdata = NULL;
static size_t ksize = 0;
static uint64_t kernel_entry = 0;
uint64_t kerndumpbase = -1;
static void *kernel_mh = 0;
uint32_t myProc;
uint32_t myUcred;

// Sandbox Policy Stuff
struct mac_policy_ops {
    uint32_t mpo_audit_check_postselect;
    uint32_t mpo_audit_check_preselect;
    uint32_t mpo_bpfdesc_label_associate;
    uint32_t mpo_bpfdesc_label_destroy;
    uint32_t mpo_bpfdesc_label_init;
    uint32_t mpo_bpfdesc_check_receive;
    uint32_t mpo_cred_check_label_update_execve;
    uint32_t mpo_cred_check_label_update;
    uint32_t mpo_cred_check_visible;
    uint32_t mpo_cred_label_associate_fork;
    uint32_t mpo_cred_label_associate_kernel;
    uint32_t mpo_cred_label_associate;
    uint32_t mpo_cred_label_associate_user;
    uint32_t mpo_cred_label_destroy;
    uint32_t mpo_cred_label_externalize_audit;
    uint32_t mpo_cred_label_externalize;
    uint32_t mpo_cred_label_init;
    uint32_t mpo_cred_label_internalize;
    uint32_t mpo_cred_label_update_execve;
    uint32_t mpo_cred_label_update;
    uint32_t mpo_devfs_label_associate_device;
    uint32_t mpo_devfs_label_associate_directory;
    uint32_t mpo_devfs_label_copy;
    uint32_t mpo_devfs_label_destroy;
    uint32_t mpo_devfs_label_init;
    uint32_t mpo_devfs_label_update;
    uint32_t mpo_file_check_change_offset;
    uint32_t mpo_file_check_create;
    uint32_t mpo_file_check_dup;
    uint32_t mpo_file_check_fcntl;
    uint32_t mpo_file_check_get_offset;
    uint32_t mpo_file_check_get;
    uint32_t mpo_file_check_inherit;
    uint32_t mpo_file_check_ioctl;
    uint32_t mpo_file_check_lock;
    uint32_t mpo_file_check_mmap_downgrade;
    uint32_t mpo_file_check_mmap;
    uint32_t mpo_file_check_receive;
    uint32_t mpo_file_check_set;
    uint32_t mpo_file_label_init;
    uint32_t mpo_file_label_destroy;
    uint32_t mpo_file_label_associate;
    uint32_t mpo_ifnet_check_label_update;
    uint32_t mpo_ifnet_check_transmit;
    uint32_t mpo_ifnet_label_associate;
    uint32_t mpo_ifnet_label_copy;
    uint32_t mpo_ifnet_label_destroy;
    uint32_t mpo_ifnet_label_externalize;
    uint32_t mpo_ifnet_label_init;
    uint32_t mpo_ifnet_label_internalize;
    uint32_t mpo_ifnet_label_update;
    uint32_t mpo_ifnet_label_recycle;
    uint32_t mpo_inpcb_check_deliver;
    uint32_t mpo_inpcb_label_associate;
    uint32_t mpo_inpcb_label_destroy;
    uint32_t mpo_inpcb_label_init;
    uint32_t mpo_inpcb_label_recycle;
    uint32_t mpo_inpcb_label_update;
    uint32_t mpo_iokit_check_device;
    uint32_t mpo_ipq_label_associate;
    uint32_t mpo_ipq_label_compare;
    uint32_t mpo_ipq_label_destroy;
    uint32_t mpo_ipq_label_init;
    uint32_t mpo_ipq_label_update;
    uint32_t mpo_file_check_library_validation;
    uint32_t mpo_vnode_notify_setacl;
    uint32_t mpo_vnode_notify_setattrlist;
    uint32_t mpo_vnode_notify_setextattr;
    uint32_t mpo_vnode_notify_setflags;
    uint32_t mpo_vnode_notify_setmode;
    uint32_t mpo_vnode_notify_setowner;
    uint32_t mpo_vnode_notify_setutimes;
    uint32_t mpo_vnode_notify_truncate;
    uint32_t mpo_mbuf_label_associate_bpfdesc;
    uint32_t mpo_mbuf_label_associate_ifnet;
    uint32_t mpo_mbuf_label_associate_inpcb;
    uint32_t mpo_mbuf_label_associate_ipq;
    uint32_t mpo_mbuf_label_associate_linklayer;
    uint32_t mpo_mbuf_label_associate_multicast_encap;
    uint32_t mpo_mbuf_label_associate_netlayer;
    uint32_t mpo_mbuf_label_associate_socket;
    uint32_t mpo_mbuf_label_copy;
    uint32_t mpo_mbuf_label_destroy;
    uint32_t mpo_mbuf_label_init;
    uint32_t mpo_mount_check_fsctl;
    uint32_t mpo_mount_check_getattr;
    uint32_t mpo_mount_check_label_update;
    uint32_t mpo_mount_check_mount;
    uint32_t mpo_mount_check_remount;
    uint32_t mpo_mount_check_setattr;
    uint32_t mpo_mount_check_stat;
    uint32_t mpo_mount_check_umount;
    uint32_t mpo_mount_label_associate;
    uint32_t mpo_mount_label_destroy;
    uint32_t mpo_mount_label_externalize;
    uint32_t mpo_mount_label_init;
    uint32_t mpo_mount_label_internalize;
    uint32_t mpo_netinet_fragment;
    uint32_t mpo_netinet_icmp_reply;
    uint32_t mpo_netinet_tcp_reply;
    uint32_t mpo_pipe_check_ioctl;
    uint32_t mpo_pipe_check_kqfilter;
    uint32_t mpo_pipe_check_label_update;
    uint32_t mpo_pipe_check_read;
    uint32_t mpo_pipe_check_select;
    uint32_t mpo_pipe_check_stat;
    uint32_t mpo_pipe_check_write;
    uint32_t mpo_pipe_label_associate;
    uint32_t mpo_pipe_label_copy;
    uint32_t mpo_pipe_label_destroy;
    uint32_t mpo_pipe_label_externalize;
    uint32_t mpo_pipe_label_init;
    uint32_t mpo_pipe_label_internalize;
    uint32_t mpo_pipe_label_update;
    uint32_t mpo_policy_destroy;
    uint32_t mpo_policy_init;
    uint32_t mpo_policy_initbsd;
    uint32_t mpo_policy_syscall;
    uint32_t mpo_system_check_sysctlbyname;
    uint32_t mpo_proc_check_inherit_ipc_ports;
    uint32_t mpo_vnode_check_rename;
    uint32_t mpo_kext_check_query;
    uint32_t mpo_iokit_check_nvram_get;
    uint32_t mpo_iokit_check_nvram_set;
    uint32_t mpo_iokit_check_nvram_delete;
    uint32_t mpo_proc_check_expose_task;
    uint32_t mpo_proc_check_set_host_special_port;
    uint32_t mpo_proc_check_set_host_exception_port;
    uint32_t mpo_exc_action_check_exception_send;
    uint32_t mpo_exc_action_label_associate;
    uint32_t mpo_exc_action_label_populate;
    uint32_t mpo_exc_action_label_destroy;
    uint32_t mpo_exc_action_label_init;
    uint32_t mpo_exc_action_label_update;
    uint32_t mpo_reserved1;
    uint32_t mpo_reserved2;
    uint32_t mpo_reserved3;
    uint32_t mpo_reserved4;
    uint32_t mpo_skywalk_flow_check_connect;
    uint32_t mpo_skywalk_flow_check_listen;
    uint32_t mpo_posixsem_check_create;
    uint32_t mpo_posixsem_check_open;
    uint32_t mpo_posixsem_check_post;
    uint32_t mpo_posixsem_check_unlink;
    uint32_t mpo_posixsem_check_wait;
    uint32_t mpo_posixsem_label_associate;
    uint32_t mpo_posixsem_label_destroy;
    uint32_t mpo_posixsem_label_init;
    uint32_t mpo_posixshm_check_create;
    uint32_t mpo_posixshm_check_mmap;
    uint32_t mpo_posixshm_check_open;
    uint32_t mpo_posixshm_check_stat;
    uint32_t mpo_posixshm_check_truncate;
    uint32_t mpo_posixshm_check_unlink;
    uint32_t mpo_posixshm_label_associate;
    uint32_t mpo_posixshm_label_destroy;
    uint32_t mpo_posixshm_label_init;
    uint32_t mpo_proc_check_debug;
    uint32_t mpo_proc_check_fork;
    uint32_t mpo_proc_check_get_task_name;
    uint32_t mpo_proc_check_get_task;
    uint32_t mpo_proc_check_getaudit;
    uint32_t mpo_proc_check_getauid;
    uint32_t mpo_proc_check_getlcid;
    uint32_t mpo_proc_check_mprotect;
    uint32_t mpo_proc_check_sched;
    uint32_t mpo_proc_check_setaudit;
    uint32_t mpo_proc_check_setauid;
    uint32_t mpo_proc_check_setlcid;
    uint32_t mpo_proc_check_signal;
    uint32_t mpo_proc_check_wait;
    uint32_t mpo_proc_label_destroy;
    uint32_t mpo_proc_label_init;
    uint32_t mpo_socket_check_accept;
    uint32_t mpo_socket_check_accepted;
    uint32_t mpo_socket_check_bind;
    uint32_t mpo_socket_check_connect;
    uint32_t mpo_socket_check_create;
    uint32_t mpo_socket_check_deliver;
    uint32_t mpo_socket_check_kqfilter;
    uint32_t mpo_socket_check_label_update;
    uint32_t mpo_socket_check_listen;
    uint32_t mpo_socket_check_receive;
    uint32_t mpo_socket_check_received;
    uint32_t mpo_socket_check_select;
    uint32_t mpo_socket_check_send;
    uint32_t mpo_socket_check_stat;
    uint32_t mpo_socket_check_setsockopt;
    uint32_t mpo_socket_check_getsockopt;
    uint32_t mpo_socket_label_associate_accept;
    uint32_t mpo_socket_label_associate;
    uint32_t mpo_socket_label_copy;
    uint32_t mpo_socket_label_destroy;
    uint32_t mpo_socket_label_externalize;
    uint32_t mpo_socket_label_init;
    uint32_t mpo_socket_label_internalize;
    uint32_t mpo_socket_label_update;
    uint32_t mpo_socketpeer_label_associate_mbuf;
    uint32_t mpo_socketpeer_label_associate_socket;
    uint32_t mpo_socketpeer_label_destroy;
    uint32_t mpo_socketpeer_label_externalize;
    uint32_t mpo_socketpeer_label_init;
    uint32_t mpo_system_check_acct;
    uint32_t mpo_system_check_audit;
    uint32_t mpo_system_check_auditctl;
    uint32_t mpo_system_check_auditon;
    uint32_t mpo_system_check_host_priv;
    uint32_t mpo_system_check_nfsd;
    uint32_t mpo_system_check_reboot;
    uint32_t mpo_system_check_settime;
    uint32_t mpo_system_check_swapoff;
    uint32_t mpo_system_check_swapon;
    uint32_t mpo_socket_check_ioctl;
    uint32_t mpo_sysvmsg_label_associate;
    uint32_t mpo_sysvmsg_label_destroy;
    uint32_t mpo_sysvmsg_label_init;
    uint32_t mpo_sysvmsg_label_recycle;
    uint32_t mpo_sysvmsq_check_enqueue;
    uint32_t mpo_sysvmsq_check_msgrcv;
    uint32_t mpo_sysvmsq_check_msgrmid;
    uint32_t mpo_sysvmsq_check_msqctl;
    uint32_t mpo_sysvmsq_check_msqget;
    uint32_t mpo_sysvmsq_check_msqrcv;
    uint32_t mpo_sysvmsq_check_msqsnd;
    uint32_t mpo_sysvmsq_label_associate;
    uint32_t mpo_sysvmsq_label_destroy;
    uint32_t mpo_sysvmsq_label_init;
    uint32_t mpo_sysvmsq_label_recycle;
    uint32_t mpo_sysvsem_check_semctl;
    uint32_t mpo_sysvsem_check_semget;
    uint32_t mpo_sysvsem_check_semop;
    uint32_t mpo_sysvsem_label_associate;
    uint32_t mpo_sysvsem_label_destroy;
    uint32_t mpo_sysvsem_label_init;
    uint32_t mpo_sysvsem_label_recycle;
    uint32_t mpo_sysvshm_check_shmat;
    uint32_t mpo_sysvshm_check_shmctl;
    uint32_t mpo_sysvshm_check_shmdt;
    uint32_t mpo_sysvshm_check_shmget;
    uint32_t mpo_sysvshm_label_associate;
    uint32_t mpo_sysvshm_label_destroy;
    uint32_t mpo_sysvshm_label_init;
    uint32_t mpo_sysvshm_label_recycle;
    uint32_t mpo_proc_notify_exit;
    uint32_t mpo_mount_check_snapshot_revert;
    uint32_t mpo_vnode_check_getattr;
    uint32_t mpo_mount_check_snapshot_create;
    uint32_t mpo_mount_check_snapshot_delete;
    uint32_t mpo_vnode_check_clone;
    uint32_t mpo_proc_check_get_cs_info;
    uint32_t mpo_proc_check_set_cs_info;
    uint32_t mpo_iokit_check_hid_control;
    uint32_t mpo_vnode_check_access;
    uint32_t mpo_vnode_check_chdir;
    uint32_t mpo_vnode_check_chroot;
    uint32_t mpo_vnode_check_create;
    uint32_t mpo_vnode_check_deleteextattr;
    uint32_t mpo_vnode_check_exchangedata;
    uint32_t mpo_vnode_check_exec;
    uint32_t mpo_vnode_check_getattrlist;
    uint32_t mpo_vnode_check_getextattr;
    uint32_t mpo_vnode_check_ioctl;
    uint32_t mpo_vnode_check_kqfilter;
    uint32_t mpo_vnode_check_label_update;
    uint32_t mpo_vnode_check_link;
    uint32_t mpo_vnode_check_listextattr;
    uint32_t mpo_vnode_check_lookup;
    uint32_t mpo_vnode_check_open;
    uint32_t mpo_vnode_check_read;
    uint32_t mpo_vnode_check_readdir;
    uint32_t mpo_vnode_check_readlink;
    uint32_t mpo_vnode_check_rename_from;
    uint32_t mpo_vnode_check_rename_to;
    uint32_t mpo_vnode_check_revoke;
    uint32_t mpo_vnode_check_select;
    uint32_t mpo_vnode_check_setattrlist;
    uint32_t mpo_vnode_check_setextattr;
    uint32_t mpo_vnode_check_setflags;
    uint32_t mpo_vnode_check_setmode;
    uint32_t mpo_vnode_check_setowner;
    uint32_t mpo_vnode_check_setutimes;
    uint32_t mpo_vnode_check_stat;
    uint32_t mpo_vnode_check_truncate;
    uint32_t mpo_vnode_check_unlink;
    uint32_t mpo_vnode_check_write;
    uint32_t mpo_vnode_label_associate_devfs;
    uint32_t mpo_vnode_label_associate_extattr;
    uint32_t mpo_vnode_label_associate_file;
    uint32_t mpo_vnode_label_associate_pipe;
    uint32_t mpo_vnode_label_associate_posixsem;
    uint32_t mpo_vnode_label_associate_posixshm;
    uint32_t mpo_vnode_label_associate_singlelabel;
    uint32_t mpo_vnode_label_associate_socket;
    uint32_t mpo_vnode_label_copy;
    uint32_t mpo_vnode_label_destroy;
    uint32_t mpo_vnode_label_externalize_audit;
    uint32_t mpo_vnode_label_externalize;
    uint32_t mpo_vnode_label_init;
    uint32_t mpo_vnode_label_internalize;
    uint32_t mpo_vnode_label_recycle;
    uint32_t mpo_vnode_label_store;
    uint32_t mpo_vnode_label_update_extattr;
    uint32_t mpo_vnode_label_update;
    uint32_t mpo_vnode_notify_create;
    uint32_t mpo_vnode_check_signature;
    uint32_t mpo_vnode_check_uipc_bind;
    uint32_t mpo_vnode_check_uipc_connect;
    uint32_t mpo_proc_check_run_cs_invalid;
    uint32_t mpo_proc_check_suspend_resume;
    uint32_t mpo_thread_userret;
    uint32_t mpo_iokit_check_set_properties;
    uint32_t mpo_system_check_chud;
    uint32_t mpo_vnode_check_searchfs;
    uint32_t mpo_priv_check;
    uint32_t mpo_priv_grant;
    uint32_t mpo_proc_check_map_anon;
    uint32_t mpo_vnode_check_fsgetpath;
    uint32_t mpo_iokit_check_open;
    uint32_t mpo_proc_check_ledger;
    uint32_t mpo_vnode_notify_rename;
    uint32_t mpo_vnode_check_setacl;
    uint32_t mpo_vnode_notify_deleteextattr;
    uint32_t mpo_system_check_kas_info;
    uint32_t mpo_vnode_check_lookup_preflight;
    uint32_t mpo_vnode_notify_open;
    uint32_t mpo_system_check_info;
    uint32_t mpo_pty_notify_grant;
    uint32_t mpo_pty_notify_close;
    uint32_t mpo_vnode_find_sigs;
    uint32_t mpo_kext_check_load;
    uint32_t mpo_kext_check_unload;
    uint32_t mpo_proc_check_proc_info;
    uint32_t mpo_vnode_notify_link;
    uint32_t mpo_iokit_check_filter_properties;
    uint32_t mpo_iokit_check_get_property;
};

kaddr_t KernelOffset(kaddr_t base, kaddr_t off){
    if(!off) {
        return 0;
    }
    return base+off;
}

static int blizzardInitializeKernel(kaddr_t base) {
    unsigned i;
    uint8_t buf[KERNEL_HEADER_SIZE];
    const struct mach_header *hdr = (struct mach_header *)buf;
    const uint8_t *q;
    uint64_t min = -1;
    uint64_t max = 0;
    
    copyin(buf, base, sizeof(buf));
    q = buf + sizeof(struct mach_header) + 0;
    
    for (i = 0; i < hdr->ncmds; i++) {
        const struct load_command *cmd = (struct load_command *)q;
        if (cmd->cmd == LC_SEGMENT) {
            const struct segment_command *seg = (struct segment_command *)q;
            if (min > seg->vmaddr) {
                min = seg->vmaddr;
            }
            if (max < seg->vmaddr + seg->vmsize) {
                max = seg->vmaddr + seg->vmsize;
            }
            if (!strcmp(seg->segname, "__TEXT")) {
                text_vmaddr = seg->vmaddr;
                text_vmsize = seg->vmsize;
                
                const struct section *sec = (struct section *)(seg + 1);
                for (uint32_t j = 0; j < seg->nsects; j++) {
                    if (!strcmp(sec[j].sectname, "__text")) {
                        text_text_sec_addr = sec[j].addr;
                        text_text_sec_size = sec[j].size;
                    } else if (!strcmp(sec[j].sectname, "__const")) {
                        text_const_sec_addr = sec[j].addr;
                        text_const_sec_size = sec[j].size;
                    } else if (!strcmp(sec[j].sectname, "__cstring")) {
                        text_cstring_sec_addr = sec[j].addr;
                        text_cstring_sec_size = sec[j].size;
                    } else if (!strcmp(sec[j].sectname, "__os_log")) {
                        text_os_log_sec_addr = sec[j].addr;
                        text_os_log_sec_size = sec[j].size;
                    }
                }
            } else if (!strcmp(seg->segname, "__DATA")) {
                data_vmaddr = seg->vmaddr;
                data_vmsize = seg->vmsize;
            }
        }
        if (cmd->cmd == LC_UNIXTHREAD) {
            uint32_t *ptr = (uint32_t *)(cmd + 1);
            uint32_t flavor = ptr[0];
            struct {
                uint32_t    r[13];  /* General purpose register r0-r12 */
                uint32_t    sp;     /* Stack pointer r13 */
                uint32_t    lr;     /* Link register r14 */
                uint32_t    pc;     /* Program counter r15 */
                uint32_t    cpsr;   /* Current program status register */
            } *thread = (void *)(ptr + 2);
            if (flavor == 6) {
                kernel_entry = thread->pc;
            }
        }
        q = q + cmd->cmdsize;
    }
    
    kerndumpbase = min;
    ksize = max - min;
    
    kdata = malloc(ksize);
    if (!kdata) {
        return -1;
    }
    
    copyin(kdata, kerndumpbase, ksize);
    
    kernel_mh = kdata + base - min;
    return 0;
}

int blizzardGetTFP0(){
    printf("Blizzard is exploting the kernel...\n");
    exploit();
    kern_task  = tfp0;
    
    if (kern_task != 0){
        printf("Got tfp0: %0xllx\n", kern_task);
        blizzardInitializeKernel(KernelBase);
        printf("Getting ALLPROC...\n");
        blizzardGetAllproc();
        printf("Getting ROOT...\n");
        blizzardGetRoot();
        printf("Escaping SandBox...\n\n");
        blizzardEscapeSandbox();
    } else {
        printf("FAILED to obtain Kernel Task Port!\n");
    }
    return 0;
}

kaddr_t blizzardGetAllproc(){
    allproc = KernelOffset(KernelBase,find_allproc(KernelBase, kdata, ksize));
    
    if (allproc == 0){
        printf("Cannot retrieve ALLPROC!\n");
        return -1;
    }
    
    printf("[+] Successfully got AllProc: 0x%x\n", allproc);
    return allproc;
}

int blizzardGetRoot(){
    pid_t currentUserID = getuid();
    printf("[i] Current User ID: %d\n", getuid());
    vm_size_t sz = 4;
    
        if (currentUserID != 0){
            uint32_t kproc = 0;
            myProc = 0;
            myUcred = 0;
            pid_t mypid = getpid();
            uint32_t proc = 0;
            vm_read_overwrite(tfp0, allproc, sz, (vm_address_t)&proc, &sz);
            while (proc) {
                uint32_t pid = 0;
                vm_read_overwrite(tfp0, proc + 8, sz, (vm_address_t)&pid, &sz);
                if (pid == mypid) {
                    myProc = proc;
                } else if (pid == 0) {
                    kproc = proc;
                }
                vm_read_overwrite(tfp0, proc, sz, (vm_address_t)&proc, &sz);
            }
            vm_read_overwrite(tfp0, myProc + 0xa4, sz, (vm_address_t)&myUcred, &sz);
            uint32_t kcred = 0;
            vm_read_overwrite(tfp0, kproc + 0xa4, sz, (vm_address_t)&kcred, &sz);
            vm_write(tfp0, myProc + 0xa4, (vm_address_t)&kcred, sz);
            setuid(0);
            printf("[+] Got ROOT! Current User ID: %x\n", getuid());
            return 0;
        }
    return -1;
}

int blizzardEscapeSandbox(){
    printf("[i] Preparing to escape SandBox...\n");
    printf("[i] Getting SBOPS Offset...\n");
    uint32_t sandbox_sbops = find_sbops(KernelBase, kdata, 32 * 1024 * 1024);
    
    if (sandbox_sbops != 0){
        printf("[+] Found SBOPS offset: %x\n", sandbox_sbops);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_ioctl), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_access), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_create), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_chroot), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_exchangedata), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_deleteextattr), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_notify_create), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_listextattr), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_open), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setattrlist), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_link), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_exec), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_stat), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_unlink), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_getattrlist), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_getextattr), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_rename), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_file_check_mmap), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_cred_label_update_execve), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_mount_check_stat), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_proc_check_fork), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_readlink), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setutimes), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setextattr), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setflags), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_fsgetpath), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setmode), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setowner), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setutimes), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_truncate), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_getattr), 0);
        WriteKernel32(KernelBase + sandbox_sbops + offsetof(struct mac_policy_ops, mpo_iokit_check_get_property), 0);
        
        printf("[i] Testing current SandBox conditions...\n");
        
        FILE *testFile = fopen("/var/mobile/blizzard", "w");
        if (!testFile) {
            printf("[!] Failed to unsandbox process! Patch failed.\n");
             return -2;
        }
        else {
            printf("[+] Successfully escaped Sandbox and patched policies.\n");
        }
        
        return 0;
    }
    printf("[-] Cannot find SBOPS offset. Aborting...\n");
    return -1;
}

#define TTB_SIZE                4096
#define L1_SECT_S_BIT           (1 << 16)
#define L1_SECT_PROTO           (1 << 1)
#define L1_SECT_AP_URW          (1 << 10) | (1 << 11)
#define L1_SECT_APX             (1 << 15)
#define L1_SECT_DEFPROT         (L1_SECT_AP_URW | L1_SECT_APX)
#define L1_SECT_SORDER          (0)
#define L1_SECT_DEFCACHE        (L1_SECT_SORDER)
#define L1_PROTO_TTE(entry)     (entry | L1_SECT_S_BIT | L1_SECT_DEFPROT | L1_SECT_DEFCACHE)

uint32_t pmaps[TTB_SIZE];
int page_maps_count = 0;

void blizzardPatchPMAP(mach_port_t tfp0, uintptr_t kernBase) {
    uint32_t kernel_pmap            = find_pmap_location(kernBase, kdata, ksize);
    uint32_t kernel_pmap_store      = ReadKernel32(kernel_pmap);
    uint32_t tte_virt               = ReadKernel32(kernel_pmap_store);
    uint32_t tte_phys               = ReadKernel32(kernel_pmap_store+4);
    
    printf("[i] Found Kernel PMAP Store at 0x%08x\n", kernel_pmap_store);
    printf("[i] The Kernel PMAP TTE is at Virtual Address 0x%08x / Physical Address 0x%08x\n", tte_virt, tte_phys);
    
    uint32_t i;
    for (i = 0; i < TTB_SIZE; i++) {
        uint32_t addr   = tte_virt + (i << 2);
        uint32_t entry  = ReadKernel32(addr);
        if (entry == 0) continue;
        if ((entry & 0x3) == 1) {
            uint32_t lvl_pg_addr = (entry & (~0x3ff)) - tte_phys + tte_virt;
            for (int i = 0; i < 256; i++) {
                uint32_t sladdr  = lvl_pg_addr+(i<<2);
                uint32_t slentry = ReadKernel32(sladdr);
                
                if (slentry == 0)
                    continue;
                
                uint32_t new_entry = slentry & (~0x200);
                if (slentry != new_entry) {
                    WriteKernel32(sladdr, new_entry);
                    pmaps[page_maps_count++] = sladdr;
                }
            }
            continue;
        }
        
        if ((entry & L1_SECT_PROTO) == 2) {
            uint32_t new_entry  =  L1_PROTO_TTE(entry);
            new_entry           &= ~L1_SECT_APX;
            WriteKernel32(addr, new_entry);
        }
    }
    
    printf("[+] Successfully patched Kernel PMAP!\n");
    usleep(100000);
}
