TEST_DIR := $(PWD)/test

all : bats self

.PHONY : bats
bats :
	bats $(TEST_DIR)/bats

.PHONY : self
self :
	$(PWD)/lib-exec/baux-test.sh $(TEST_DIR)/self
