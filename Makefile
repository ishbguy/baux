TEST_DIR := $(PWD)/test

all : bats

.PHONY : bats
bats :
	bats $(TEST_DIR)/bats
