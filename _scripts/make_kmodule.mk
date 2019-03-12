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

CFLAGS += -Wall -Wextra -Wno-unused-parameter -Wno-char-subscripts
CFLAGS += -Wno-multichar -Wno-implicit-fallthrough
CFLAGS += -fno-builtin -ffreestanding -fPIC -nostartfiles
CFLAGS += -D_DATE_=\"'$(DATE)'\" -D_GITH_=\"'$(GIT)'\"

$(krndir) = $(topdir)/../../kernel
__CFLAGS = $(CFLAGS)
__CFLAGS += -I $(krndir)/include
__CFLAGS += -I $(krndir)/arch/$(target_arch)/include
__CFLAGS += -I $(krndir)/os/$(target_os)

$(name)_src-y = $(src-y)
$(eval $(call ccpl,_))
DEPS += $(call obj,_,$(name),d)
objs = $(call obj,_,$(name),o)

$(libdir)/$(name).km:: $(objs)
	$(S) mkdir -p $(dir $@)
	$(Q) echo "    LD  "$@
	$(V) $(CC) --shared $(LFLAGS) -o $@ $(objs)
