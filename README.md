conf/local.conf
MACHINE ?= "qemuarm"

## Build docker image - once
docker build -t yocto-builder .

## Run docker container
docker run -it --rm \
  --net=host \
  -v "$HOME/Documents/code/yocto:/home/yocto/workspace" \
  -v "$HOME/Documents/code/snake_game:/home/yocto/snake_game" \
  yocto-builder

## Set environment for bitbake and runqemu
source poky/oe-init-build-env build-qemux86-64

## build
bitbake core-image-minimal

## build poky sdk
bitbake core-image-minimal -c populate_sdk

## after a new sdk
# Copy the newly generated script from the deploy directory to your Dockerfile directory
cp build-qemux86-64/tmp/deploy/sdk/poky-glibc-*.sh .

##
runqemu qemux86-64 nographic slirp

# don't use
qemu-system-x86_64 \
  -kernel bzImage \
  -drive file=core-image-minimal-qemux86-64.rootfs.ext4,format=raw \
  -append "root=/dev/sda rw console=ttyS0" \
  -nographic

## 