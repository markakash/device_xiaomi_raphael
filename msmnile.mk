#####Dynamic partition Handling
####
#### Turning BOARD_DYNAMIC_PARTITION_ENABLE flag to TRUE will enable dynamic partition/super image creation.

ifeq ($(TARGET_FWK_SUPPORTS_FULL_VALUEADDS),true)
  # By default this target is new-launch config, so set the default shipping level to 29 (if not set explictly earlier)
  SHIPPING_API_LEVEL ?= 29

  # Enable Dynamic partitions only for Q new launch devices.
  ifeq ($(SHIPPING_API_LEVEL),29)
    BOARD_DYNAMIC_PARTITION_ENABLE := true
    PRODUCT_SHIPPING_API_LEVEL := 29
  else ifeq ($(SHIPPING_API_LEVEL),28)
    BOARD_DYNAMIC_PARTITION_ENABLE := false
    $(call inherit-product, build/make/target/product/product_launched_with_p.mk)
  endif
endif

ifneq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
# Enable chain partition for system, to facilitate system-only OTA in Treble.
BOARD_AVB_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_SYSTEM_ROLLBACK_INDEX_LOCATION := 1
else
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_PACKAGES += fastbootd
# Add default implementation of fastboot HAL.
PRODUCT_PACKAGES += android.hardware.fastboot@1.0-impl-mock
PRODUCT_COPY_FILES += $(LOCAL_PATH)/fstab_dynamic_partition.qcom:$(TARGET_COPY_OUT_RAMDISK)/fstab.qcom
BOARD_AVB_VBMETA_SYSTEM := system
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
$(call inherit-product, build/make/target/product/gsi_keys.mk)
endif

#####Dynamic partition Handling

# For QSSI builds, we skip building the system image (when value adds are enabled).
# Instead we build the "non-system" images (that we support).

ifeq ($(TARGET_FWK_SUPPORTS_FULL_VALUEADDS),true)
PRODUCT_BUILD_SYSTEM_IMAGE := false
else
PRODUCT_BUILD_SYSTEM_IMAGE := true
endif
PRODUCT_BUILD_SYSTEM_OTHER_IMAGE := false
PRODUCT_BUILD_VENDOR_IMAGE := true
PRODUCT_BUILD_PRODUCT_IMAGE := false
PRODUCT_BUILD_PRODUCT_SERVICES_IMAGE := false
PRODUCT_BUILD_ODM_IMAGE := true
PRODUCT_BUILD_CACHE_IMAGE := false
PRODUCT_BUILD_RAMDISK_IMAGE := true
PRODUCT_BUILD_USERDATA_IMAGE := true

# Also, since we're going to skip building the system image, we also skip
# building the OTA package. We'll build this at a later step. We also don't
# need to build the OTA tools package (we'll use the one from the system build).
TARGET_SKIP_OTA_PACKAGE := true
TARGET_SKIP_OTATOOLS_PACKAGE := true

# Enable AVB 2.0
BOARD_AVB_ENABLE := true

PRODUCT_SOONG_NAMESPACES += \
    hardware/google/av \
    hardware/google/interfaces

# privapp-permissions whitelisting (To Fix CTS :privappPermissionsMustBeEnforced)
ifeq ($(TARGET_FWK_SUPPORTS_FULL_VALUEADDS),true)
PRODUCT_PROPERTY_OVERRIDES += ro.control_privapp_permissions=enforce
endif

TARGET_DEFINES_DALVIK_HEAP := true
TARGET_ENABLE_QC_AV_ENHANCEMENTS := true
$(call inherit-product, device/qcom/qssi/common64.mk)

#Inherit all except heap growth limit from phone-xhdpi-2048-dalvik-heap.mk
PRODUCT_PROPERTY_OVERRIDES  += \
	dalvik.vm.heapstartsize=8m \
	dalvik.vm.heapsize=512m \
	dalvik.vm.heaptargetutilization=0.75 \
	dalvik.vm.heapminfree=512k \
	dalvik.vm.heapmaxfree=8m


PRODUCT_NAME := msmnile
PRODUCT_DEVICE := msmnile
PRODUCT_BRAND := qti
PRODUCT_MODEL := msmnile for arm64

#Initial bringup flags
TARGET_USES_AOSP := false
TARGET_USES_AOSP_FOR_AUDIO := false
TARGET_USES_QCOM_BSP := false

ifeq ($(TARGET_FWK_SUPPORTS_FULL_VALUEADDS),true)
  $(warning "Compiling with full value-added framework")
else
  $(warning "Compiling without full value-added framework - enabling GENERIC_ODM_IMAGE")
  GENERIC_ODM_IMAGE := true
endif

# Enable Codec2.0 HAL as default for pure AOSP variants.
# WA till ODM properties start taking effect
ifeq ($(GENERIC_ODM_IMAGE),true)
  $(warning "Forcing codec2.0 for generic odm build variant")
  PRODUCT_PROPERTY_OVERRIDES += debug.media.codec2=2
  PRODUCT_PROPERTY_OVERRIDES += debug.stagefright.ccodec=4
  PRODUCT_PROPERTY_OVERRIDES += debug.stagefright.omx_default_rank=1000
