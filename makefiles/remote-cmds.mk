ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS         += remote-cmds
REMOTE-CMDS_VERSION := 302
LIBTELNET_VERSION   := 13

remote-cmds-setup: setup
	$(call GITHUB_ARCHIVE,apple-oss-distributions,remote_cmds,$(REMOTE-CMDS_VERSION),remote_cmds-$(REMOTE-CMDS_VERSION))
	$(call GITHUB_ARCHIVE,apple-oss-distributions,libtelnet,$(LIBTELNET_VERSION),libtelnet-$(LIBTELNET_VERSION))
	$(call EXTRACT_TAR,remote_cmds-$(REMOTE-CMDS_VERSION).tar.gz,remote_cmds-remote_cmds-$(REMOTE-CMDS_VERSION),remote-cmds)
	$(call EXTRACT_TAR,libtelnet-$(LIBTELNET_VERSION).tar.gz,libtelnet-libtelnet-$(LIBTELNET_VERSION),remote-cmds/libtelnet)
	[ ! -e $(BUILD_WORK)/remote-cmds/telnetd-overrides.diff.done ] && patch -p1 -d $(BUILD_WORK)/remote-cmds < $(BUILD_ROOT)/patches/telnetd-overrides.diff && touch $(BUILD_WORK)/remote-cmds/telnetd-overrides.patch.done || true
	mkdir -p $(BUILD_STAGE)/remote-cmds/$(MEMO_PREFIX)/{private/tftpboot,Library/LaunchDaemons,$(MEMO_SUB_PREFIX)/{bin,libexec,share/man/man{1,8}}}
	sed -i 's/TARGET_OS_OSX/1/g' $(BUILD_WORK)/remote-cmds/telnetd/sys_term.c
	rm -f $(BUILD_WORK)/remote-cmds/{telnetd/{strlcpy,authenc}.c,libtelnet/pk.{c,h}}

ifneq ($(wildcard $(BUILD_WORK)/remote-cmds/.build_complete),)
remote-cmds:
	@echo "Using previously built remote-cmds."
else
remote-cmds: remote-cmds-setup
	mkdir -p $(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/libtelnet
	cd $(BUILD_WORK)/remote-cmds/libtelnet; \
	$(CC) $(CFLAGS) -c *.c -D'__FBSDID=__RCSID' -I. -DHAS_CGETENT -DAUTHENTICATION -DRSA -DFORWARD -DHAVE_STDLIB_H; \
	$(AR) -cr $(BUILD_WORK)/remote-cmds/libtelnet.a *.o; \
	cd $(BUILD_WORK)/remote-cmds; \
		$(CC) -nostdlib -r -Iinclude $$CFLAGS -o $(BUILD_STAGE)/remote-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec/telnetd.lo -DTIOCEXT -DNO_UTMP -DLINEMODE -DKLUDGELINEMODE -DUSE_TERMIO -DOLD_ENVIRON -DENV_HACK -DINET6 -D_PATH_WTMP telnetd/*.c $(BUILD_WORK)/remote-cmds/libtelnet.a;

	$(call SETUP_STUBS)
	$(call AFTER_BUILD)
endif


.PHONY: remote-cmds
