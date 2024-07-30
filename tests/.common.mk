SHELL := bash

BASE := $(shell pwd)

export YSPATH=$(BASE)

FIX := ../../bin/fix-test-output
GEN := ../../bin/gen-expected-results-json


default:

.PHONY: test
test:
	(set -o pipefail; prove -v test/*.ys | $(FIX))

update: expected_results.json

expected_results.json: *.ys test/* Makefile
	$(GEN) $(BASE) > $@.out || true
	mv $@.out $@
