ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS += xz
XZ_VERSION    := 5.4.6

xz-setup: binpack-setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://fossies.org/linux/misc/xz-5.4.6.tar.xz)
	#$(call PGP_VERIFY,xz-$(XZ_VERSION).tar.xz)
	$(call EXTRACT_TAR,xz-$(XZ_VERSION).tar.xz,xz-$(XZ_VERSION),xz)

ifneq ($(wildcard $(BUILD_WORK)/xz/.build_complete),)
xz:
	@echo "Using previously built xz."
else
xz: xz-setup
	cd $(BUILD_WORK)/xz && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-shared \
		--disable-static \
		--disable-xz \
		--disable-xzdec \
		--disable-scripts \
		--disable-nls \
		--disable-encoders \
		--disable-threads \
		--disable-liblzma2-compat \
		--disable-lzmainfo \
		--disable-lzmadec \
		--disable-lzma-links
	+$(MAKE) -C $(BUILD_WORK)/xz install \
		DESTDIR=$(BUILD_STAGE)/xz
	$(call AFTER_BUILD,copy)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: xz
