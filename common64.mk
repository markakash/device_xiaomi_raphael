$(call inherit-product, device/xiaomi/raphael/base.mk)

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)

PRODUCT_BRAND := xiaomi

PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=libqti-perfd-client.so \
    persist.backup.ntpServer=0.pool.ntp.org \
    sys.vendor.shutdown.waittime=500

ifneq ($(BOARD_FRP_PARTITION_NAME),)
    PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/bootdevice/by-name/$(BOARD_FRP_PARTITION_NAME)
else
    PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/bootdevice/by-name/config
endif

# whitelisted app
PRODUCT_COPY_FILES += \
    device/xiaomi/raphael/qti_whitelist.xml:system/etc/sysconfig/qti_whitelist.xml

PRODUCT_COPY_FILES += \
    device/xiaomi/raphael/privapp-permissions-qti.xml:system/etc/permissions/privapp-permissions-qti.xml

#copy telephony app's permissions
PRODUCT_COPY_FILES += vendor/qcom/common/telephony/proprietary/product/etc/permissions/telephony_product_privapp-permissions-qti.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/telephony_product_privapp-permissions-qti.xml

PRODUCT_COPY_FILES += vendor/qcom/common/telephony/proprietary/product/etc/permissions/telephony_system-ext_privapp-permissions-qti.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/telephony_system-ext_privapp-permissions-qti.xml

# Permission for Wi-Fi passpoint support
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml

$(call inherit-product, frameworks/native/build/phone-xhdpi-8192-dalvik-heap.mk)
