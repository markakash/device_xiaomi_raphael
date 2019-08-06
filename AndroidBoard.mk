LOCAL_PATH := $(call my-dir)

#----------------------------------------------------------------------
# Compile (L)ittle (K)ernel bootloader and the nandwrite utility
#----------------------------------------------------------------------
ifneq ($(strip $(TARGET_NO_BOOTLOADER)),true)

# Compile
include bootable/bootloader/edk2/AndroidBoot.mk

$(INSTALLED_BOOTLOADER_MODULE): $(TARGET_EMMC_BOOTLOADER) | $(ACP)
	$(transform-prebuilt-to-target)
$(BUILT_TARGET_FILES_PACKAGE): $(INSTALLED_BOOTLOADER_MODULE)

droidcore: $(INSTALLED_BOOTLOADER_MODULE)
endif

ifeq ($(TARGET_KERNEL_SOURCE),)
     TARGET_KERNEL_SOURCE := kernel
endif

DTC := $(HOST_OUT_EXECUTABLES)/dtc$(HOST_EXECUTABLE_SUFFIX)
UFDT_APPLY_OVERLAY := $(HOST_OUT_EXECUTABLES)/ufdt_apply_overlay$(HOST_EXECUTABLE_SUFFIX)

# Record current directory to handle invoking sub-makes with -C
# TODO(b/112561200) creating the TEMP_TOP variable undoes the intent of
# removing ANDROID_BUILD_TOP, but it allows the build to succeed.
TEMP_TOP=$(shell pwd)
TARGET_KERNEL_MAKE_ENV := DTC_EXT=$(TEMP_TOP)/$(DTC)
TARGET_KERNEL_MAKE_ENV += DTC_OVERLAY_TEST_EXT=$(TEMP_TOP)/$(UFDT_APPLY_OVERLAY)
TARGET_KERNEL_MAKE_ENV += CONFIG_BUILD_ARM64_DT_OVERLAY=y
TARGET_KERNEL_MAKE_ENV += HOSTCC=$(TEMP_TOP)/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-gcc
TARGET_KERNEL_MAKE_ENV += HOSTAR=$(TEMP_TOP)/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-ar
TARGET_KERNEL_MAKE_ENV += HOSTLD=$(TEMP_TOP)/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-ld
TARGET_KERNEL_MAKE_ENV += HOSTCFLAGS="-I$$(pwd)/kernel/msm-4.14/include/uapi -I/usr/include -I/usr/include/x86_64-linux-gnu -L/usr/lib -L/usr/lib/x86_64-linux-gnu"
TARGET_KERNEL_MAKE_ENV += HOSTLDFLAGS="-L/usr/lib -L/usr/lib/x86_64-linux-gnu"

include $(TARGET_KERNEL_SOURCE)/AndroidKernel.mk
$(TARGET_PREBUILT_KERNEL): $(DTC) $(UFDT_APPLY_OVERLAY)

$(INSTALLED_KERNEL_TARGET): $(TARGET_PREBUILT_KERNEL) | $(ACP)
	$(transform-prebuilt-to-target)

#----------------------------------------------------------------------
# Copy additional target-specific files
#----------------------------------------------------------------------
include $(CLEAR_VARS)
LOCAL_MODULE       := vold.fstab
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.target.rc
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := $(LOCAL_MODULE)
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)/init/hw
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := gpio-keys.kl
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := $(LOCAL_MODULE)
LOCAL_MODULE_PATH  := $(TARGET_OUT_KEYLAYOUT)
include $(BUILD_PREBUILT)

ifeq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
include $(CLEAR_VARS)
LOCAL_MODULE       := fstab.qcom
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := fstab_dynamic_partition.qcom
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)
include $(BUILD_PREBUILT)
else
include $(CLEAR_VARS)
LOCAL_MODULE       := fstab.qcom
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := $(LOCAL_MODULE)
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)
ifeq ($(ENABLE_VENDOR_IMAGE), true)
LOCAL_POST_INSTALL_CMD := echo $(VENDOR_FSTAB_ENTRY) >> $(LOCAL_MODULE_PATH)/$(LOCAL_MODULE)
endif
include $(BUILD_PREBUILT)
endif

#----------------------------------------------------------------------
# Radio image
#----------------------------------------------------------------------
ifeq ($(ADD_RADIO_FILES), true)
radio_dir := $(LOCAL_PATH)/radio
RADIO_FILES := $(shell cd $(radio_dir) ; ls)
$(foreach f, $(RADIO_FILES), \
	$(call add-radio-file,radio/$(f)))
endif

#----------------------------------------------------------------------
# extra images
#----------------------------------------------------------------------
#ifeq (, $(wildcard vendor/qcom/build/tasks/generate_extra_images.mk))
include device/qcom/common/generate_extra_images.mk
#endif

#----------------------------------------------------------------------
# wlan specific
#----------------------------------------------------------------------
ifeq ($(strip $(BOARD_HAS_QCOM_WLAN)),true)
include device/qcom/wlan/msmnile/AndroidBoardWlan.mk
endif

#----------------------------------------------------------------------
# override default make with prebuilt make path (if any)
#----------------------------------------------------------------------
ifneq (, $(wildcard $(shell pwd)/prebuilts/build-tools/linux-x86/bin/make))
    MAKE := $(shell pwd)/prebuilts/build-tools/linux-x86/bin/$(MAKE)
endif
