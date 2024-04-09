ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += apple-cmds

apple-cmds-setup: setup binpack-setup
	mkdir -p $(BUILD_STAGE)/apple-cmds/ \
		$(BUILD_WORK)/apple-cmds
	cp -a $(BUILD_ROOT)/binpack.c $(BUILD_WORK)/apple-cmds/

ifneq ($(wildcard $(BUILD_WORK)/apple-cmds/.build_complete),)
apple-cmds:
	@echo "Using previously built apple-cmds."
else
apple-cmds: apple-cmds-setup adv-cmds file-cmds kext-tools libarchive network-cmds shell-cmds system-cmds text-cmds remote-cmds
	cp -a $(BUILD_STAGE)/adv-cmds/* $(BUILD_STAGE)/apple-cmds/
	cp -a $(BUILD_STAGE)/file-cmds/* $(BUILD_STAGE)/apple-cmds/
	cp -a $(BUILD_STAGE)/kext-tools/* $(BUILD_STAGE)/apple-cmds/
	cp -a $(BUILD_STAGE)/libarchive/* $(BUILD_STAGE)/apple-cmds/
	cp -a $(BUILD_STAGE)/network-cmds/* $(BUILD_STAGE)/apple-cmds/
	cp -a $(BUILD_STAGE)/shell-cmds/* $(BUILD_STAGE)/apple-cmds/
	cp -a $(BUILD_STAGE)/system-cmds/* $(BUILD_STAGE)/apple-cmds/
	cp -a $(BUILD_STAGE)/text-cmds/* $(BUILD_STAGE)/apple-cmds/
	cp -a $(BUILD_STAGE)/remote-cmds/* $(BUILD_STAGE)/apple-cmds/
	objs=""; \
	for f in $$(find $(BUILD_STAGE)/apple-cmds/ -type f -name '*.lo' -print); do \
		n=$$(basename $$f .lo); \
		sed -i "/%DECLARE%/a extern crunched_stub_t _crunched_$${n}_stub;" $(BUILD_WORK)/apple-cmds/binpack.c; \
		sed -i "/%ENTRYPOINTS%/a { \"$${n}\", _crunched_$${n}_stub }," $(BUILD_WORK)/apple-cmds/binpack.c; \
		objs="$${objs} $$f"; \
	done; \
	for l in $$(find $(BUILD_STAGE)/apple-cmds/ -type l -print); do \
		alias=$$(basename $$l); \
		orig=$$(basename $$(readlink $$l)); \
		sed -i "/%ENTRYPOINTS%/a { \"$${alias}\", _crunched_$${orig}_stub }," $(BUILD_WORK)/apple-cmds/binpack.c; \
	done; \
	$(CC) $(CFLAGS) -c -o $(BUILD_WORK)/apple-cmds/binpack.o $(BUILD_WORK)/apple-cmds/binpack.c -DEXECNAME=\"binpack\"; \
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_WORK)/apple-cmds/binpack $(BUILD_WORK)/apple-cmds/binpack.o $$objs -larchive -lutil -lncurses -lbsm -lbz2 -llzma -lz -framework IOKit -framework CoreFoundation $(BUILD_MISC)/PrivateFrameworks/ktrace.framework/ktrace.tbd
	$(STRIP) $(BUILD_WORK)/apple-cmds/binpack
	install -m755 $(BUILD_WORK)/apple-cmds/binpack $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)/bin/binpack
	for f in $$(find $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)/bin -type f -name '*.lo' -print); do \
		$(LN_SR) $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)/bin/binpack $${f%.lo}; \
		rm $$f; \
	done
	for f in $$(find $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)/sbin -type f -name '*.lo' -print); do \
		$(LN_SR) $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)/bin/binpack $${f%.lo}; \
		rm $$f; \
	done
	for f in $$(find $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin -type f -name '*.lo' -print); do \
		$(LN_SR) $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)/bin/binpack $${f%.lo}; \
		rm $$f; \
	done
	for f in $$(find $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin -type f -name '*.lo' -print); do \
		$(LN_SR) $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)/bin/binpack $${f%.lo}; \
		rm $$f; \
	done
	for f in $$(find $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec -type f -name '*.lo' -print); do \
		$(LN_SR) $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)/bin/binpack $${f%.lo}; \
		rm $$f; \
	done
	$(call AFTER_BUILD)
	$(LDID) -S$(BUILD_ROOT)/binpack.xml $(BUILD_STAGE)/apple-cmds/$(MEMO_PREFIX)/bin/binpack
endif

.PHONY: apple-cmds
