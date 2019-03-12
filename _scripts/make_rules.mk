#      This file is part of the KoraOS project.
#  Copyright (C) 2018  <Fabien Bavent>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as
#  published by the Free Software Foundation, either version 3 of the
#  License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# D E L I V E R I E S -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

define libs
	$(patsubst %,$(libdir)/lib%.$2,$($1))
endef

define llib
DEPS += $(call obj,$2,$1,d)
lib$1: $(libdir)/lib$1.so
$(libdir)/lib$1.a: $(call obj,$2,$1,o) $(call libs,$1_SLIBS,a)
$(libdir)/lib$1.so: $(call obj,$2,$1,o) $(call libs,$1_SLIBS,a) $(call libs,$1_DLIBS,a)
	$(S) mkdir -p $$(dir $$@)
	$(Q) echo "    LD  "$$@
	$(V) $(LD) -shared $($(1)_LFLAGS) -o $$@ $(call obj,$2,$1,o) $(call libs,$1_SLIBS,a) $($(1)_LIBS)
endef

define link
DEPS += $(call obj,$2,$1,d)
$1: $(bindir)/$1
$(bindir)/$1: $(call obj,$2,$1,o) $(call libs,$1_SLIBS,a) $(call libs,$1_DLIBS,so)
	$(S) mkdir -p $$(dir $$@)
	$(Q) echo "    LD  "$$@
	$(V) $(CC) $($(1)_LFLAGS) -o $$@ $(call obj,$2,$1,o) $(call libs,$1_SLIBS,a) $($(1)_LIBS)
endef

define linkp
DEPS += $(call obj,$2,$1,d)
$1: $(bindir)/$1
$(bindir)/$1: $(call obj,$2,$1,o) $(call libs,$1_SLIBS,a) $(call libs,$1_DLIBS,so) $(patsubst $(srcdir)/%.asm,$(outdir)/%.o,$($1_CRT))
	$(S) mkdir -p $$(dir $$@)
	$(Q) echo "    LD  "$$@
	$(V) $(LD) -T $($(1)_SCP) $($(1)_LFLAGS) -o $$@ -Map $$@.map $(call obj,$2,$1,o) $(call libs,$1_SLIBS,a)
endef

define kimg
DEPS += $(call obj,$2,$1,d)
$(kname): $(gendir)/$(kname)
$(gendir)/$(kname): $(call obj,$2,$1,o)
	$(S) mkdir -p $$(dir $$@)
	$(Q) echo "    LD  "$$@
	$(V) $(LD) -T $(topdir)/arch/$(target_arch)/kernel.ld $($(1)_LFLAGS) -o $$@ $(call obj,$2,$1,o)
endef

define ccpl
$(outdir)/$(1)/%.o: $(srcdir)/%.c
	$(S) mkdir -p $$(dir $$@)
	$(Q) echo "    CC  "$$@
	$(V) $(CC) -c $($(1)_CFLAGS) -o $$@ $$<
$(outdir)/$(1)/%.d: $(srcdir)/%.c
	$(S) mkdir -p $$(dir $$@)
	$(Q) echo "    CM  "$$@
	$(V) $(CC) -M $($(1)_CFLAGS) -o $$@ $$<
	@ sed "s%.*\.o%$$(@:.d=.o)%" -i $$@
$(outdir)/$(1)/%.o: $(topdir)/%.c
	$(S) mkdir -p $$(dir $$@)
	$(Q) echo "    CC  "$$@
	$(V) $(CC) -c $($(1)_CFLAGS) -o $$@ $$<
$(outdir)/$(1)/%.d: $(topdir)/%.c
	$(S) mkdir -p $$(dir $$@)
	$(Q) echo "    CM  "$$@
	$(V) $(CC) -M $($(1)_CFLAGS) -o $$@ $$<
	@ sed "s%.*\.o%$$(@:.d=.o)%" -i $$@
endef

define crt
$2: $(outdir)/$2.o
$(outdir)/$1.o: $(srcdir)/$1.asm
	$(S) mkdir -p $$(dir $$@)
	$(Q) echo "    ASM "$$@
	$(V) nasm -f elf32 -o $$@ $$^
endef

$(libdir)/lib%.a:
	$(S) mkdir -p $(dir $@)
	$(Q) echo "    AR  "$@
	$(V) $(AR) src $@ $^

# C O M M O N   T A R G E T S -=-=-=-=-=-=-=-=-=-=-=-=-=-
libs: $(DV_LIBS)
bins: $(DV_UTILS)
tests: $(DV_CHECK)
statics: $(patsubst %,$(gendir)/lib/%.a,$(DV_LIBS))
# install: install_dev install_runtime install_utils
# unistall:
# TODO -- rm $(prefix)/XX (without messing with others libs)
clean:
	$(V) rm -rf $(outdir)
distclean: clean
	$(V) rm -rf $(libdir)
	$(V) rm -rf $(bindir)
config:
# TODO -- Create/update configuration headers
check: | $(patsubst $(bindir)/%,val_%, $(DV_CHECK))

# TODO -- Launch unit tests
.PHONY: all libs utils install unistall
.PHONY: clean distclean config check

# P A C K A G I N G -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
release: $(gendir)/$(NAME)-$(target_arch)-$(VERSION).tar.gz

$(gendir)/$(NAME)-$(target_arch)-$(VERSION).tar.gz: $(DV_UTILS) $(DV_LIBS)
	$(Q) echo "  TAR   $@"
	$(V) tar czf $@  -C $(topdir) $(topdir)/include -C $(gendir) $^

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

SED_LCOV  = -e '/SF:\/usr.*/,/end_of_record/d'
SED_LCOV += -e '/SF:.*\/src\/tests\/.*/,/end_of_record/d'

# Create coverage HTML report
%.lcov: $(bindir)/%
	@ find -name *.gcda | xargs -r rm
	$(V) CK_FORK=no $<
	$(V) lcov --rc lcov_branch_coverage=1 -c --directory . -b . -o $@ >/dev/null
	@ sed $(SED_LCOV) -i $@

cov_%: %.lcov
	$(V) genhtml --rc lcov_branch_coverage=1 -o $@ $< >/dev/null

val_%: $(bindir)/%
	$(V) valgrind --leak-check=full --show-leak-kinds=all $< 2>&1 #| tee $@

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
deps:
	@ echo $(DEPS)

dirs:
	@ echo GPATH: $(GPATH)
	@ echo VPATH: $(VPATH)
	@ echo SPATH: $(SPATH)

delv:
	@ echo LIBS: $(DV_LIBS)
	@ echo UTILS: $(DV_UTILS)

ifeq ($(NODEPS),)
-include $(DEPS)
endif
