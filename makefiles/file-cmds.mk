ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))

STRAPPROJECTS     += file-cmds
FILE-CMDS_VERSION := 400

file-cmds-setup: setup binpack-setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,file_cmds,$(FILE-CMDS_VERSION),file_cmds-$(FILE-CMDS_VERSION))
	$(call EXTRACT_TAR,file_cmds-$(FILE-CMDS_VERSION).tar.gz,file_cmds-file_cmds-$(FILE-CMDS_VERSION),file-cmds)
	[ ! -e $(BUILD_WORK)/file-cmds/file_cmds-mv.diff.done ] && patch -p1 -d $(BUILD_WORK)/file-cmds < $(BUILD_ROOT)/patches/file_cmds-mv.diff && touch $(BUILD_WORK)/file-cmds/file_cmds-mv.diff.done || true
	sed -i '/libutil.h/ s/$$/\nint expand_number(const char *buf, uint64_t *num);/' $(BUILD_WORK)/file-cmds/du/du.c
	sed -i 's/strcmp(progname, "gunzip") == 0/& || strcmp(progname, "xzdec") == 0 || strcmp(progname, "bunzip2") == 0/' $(BUILD_WORK)/file-cmds/gzip/gzip.c
	rm -f $(BUILD_WORK)/file-cmds/dd/gen.c
	mkdir -p $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX){,$(MEMO_SUB_PREFIX)}/{,s}bin

ifneq ($(wildcard $(BUILD_WORK)/file-cmds/.build_complete),)
file-cmds:
	@echo "Using previously built file-cmds."
else
file-cmds: file-cmds-setup bzip2 xz
	$(CC) $(CFLAGS) -r -nostdlib -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)/sbin/mknod.lo $(BUILD_WORK)/file-cmds/mknod/{mknod,pack_dev}.c
	$(CC) $(CFLAGS) -r -nostdlib -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/chflags.lo $(BUILD_WORK)/file-cmds/chflags/chflags.c
	$(CC) $(CFLAGS) -r -nostdlib -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/chown.lo $(BUILD_WORK)/file-cmds/chown/chown.c
	for tool in chmod cp dd ln ls mkdir mv rm rmdir; do \
		EXTRA_CFLAGS=""; \
		if [ "$$tool" = "ls" ]; then \
			EXTRA_CFLAGS="-DCOLORLS"; \
		fi; \
		$(CC) $(CFLAGS) $$EXTRA_CFLAGS -r -nostdlib -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)/bin/$$tool.lo $(BUILD_WORK)/file-cmds/$$tool/*.c -D'__FBSDID(x)=' -D__POSIX_C_SOURCE; \
	done
	for tool in du gzip stat; do \
		EXTRA_CFLAGS=""; \
		if [ "$$tool" = "gzip" ]; then \
			EXTRA_CFLAGS='-DGZIP_APPLE_VERSION="321.40.3"'; \
		fi; \
		$(CC) $(CFLAGS) $$EXTRA_CFLAGS -r -nostdlib -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/$$tool.lo $(BUILD_WORK)/file-cmds/$$tool/$$tool.c -D'__FBSDID(x)=' -D__POSIX_C_SOURCE; \
	done
	$(LN_S) gzip $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/gunzip
	$(LN_S) gzip $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/xzdec
	$(LN_S) gzip $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/bunzip2
	$(CC) $(CFLAGS) -r -nostdlib -o $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/xattr.lo $(BUILD_WORK)/file-cmds/xattr/xattr.c
	$(call SETUP_STUBS)
	$(call AFTER_BUILD)
	#$(call BINPACK_SIGN,general.xml)
	#$(LDID) -Hsha256 -S$(BUILD_MISC)/entitlements/dd.xml $(BUILD_STAGE)/file-cmds/$(MEMO_PREFIX)/bin/dd
endif

.PHONY: file-cmds

endif # ($(MEMO_TARGET),darwin-\*)
