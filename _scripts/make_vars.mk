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
host ?= $(shell uname -m)-pc-linux-gnu
host_arch := $(word 1,$(subst -, ,$(host)))
host_vendor := $(word 2,$(subst -, ,$(host)))
host_os := $(patsubst $(host_arch)-$(host_vendor)-%,%,$(host))

target ?= $(host_arch)-$(host_vendor)-kora
target_arch := $(word 1,$(subst -, ,$(target)))
target_vendor := $(word 2,$(subst -, ,$(target)))
target_os := $(patsubst $(target_arch)-$(target_vendor)-%,%,$(target))


S := @
V := $(shell [ -z $(VERBOSE) ] && echo @)
Q := $(shell [ -z $(QUIET) ] && echo @ || echo @true)

# D I R E C T O R I E S -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
prefix ?= /usr/local
gendir ?= $(shell pwd)
srcdir := $(topdir)/src
outdir := $(gendir)/obj
bindir := $(gendir)/bin
libdir := $(gendir)/lib

# C O M M A N D S -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
CROSS_COMPILE ?= $(CROSS)
AS := $(CROSS_COMPILE)as
AR := $(CROSS_COMPILE)ar
CC := $(CROSS_COMPILE)gcc
CXX := $(CROSS_COMPILE)g++
LD := $(CROSS_COMPILE)ld
NM := $(CROSS_COMPILE)nm

LINUX := $(shell uname -sr)
DATE := $(shell date '+%Y-%b-%d')
GIT := $(shell git --git-dir=$(topdir)/.git rev-parse --short HEAD)$(shell if [ -n "$(git --git-dir=$(topdir)/.git status -suno)"]; then echo '+'; fi)

# A V O I D   D E P E N D E N C Y -=-=-=-=-=-=-=-=-=-=-=-
ifeq ($(shell [ -d $(outdir) ] || echo N ),N)
NODEPS = 1
endif
ifeq ($(MAKECMDGOALS),help)
NODEPS = 1
endif
ifeq ($(MAKECMDGOALS),clean)
NODEPS = 1
endif
ifeq ($(MAKECMDGOALS),distclean)
NODEPS = 1
endif

# D E L I V E R I E S -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
define obj
	$(patsubst $(srcdir)/%.c,$(outdir)/$(1)/%.$(3),   \
	$(patsubst $(srcdir)/%.asm,$(outdir)/$(1)/%.$(3), \
	$(patsubst $(topdir)/%.c,$(outdir)/$(1)/%.$(3), \
	$(patsubst $(topdir)/%.asm,$(outdir)/$(1)/%.$(3), \
	$(patsubst $(topdir)/%.s,$(outdir)/$(1)/%.$(3), \
		$(filter-out $($(2)_omit-y),$($(2)_src-y))      \
	)))))
endef

