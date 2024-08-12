SHELL := bash

ROOT := $(shell pwd)

BIN := $(ROOT)/bin
SHELLCHECK := $(BIN)/shellcheck

export PATH := $(BIN):$(PATH)

EXPECTED_RESULTS_FILES := \
  $(shell find . -name expected_results.json)

SHELL_FILES := $(shell find . -name '*.sh')

SHELLCHECK_VERSION := v0.10.0
SHELLCHECK_REPO := https://github.com/koalaman/shellcheck
SHELLCHECK_RELEASES := $(SHELLCHECK_REPO)/releases/download
SHELLCHECK_DIR := shellcheck-$(SHELLCHECK_VERSION)
SHELLCHECK_TAR := $(SHELLCHECK_DIR).linux.x86_64.tar.xz
SHELLCHECK_RELEASE := \
  $(SHELLCHECK_RELEASES)/$(SHELLCHECK_VERSION)/$(SHELLCHECK_TAR)

DOCKER_USER := ingy
DOCKER_VERSION := 0.0.1
DOCKER_NAME := exercism-$(shell basename $(ROOT))
DOCKER_IMAGE := $(DOCKER_USER)/$(DOCKER_NAME):$(DOCKER_VERSION)


default:

test: test-shellcheck

update: $(EXPECTED_RESULTS_FILES)

clean:
	$(RM) -r shellcheck*

realclean: clean
	$(RM) $(SHELLCHECK)

tests/%/expected_results.json: tests/%
	$(MAKE) -C $< $(@:$</%=%)

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
	curl -sSOL $(SHELLCHECK_RELEASE)

docker-build:
	docker build --tag=$(DOCKER_IMAGE) .

docker-push: docker-build
	docker push $(DOCKER_IMAGE)
