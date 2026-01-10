# part of the FWK
# Makefile for Yocto integration using docker image fwfwk/yocto:{release}

# default variable values
FWK_YOCTO_SRC?=${FWK_TOPDIR}/src/yocto
FWK_YOCTO_DIR?=${FWK_TOPDIR}/prj/yocto
FWK_YOCTO_BUILD_DIR?=${FWK_YOCTO_DIR}/build

FWK_YOCTO_INIT_BUILD_ENV?=${FWK_YOCTO_SRC}/poky/oe-init-build-env
FWK_YOCTO_OE_TERMINAL?="tmux"
FWK_YOCTO_POST_CFG?=${FWK_TOPDIR}/cfg/yocto_post.conf
FWK_YOCTO_SITE_CFG?=${FWK_TOPDIR}/cfg/yocto_site.conf

FWK_YOCTO_HDF_DIR?=${FWK_TOPDIR}/src/yocto-local/meta-hdf

FWK_YOCTO_WIC_XZ_OPT?="--threads=0 -6"

FWK_YOCTO_SDCARD_OPT?=IMAGE_FSTYPES="wic.xz" WKS_FILE="xilinx-default-sd.wks" WIC_CREATE_EXTRA_ARGS="--no-fstab-update" BB_ENV_PASSTHROUGH_ADDITIONS="IMAGE_FSTYPES WKS_FILE WIC_CREATE_EXTRA_ARGS"
FWK_YOCTO_FITIMAGE_OPT?=KERNEL_CLASSES="kernel-fitimage" KERNEL_IMAGETYPES="fitImage" INITRAMFS_IMAGE=$(FWK_YOCTO_IMAGE) BB_ENV_PASSTHROUGH_ADDITIONS="KERNEL_CLASSES KERNEL_IMAGETYPES INITRAMFS_IMAGE"

# docker
# current user information
UID=$(shell id -u)
GID=$(shell id -g)
USERNAME=$(shell id -u -n)
GROUPNAME=$(shell id -g -n)

# set tty for docker if not CI
ifneq (${CI},true)
DOCKER_INT="-it"
endif

ifeq (${FWK_YOCTO_DOCKER_USE},false)
YOCTO_ENV := source $(FWK_YOCTO_DIR)/bitbake_env.sh &&
else
# docker command
YOCTO_ENV := docker run --rm \
-v ${FWK_TOPDIR}:${FWK_TOPDIR} \
-v ${HOME}/.ssh:/home/${USERNAME}/.ssh \
-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
-v ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK} \
-e DISPLAY=$(DISPLAY) \
-e SSH_AUTH_SOCK \
-w ${FWK_TOPDIR} \
$(shell echo ${FWK_DOCKER_EXTRA_ARGS}) \
${DOCKER_INT} fwfwk/yocto:$(FWK_YOCTO_RELEASE_TAG) \
--source $(FWK_YOCTO_DIR)/bitbake_env.sh \
--create-user \
--uid ${UID} \
--user ${USERNAME} \
--gid ${GID} \
--group ${GROUPNAME}
endif

.PHONY: yocto yocto_env yocto_bbappend yocto_build

# create bitbake env
yocto_env:
	@mkdir -p $(FWK_YOCTO_DIR)
	@echo "export HISTFILE=$(FWK_YOCTO_BUILD_DIR)/.bash_history" > $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "export TEMPLATECONF=${FWK_YOCTO_TEMPLATECONF}" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "export XZ_DEFAULTS=\"${FWK_YOCTO_WIC_XZ_OPT}\"" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "source $(FWK_YOCTO_INIT_BUILD_ENV) $(FWK_YOCTO_BUILD_DIR)" >> $(FWK_YOCTO_DIR)/bitbake_env.sh
	@echo "export PATH=${FWK_TOPDIR}/fwk/scr/yocto:\$$PATH" >> $(FWK_YOCTO_DIR)/bitbake_env.sh

# download yocto sources
yocto_src: yocto_env
	@mkdir -p $(FWK_YOCTO_SRC)
	cd $(FWK_YOCTO_SRC) && \
	repo init -u $(FWK_YOCTO_MANIFEST_REPO) -m $(FWK_YOCTO_MANIFEST_FILE) -b ${FWK_YOCTO_RELEASE_TAG} && \
	repo sync

# create .conf for yocto build
yocto_conf: yocto_env
	@mkdir -p $(FWK_YOCTO_BUILD_DIR)/conf
	@cp $(FWK_YOCTO_TEMPLATECONF)/local.conf.sample $(FWK_YOCTO_BUILD_DIR)/conf/local.conf
	@echo "# exported config from FWK makefile; !DO NOT EDIT!" >> $(FWK_YOCTO_BUILD_DIR)/conf/local.conf
	@echo "MACHINE=\"${FWK_YOCTO_MACHINE}\"" >> $(FWK_YOCTO_BUILD_DIR)/conf/local.conf
	@cat $(FWK_YOCTO_POST_CFG) >> $(FWK_YOCTO_BUILD_DIR)/conf/local.conf
	@cp $(FWK_YOCTO_SITE_CFG) $(FWK_YOCTO_BUILD_DIR)/conf/site.conf

# create hdf-related recipes
yocto_hdf:
	$(FWK_TOPDIR)/fwk/scr/yocto/hdf_recipe_gen.py -p $(FWK_TOPDIR) -l $(FWK_YOCTO_HDF_DIR) -n $(ProjectName) -m $(FWK_YOCTO_MACHINE)

yocto_bbappend: yocto_hdf
	$(YOCTO_ENV) bitbake-layers add-layer $(FWK_YOCTO_HDF_DIR) $(FWK_YOCTO_BBAPPEND)

yocto: yocto_env yocto_src yocto_conf yocto_hdf yocto_bbappend

yocto_build: yocto_env yocto_conf yocto_hdf
	$(YOCTO_ENV) bitbake $(FWK_YOCTO_IMAGE)
	$(YOCTO_ENV) bitbake package-index

yocto_bash: yocto_env yocto_conf yocto_hdf
	$(YOCTO_ENV) bash

yocto_cleanall: yocto_env yocto_conf yocto_hdf
	$(YOCTO_ENV) bitbake $(FWK_YOCTO_IMAGE) -c cleanall

yocto_clean:
	rm -rf $(FWK_YOCTO_BUILD_DIR)

yocto_sdk: yocto_env yocto_conf yocto_hdf
	$(YOCTO_ENV) bitbake $(FWK_YOCTO_IMAGE) -c populate_sdk

yocto_sdk_ext: yocto_env yocto_conf yocto_hdf
	$(YOCTO_ENV) bitbake $(FWK_YOCTO_IMAGE) -c populate_sdk_ext

yocto_sdcard: yocto_env yocto_conf yocto_hdf
	$(YOCTO_ENV) $(FWK_YOCTO_SDCARD_OPT) bitbake $(FWK_YOCTO_IMAGE)

yocto_fitimage: yocto_env yocto_conf yocto_hdf
	$(YOCTO_ENV) $(FWK_YOCTO_FITIMAGE_OPT) bitbake $(FWK_YOCTO_IMAGE)

