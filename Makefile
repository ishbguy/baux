TESTS := test-baux.bats

all : test

.PHONY : test
test :
	bats $(TESTS)