else
  $(warning "Enabling codec2.0 SW only for non-generic odm build variant")
  #Rank OMX SW codecs lower than OMX HW codecs
  PRODUCT_PROPERTY_OVERRIDES += debug.stagefright.omx_default_rank.sw-audio=1
  PRODUCT_PROPERTY_OVERRIDES += debug.stagefright.omx_default_rank=0
endif

###########
#QMAA flags starts
###########
#QMAA global flag for modular architecture
#true means QMAA is enabled for system
#false means QMAA is disabled for system

TARGET_USES_QMAA := false

#QMAA tech team flag to override global QMAA per tech team
#true means overriding global QMAA for this tech area
#false means using global, no override

TARGET_USES_QMAA_OVERRIDE_DISPLAY := false
TARGET_USES_QMAA_OVERRIDE_AUDIO   := false
TARGET_USES_QMAA_OVERRIDE_VIDEO   := false
TARGET_USES_QMAA_OVERRIDE_CAMERA  := false
TARGET_USES_QMAA_OVERRIDE_GFX     := false
TARGET_USES_QMAA_OVERRIDE_WFD     := false
TARGET_USES_QMAA_OVERRIDE_DATA    := false
TARGET_USES_QMAA_OVERRIDE_GPS     := false

###########
#QMAA flags ends
###########

# RRO configuration
TARGET_USES_RRO := true

###QMAA Indicator Start###

#Full QMAA HAL List
QMAA_HAL_LIST := audio video camera display sensors gps

#Indicator for each enabled QMAA HAL for this target. Each tech team
#locally verified their QMAA HAL and ensure code is updated/merged,
#then add their HAL module name to QMAA_ENABLED_HAL_MODULES as a QMAA
#enabling completion indicator.
QMAA_ENABLED_HAL_MODULES :=

###QMAA Indicator End###

#Default vendor image configuration
ifeq ($(ENABLE_VENDOR_IMAGE),)
ENABLE_VENDOR_IMAGE := false
endif
ifeq ($(ENABLE_VENDOR_IMAGE), true)
#Comment on msm8998 tree says that QTIC does not
# yet support system/vendor split. So disabling it
# for msmnile as well
#TARGET_USES_QTIC := false
#TARGET_USES_QTIC_EXTENSION := false

endif
TARGET_KERNEL_VERSION := 4.14

#Enable llvm support for kernel
KERNEL_LLVM_SUPPORT := true

#Enable sd-llvm suppport for kernel
KERNEL_SD_LLVM_SUPPORT := true

# default is nosdcard, S/W button enabled in resource
PRODUCT_CHARACTERISTICS := nosdcard

BOARD_FRP_PARTITION_NAME := frp

#Android EGL implementation
PRODUCT_PACKAGES += libGLES_android

-include $(QCPATH)/common/config/qtic-config.mk

# Video seccomp policy files
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/seccomp/codec2.software.ext.policy:$(TARGET_COPY_OUT)/etc/seccomp_policy/codec2.software.ext.policy \

PRODUCT_BOOT_JARS += tcmiface

#ifneq ($(strip $(QCPATH)),)
#    PRODUCT_BOOT_JARS += WfdCommon
#endif

PRODUCT_PACKAGES += android.hardware.media.omx@1.0-impl

# Camera configuration file. Shared by passthrough/binderized camera HAL
PRODUCT_PACKAGES += camera.device@3.2-impl
PRODUCT_PACKAGES += camera.device@1.0-impl
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-impl
# Enable binderized camera HAL
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-service_64

# Audio configuration file
-include $(TOPDIR)vendor/qcom/opensource/audio-hal/primary-hal/configs/msmnile/msmnile.mk

#Audio DLKM
AUDIO_DLKM := audio_apr.ko
AUDIO_DLKM += audio_wglink.ko
AUDIO_DLKM += audio_q6_pdr.ko
AUDIO_DLKM += audio_q6_notifier.ko
AUDIO_DLKM += audio_adsp_loader.ko
AUDIO_DLKM += audio_q6.ko
AUDIO_DLKM += audio_usf.ko
AUDIO_DLKM += audio_pinctrl_wcd.ko
AUDIO_DLKM += audio_swr.ko
AUDIO_DLKM += audio_wcd_core.ko
AUDIO_DLKM += audio_swr_ctrl.ko
AUDIO_DLKM += audio_wsa881x.ko
AUDIO_DLKM += audio_platform.ko
AUDIO_DLKM += audio_hdmi.ko
AUDIO_DLKM += audio_stub.ko
AUDIO_DLKM += audio_wcd9xxx.ko
AUDIO_DLKM += audio_mbhc.ko
AUDIO_DLKM += audio_wcd9360.ko
AUDIO_DLKM += audio_wcd_spi.ko
AUDIO_DLKM += audio_native.ko
AUDIO_DLKM += audio_machine_msmnile.ko
AUDIO_DLKM += audio_wcd934x.ko
PRODUCT_PACKAGES += $(AUDIO_DLKM)

