# jetson-kvm

WIP docs for this, expands on [BaoqianWang's docs](https://github.com/BaoqianWang/VirtualizationOnJetsonTX2
) and various posts on the NVIDIA forums.

## Why?

The TX2 devkit has:
* 6 ARM Cores (4 Cortex-A57 + 2 Denver2s) peaking at 2GHz
* 8GB ram 
* cheap (£300 with academic discount)
* low power (IIRC 15W Peak)
* x4 PCIe slot
* SATA Adapator
* Mini ITX form factor

Which honestly makes this a fairly solid box for running a few VMs. Also we can finaly rid ourselves of x86!

## Process

Minor notes:

* You actually do not need to backport `KVM_CAP_ARM_USER_IRQ`[arm_user_irq], like I mistakenly thought based on previous errors, just need to enable two kernel features and update the device tree.

### Rebuild Kernel

#### Get the sources

```
./source_sync.sh
```

At the time of writing, `tegra-l4t-r32.4.3` was the latest tag, which was used.

#### Installing the Toolchain

NVIDIA recomends the [Linaro toolchain](http://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz).

#### Setup Environment

```
export CROSS_COMPILE=<cross_prefix>
export LOCALVERSION=-tegra
```

#### Reconfigure

```
# Generate the default Tegra config
make ARCH=arm64 O=$TEGRA_KERNEL_OUT tegra_defconfig
# Modify
make ARCH=arm64 O=$TEGRA_KERNEL_OUT menuconfig
```

Now enable the following options:

* Virtualization -> Kernel-Based Virtual Machine
* Device Drivers -> Tegra Virtualization Support

#### Compile

```
make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j$(nproc)
```

#### Build a better rootfs (optional)

If you'd prefer a system with more up to date packages that what the base 18.04 Sample rootfs provides, you can take one from another `aarch64` distribution.

I've tested:

* [ArchLinux Arms ARMv8 AArch64 Multi-platform](https://archlinuxarm.org/about/downloads)
* [Alpine's Mini Root Filesystem](https://alpinelinux.org/downloads/)

You need to make sure:
* It has `/sbin/init` (or use `flash.sh` to specify an alternative init)
* Copy over the sample rootfs `/boot`
* Install the modules (next step)

After that, it should boot.

#### Replace Default Kernel

Run the following to move the build artifacts to the 

```
cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image $BASE_DIR/Linux_for_Tegra/kernel/Image 
cp -r $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/ $BASE_DIR/Linux_for_Tegra/kernel/dtb/
sudo make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install \
    INSTALL_MOD_PATH=$BASE_DIR/Linux_for_Tegra/rootfs/
```

### Update Device Tree

The patches to the device tree listed on the Nvidia forums ended up resulting in my devkit (Revision C02) boot hanging. Seems it was because it needed two extra lines.

### Flash 

```
sudo ./flash.sh -d ./kernel/dtb/tegra186-quill-p3310-1000-c03-00-base.dtb jetson-tx2 mmcblk0p1
```

* The `-d` option is used to point to your new device tree binary. You might not need it, but it's just a cautious thing.
* Pretty much the standard recomendation from [flashing]

### Install virt-manager

You need to install the EFI tools and virt-manager to create and manage VMs:

```
sudo apt install kvmtool virt-manager qemu-efi # stock rootfs
```

### Run a VM

Try something like Alpine Linux.

## References

* [flashing] https://docs.nvidia.com/jetson/l4t/index.html#page/Tegra%2520Linux%2520Driver%2520Package%2520Development%2520Guide%2Fflashing.html%23wwpID0E0UJ0HA
* [arm_user_irq] https://www.spinics.net/lists/kvm/msg147786.html
