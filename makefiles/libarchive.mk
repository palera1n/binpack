ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS        += libarchive
LIBARCHIVE_VERSION := 54.250.1

libarchive-setup: setup binpack-setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,libarchive,$(LIBARCHIVE_VERSION),libarchive-$(LIBARCHIVE_VERSION))
	$(call EXTRACT_TAR,libarchive-$(LIBARCHIVE_VERSION).tar.gz,libarchive-libarchive-$(LIBARCHIVE_VERSION),libarchive)
	cp -a $(BUILD_MISC)/config.sub $(BUILD_WORK)/libarchive/libarchive
	mkdir -p $(BUILD_STAGE)/libarchive/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin

ifneq ($(wildcard $(BUILD_WORK)/libarchive/.build_complete),)
libarchive:
	@echo "Using previously built libarchive."
else
libarchive: libarchive-setup
	cd $(BUILD_WORK)/libarchive/libarchive/tar && \
		$(CC) $(CFLAGS) -I../.. -I../libarchive -I../libarchive_fe \
		bsdtar.c cmdline.c read.c subst.c util.c write.c tree.c getdate.c \
		../libarchive_fe/err.c ../libarchive_fe/line_reader.c ../libarchive_fe/matching.c \
		../libarchive_fe/pathmatch.c \
		-r -nostdlib $(BUILD_MISC)/tar/archive_stubs.c \
		-o $(BUILD_STAGE)/libarchive/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/tar.lo
	$(LN_S) tar $(BUILD_STAGE)/libarchive/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/bsdtar
	$(call SETUP_STUBS)
	$(call AFTER_BUILD)
	#$(call BINPACK_SIGN,general.xml)
endif

.PHONY: libarchive
