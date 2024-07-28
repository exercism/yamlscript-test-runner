SHELL := bash

ROOT := $(shell pwd)

BIN := $(ROOT)/bin
SHELLCHECK := $(BIN)/shellcheck

export PATH := $(BIN):$(PATH)

SHELL_FILES := $(shell find . -name '*.sh')

SHELLCHECK_VERSION := v0.10.0
SHELLCHECK_REPO := https://github.com/koalaman/shellcheck
SHELLCHECK_RELEASES := $(SHELLCHECK_REPO)/releases/download
SHELLCHECK_DIR := shellcheck-$(SHELLCHECK_VERSION)
SHELLCHECK_TAR := $(SHELLCHECK_DIR).linux.x86_64.tar.xz
SHELLCHECK_RELEASE := \
  $(SHELLCHECK_RELEASES)/$(SHELLCHECK_VERSION)/$(SHELLCHECK_TAR)


default:

test: test-shellcheck

clean:
	$(RM) -r shellcheck*

realclean: clean
	$(RM) $(SHELLCHECK)

test-shellcheck: $(SHELLCHECK)
	@echo '*** Testing shell files pass shellcheck'
	$< $(SHELL_FILES)
	@echo '*** All shell files are OK'
	@echo

ifeq (,$(wildcard $(SHELLCHECK)))
$(SHELLCHECK): $(SHELLCHECK_DIR)
	mv $</shellcheck $@
	touch $@
	$(RM) -r $<
	$(RM) $(SHELLCHECK_TAR)
endif

$(SHELLCHECK_DIR): $(SHELLCHECK_TAR)
	tar xf $<

$(SHELLCHECK_TAR):
	wget $(SHELLCHECK_RELEASE)
