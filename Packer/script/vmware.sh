#!/bin/bash -eux

SSH_USER=${SSH_USERNAME:-vagrant}
SSH_USER_HOME=${SSH_USER_HOME:-/home/${SSH_USER}}

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
    echo "==> Installing VMware Tools"
    cat /etc/redhat-release
    if grep -q -i "release 6" /etc/redhat-release ; then
        # Uninstall fuse to fake out the vmware install so it won't try to
        # enable the VMware blocking filesystem
        yum erase -y fuse
    fi
    # Assume that we've installed all the prerequisites:
    # kernel-headers-$(uname -r) kernel-devel-$(uname -r) gcc make perl
    # from the install media via ks.cfg

    # On RHEL 5, add /sbin to PATH because vagrant does a probe for
    # vmhgfs with lsmod sans PATH
    if grep -q -i "release 5" /etc/redhat-release ; then
        echo "export PATH=$PATH:/usr/sbin:/sbin" >> $SSH_USER_HOME/.bashrc
    fi

    if grep -q -i "release 7" /etc/redhat-release ; then

# From version 9.10.x of open-vm-tools the deploypkg component is included,
# so this code should not be needed any more.
#         cat <<-EOF > /etc/yum.repos.d/vmware-tools.repo
# [vmware-tools]
# name = VMware Tools
# baseurl = http://packages.vmware.com/packages/rhel7/x86_64/
# enabled = 1
# gpgcheck = 1
# EOF

#         cd /tmp
#         for key in VMWARE-PACKAGING-GPG-DSA-KEY.pub VMWARE-PACKAGING-GPG-RSA-KEY.pub
#         do
#             wget http://packages.vmware.com/tools/keys/${key}
#             rpm --import ${key}
#         done

        # yum -y install open-vm-tools open-vm-tools-deploypkg perl net-tools
        yum -y install open-vm-tools perl net-tools
        systemctl restart vmtoolsd

        # This is required for the server customisation step to work with CentOS7 installs currently.
        rm -f /etc/redhat-release
        touch /etc/redhat-release
        echo "Red Hat Enterprise Linux Server release 7.0 (Maipo)" > /etc/redhat-release

    else 
        cd /tmp
        mkdir -p /mnt/cdrom
        mount -o loop $SSH_USER_HOME/linux.iso /mnt/cdrom

        VMWARE_TOOLS_PATH=$(ls /mnt/cdrom/VMwareTools-*.tar.gz)
        VMWARE_TOOLS_VERSION=$(echo "${VMWARE_TOOLS_PATH}" | cut -f2 -d'-')
        VMWARE_TOOLS_BUILD=$(echo "${VMWARE_TOOLS_PATH}" | cut -f3 -d'-')
        VMWARE_TOOLS_BUILD=$(basename ${VMWARE_TOOLS_BUILD} .tar.gz)
        VMWARE_TOOLS_MAJOR_VERSION=$(echo ${VMWARE_TOOLS_VERSION} | cut -d '.' -f 1)
        echo "==> VMware Tools Path: ${VMWARE_TOOLS_PATH}"
        echo "==> VMware Tools Version: ${VMWARE_TOOLS_VERSION}"
        echo "==> VMware Tools Build: ${VMWARE_TOOLS_BUILD}"

        tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/

        if [ "${VMWARE_TOOLS_MAJOR_VERSION}" -lt "10" ]; then
            /tmp/vmware-tools-distrib/vmware-install.pl -d
        else
            /tmp/vmware-tools-distrib/vmware-install.pl -f
        fi
        rm $SSH_USER_HOME/linux.iso
        umount /mnt/cdrom
        rmdir /mnt/cdrom
        rm -rf /tmp/VMwareTools-*

        echo "==> Removing packages needed for building guest tools"
        yum -y remove gcc cpp libmpc mpfr kernel-devel kernel-headers
    fi

    systemctl disable NetworkManager.service
    chkconfig network on

fi
