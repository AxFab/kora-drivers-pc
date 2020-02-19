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
#  This makefile is more or less generic.
#  The configuration is on `sources.mk`.
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
topdir ?= $(shell readlink -f $(dir $(word 1,$(MAKEFILE_LIST))))
gendir ?= $(shell pwd)

include $(topdir)/make/global.mk

all: drivers libs bins

CFLAGS += -Wall -Wextra -fPIC
CFLAGS += -Wno-unused-parameter -Dmain=_main
CFLAGS += -ggdb

include $(topdir)/make/build.mk
include $(topdir)/make/drivers.mk

DRV = ac97 ata e1000 ps2 vga

include $(foreach dir,$(DRV),$(topdir)/$(dir)/Makefile)

drivers: $(DRVS)
libs: $(LIBS)
bins: $(BINS)

install: $(INSTALL_DRVS) $(INSTALL_BINS)

ifeq ($(NODEPS),)
-include $(call fn_deps,SRCS)
endif

