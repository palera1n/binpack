ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += dropbear
DROPBEAR_VERSION := 2022.83

dropbear-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://github.com/mkj/dropbear/archive/DROPBEAR_$(DROPBEAR_VERSION).tar.gz)
	$(call EXTRACT_TAR,DROPBEAR_$(DROPBEAR_VERSION).tar.gz,dropbear-DROPBEAR_$(DROPBEAR_VERSION),dropbear)
	$(call DO_PATCH,dropbear,dropbear,-p1)
	[ ! -e $(BUILD_WORK)/dropbear/dropbear-overrides.patch.done ] && patch -p1 -d $(BUILD_WORK)/dropbear < $(BUILD_ROOT)/patches/dropbear-overrides.patch && touch $(BUILD_WORK)/dropbear/dropbear-overrides.patch.done || true

ifneq ($(wildcard $(BUILD_WORK)/dropbear/.build_complete),)
dropbear:
	@echo "Using previously built dropbear."
else
dropbear: dropbear-setup
	if ! [ -f $(BUILD_WORK)/dropbear/configure ]; then \
		cd $(BUILD_WORK)/dropbear && autoreconf -i; \
	fi
	cd $(BUILD_WORK)/dropbear && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-lastlog \
		--disable-utmp \
		--disable-utmpx \
		--disable-wtmp \
		--disable-wtmpx \
		--disable-loginfunc \
		--disable-pututline \
		--disable-pututxline \
		--disable-static \
		LDFLAGS="$(LDFLAGS) -fPIE -pie" \
		CFLAGS="$(CFLAGS) -DDEFAULT_PATH=\"\\\"$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/local/sbin:$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/local/bin:$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin:$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin:$(MEMO_PREFIX)/sbin:$(MEMO_PREFIX)/bin\\\"\""
	+$(MAKE) -C $(BUILD_WORK)/dropbear MULTI=1 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp"
	+$(MAKE) -C $(BUILD_WORK)/dropbear inst_dropbearmulti MULTI=1 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" \
		DESTDIR="$(BUILD_STAGE)/dropbear"
	$(LN_S) dropbearmulti $(BUILD_STAGE)/dropbear/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/dbclient
	$(LN_S) dropbearmulti $(BUILD_STAGE)/dropbear/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/dropbearconvert
	$(LN_S) dropbearmulti $(BUILD_STAGE)/dropbear/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/dropbearkey
	$(LN_S) dropbearmulti $(BUILD_STAGE)/dropbear/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/scp
	# ssh is just an alias for dbclient
	$(LN_S) dropbearmulti $(BUILD_STAGE)/dropbear/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/ssh
	$(LN_S) ../bin/dropbearmulti $(BUILD_STAGE)/dropbear/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/dropbear
	mkdir -p $(BUILD_STAGE)/dropbear/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/
	cp $(BUILD_ROOT)/dropbear.plist $(BUILD_STAGE)/dropbear/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/dropbear.plist.example
	$(call AFTER_BUILD)
	$(call BINPACK_SIGN,general.xml)
endif

.PHONY: dropbear