PRODUCT_PACKAGES += fs_config_files

#A/B related packages
PRODUCT_PACKAGES += update_engine \
    update_engine_client \
    update_verifier \
    bootctrl.msmnile \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service

PRODUCT_HOST_PACKAGES += \
    brillo_update_payload \
    configstore_xmlparser

#Boot control HAL test app
PRODUCT_PACKAGES_DEBUG += bootctl

PRODUCT_STATIC_BOOT_CONTROL_HAL := \
  bootctrl.msmnile \
  librecovery_updater_msm \
  libz \
  libcutils

PRODUCT_PACKAGES += \
  update_engine_sideload

#Healthd packages
PRODUCT_PACKAGES += \
    libhealthd.msm

# Fingerprint feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml \

# Ipsec_tunnels feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \

DEVICE_MANIFEST_FILE := device/qcom/msmnile/manifest.xml
DEVICE_MATRIX_FILE   := device/qcom/common/compatibility_matrix.xml
DEVICE_FRAMEWORK_MANIFEST_FILE := device/qcom/msmnile/framework_manifest.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := vendor/qcom/opensource/core-utils/vendor_framework_compatibility_matrix.xml

#audio related module
PRODUCT_PACKAGES += libvolumelistener

# Display/Graphics
PRODUCT_PACKAGES += \
    android.hardware.configstore@1.1-service \
    android.hardware.broadcastradio@1.0-impl

# MSM IRQ Balancer configuration file
PRODUCT_COPY_FILES += device/qcom/msmnile/msm_irqbalance.conf:$(TARGET_COPY_OUT_VENDOR)/etc/msm_irqbalance.conf

# Powerhint configuration file
PRODUCT_COPY_FILES += device/qcom/msmnile/powerhint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.xml


# Vibrator
PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator@1.2-service

# Context hub HAL
PRODUCT_PACKAGES += \
    android.hardware.contexthub@1.0-impl.generic \
    android.hardware.contexthub@1.0-service

#vendor prop to enable advanced network scanning
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.enableadvancedscan=true

# system prop for enabling QFS (QTI Fingerprint Solution)
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.qfp=true

# MIDI feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

# Pro Audio feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.pro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.pro.xml

# USB default HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service

#PASR HAL and APP
PRODUCT_PACKAGES += \
    vendor.qti.power.pasrmanager@1.0-service \
    vendor.qti.power.pasrmanager@1.0-impl \
    pasrservice

# Sensor conf files
PRODUCT_COPY_FILES += \
    device/qcom/msmnile/sensors/hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/hals.conf \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.sensor.ambient_temperature.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.ambient_temperature.xml \
    frameworks/native/data/etc/android.hardware.sensor.relative_humidity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.relative_humidity.xml \
    frameworks/native/data/etc/android.hardware.sensor.hifi_sensors.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.hifi_sensors.xml


# Kernel modules install path
KERNEL_MODULES_INSTALL := dlkm
KERNEL_MODULES_OUT := out/target/product/$(PRODUCT_NAME)/$(KERNEL_MODULES_INSTALL)/lib/modules

#FEATURE_OPENGLES_EXTENSION_PACK support string config file
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml

#Exclude vibrator from InputManager
PRODUCT_COPY_FILES += \
    device/qcom/msmnile/excluded-input-devices.xml:system/etc/excluded-input-devices.xml

#Enable full treble flag
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VENDOR_MOVE_ENABLED := true
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

ifneq ($(strip $(TARGET_USES_RRO)),true)
DEVICE_PACKAGE_OVERLAYS += device/qcom/msmnile/overlay
endif


#Enable vndk-sp Libraries
PRODUCT_PACKAGES += vndk_package

PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE:=true

#----------------------------------------------------------------------
# wlan specific
#----------------------------------------------------------------------
include device/qcom/wlan/msmnile/wlan.mk

TARGET_MOUNT_POINTS_SYMLINKS := false

TARGET_USES_MKE2FS := true

PRODUCT_PROPERTY_OVERRIDES += \
ro.crypto.volume.filenames_mode = "aes-256-cts" \
ro.crypto.allow_encrypt_override = true

ifneq ($(GENERIC_ODM_IMAGE),true)
    PRODUCT_COPY_FILES += device/qcom/msmnile/manifest-qva.xml:$(TARGET_COPY_OUT_ODM)/etc/vintf/manifest.xml
else
    PRODUCT_COPY_FILES += device/qcom/msmnile/manifest-generic.xml:$(TARGET_COPY_OUT_ODM)/etc/vintf/manifest.xml
endif
###################################################################################
# This is the End of target.mk file.
# Now, Pickup other split product.mk files:
###################################################################################
# TODO: Relocate the system product.mk files pickup into qssi lunch, once it is up.
$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/system/*.mk)
$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/vendor/*.mk)
###################################################################################
