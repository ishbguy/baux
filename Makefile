TEST_DIR := $(PWD)/test

all : bats self

.PHONY : bats
bats :
	bats $(TEST_DIR)/bats

.PHONY : self
self :
	$(PWD)/bin/baux-test.sh $(TEST_DIR)/self
