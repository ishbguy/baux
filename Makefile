TEST_DIR := $(shell pwd)/test

all : test

.PHONY : test
test :
	bats $(TEST_DIR)
