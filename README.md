# [BAUX](https://github.com/ishbguy/baux)

[![Travis][travissvg]][travis] [![Codecov][codecovsvg]][codecov] [![Codacy][codacysvg]][codacy] [![Version][versvg]][ver] [![License][licsvg]][lic]

[travissvg]: https://travis-ci.org/ishbguy/baux.svg?branch=master
[travis]: https://travis-ci.org/ishbguy/baux
[codecovsvg]: https://codecov.io/gh/ishbguy/baux/branch/master/graph/badge.svg
[codecov]: https://codecov.io/gh/ishbguy/baux
[codacysvg]: https://api.codacy.com/project/badge/Grade/9a7820362a97474b87652d1519714e1b
[codacy]: https://www.codacy.com/app/ishbguy/baux?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ishbguy/baux&amp;utm_campaign=Badge_Grade
[versvg]: https://img.shields.io/badge/version-v0.0.1-lightgrey.svg
[ver]: https://img.shields.io/badge/version-v0.1.0-lightgrey.svg
[licsvg]: https://img.shields.io/badge/license-MIT-green.svg
[lic]: https://github.com/ishbguy/baux/blob/master/LICENSE

**BAUX** is a bash auxiliary library for writing script.

## Table of Contents

+ [:art: Features](#art-features)
+ [:straight_ruler: Prerequisite](#straight_ruler-prerequisite)
+ [:rocket: Installation](#rocket-installation)
+ [:notebook: Usage](#notebook-usage)
+ [:hibiscus: Contributing](#hibiscus-contributing)
+ [:boy: Authors](#boy-authors)
+ [:scroll: License](#scroll-license)

## :art: Features

+ [**Helper**](#helper-functions-bauxsh): Basic script writing helper functions, such as getting script's name, version and help message, importing other script once, warning or exit when get a wrong status. (`baux.sh`)
+ [**Assertion**](#assertion-ensuresh): Functions for writing reliable APIs, ensuring the pre- or post-condition. (`ensure.sh`)
+ [**Utility**](#utility-utilish): Useful utility functions for getting options, reading a simple config file, printing message with color and so on. (`utils.sh`)
+ [**Debugging**](#debugging-logsh-tracesh): Simple functions for logging (`log.sh`) and print callstack when failed (`trace.sh`).
+ [**Testing**](#testing-varsh-testsh): Functions for check a variable (`var.sh`) and writing unit tests (`test.sh`).
+ [**Exception**](#exception-exceptsh): (Not yet finished)
    - `try()`, `catch()`, `throw()`.
+ [**Array**](#array-arraysh): Functions for array manipulation. (`array.sh`)
    - Data structure: stack, queue.
    - Sort and search: `sort()`, `bsearch()`.
+ [**Pattern**](#pattern-patternsh): POSIX compatible characters patterns and other common regex. (`pattern.sh`)
    - Pattern match: IP, URL, tele-number, etc.
    - `is` pattern check.

## :straight_ruler: Prerequisite

> + [`bash`](https://www.gnu.org/software/bash/bash.html)
> + [`sed`](https://www.gnu.org/software/sed/)

## :rocket: Installation

You can get this program with `git`:

```
$ git clone https://github.com/ishbguy/baux
```

## :notebook: Usage

### Library Hierarchy

```bash
lib
├── array.sh    # array manipulate functions
├── baux.sh     # basic helper functions
├── pattern.sh  # POSIX compatible characters patterns and other common regex
├── ensure.sh   # assertion functions
├── except.sh   # not yet finished
├── log.sh      # simple logging
├── test.sh     # unit test functions
├── trace.sh    # simple callstack function
├── utils.sh    # useful tools
└── var.sh      # checking variables
```

### Library Dependence Diagram

```bash
except.sh
    |-----------------------------------------------+
    V                                               |
array.sh    test.sh                                 |
    |           |-----------------------------------|
    V           V                                   V
var.sh      utils.sh    pattern.sh    log.sh      trace.sh
    |           |           |           |           |
    +-----------+-----------+-----------+-----------+
    V
baux.sh <-> ensure.sh
```

### How to Use BAUX Library?

As the [Library Dependence Diagram](#library-dependence-diagram) above, you can easily source one of the library file to include the functions you need, for example:

```bash
# in your script
source /path/to/baux/lib/baux.sh

[[ -e $file ]] || die "$file not exist."
```

### Helper Functions (`baux.sh`)

#### Warning

```bash
# your script
source /path/to/baux/lib/baux.sh

[[ -e $opt_file ]] || warn "Just warn you that $opt_file does not exsit"
[[ -e $need_file ]] || die "$need_file not found! This will exit with $BAUX_EXIT_CODE"

echo "Can not be here."
```

**PS**: Though `warn` runs successfully, it does `return ((++BAUX_EXIT_CODE))` in the end, so `warn` returns an **none-zero** when it finished!

#### Information

```bash
#! /usr/bin/env bash
# your script
source /path/to/baux/lib/baux.sh

echo "The script name is $(proname)" # will print the script name

VERSION="v0.0.1" # need to define VERSION first, or version will warn
echo "The script version is $(version)" # will print the script version

HELP="This is a help message." # need to define HELP first, or usage will warn
usage                          # print help message
```

**PS**: `usage` call `version` first to print version message, then print help message, so, both `VERSION` and `HELP` should be predefined when call `usage`.

#### Importation

`baux.sh` includes an `import` function to ensure source a file for only one time.

```bash
source /path/to/baux/lib/baux.sh

import /path/to/your/lib.sh         # this will import once
import /path/to/your/lib.sh         # OK, but will not import lib.sh again

cmd_from_lib_sh

import /file/not/exsit.sh           # this will fail, and make you script die

echo "Can not be here!"
```

### Assertion (`ensure.sh`)

Assertion functions are useful for writing APIs, and they can be sorted in 3 catogories: general, explicit and implicit assertion.

#### General Assertion

`ensure` can make an assertion with a given expression, if the expression is true, it will continue to run the following commands, or it will die and print a given message.

```bash
source /path/to/baux/lib/ensure.sh

# the first arg is expression, the second arg is error message, which is optional

NUM=1
ensure "$NUM == 1" "$NUM must be equal 1"       # OK
ensure "2 -gt $NUM" "2 must greater than $NUM"  # OK

ensure "$NUM == 1.0" "$NUM must be 1.0"         # this will die, for $NUM act as string '1' not '1.0'
```

The expression given to `ensure` will be `eval [[ $expr ]]` inside `ensure`.

`ensure_not_empty` can test all given args wheather they are not empty, if anyone of them is empty, it will die.

```bash
source /path/to/baux/lib/ensure.sh

one=1
two=2
empty=

ensure_not_empty "$one" "$two"  # OK
ensure_not_empty "$empty"       # will die

echo "Can not be here."
```

It is a best practice to wrap each arg with double qoute.

#### Explicit Assertion

`ensure_is "$1" "$2"` is equivalent to `ensure "$1 == $2".`

```bash
source /path/to/baux/lib/ensure.sh

one=1

ensure_is "$one" "1" "$one is not 1"    # OK
ensure_is "$one" "1.0" "$one is not 1"  # will die

echo "Can not be here."
```

`ensure_isnt "$1" "$2"` is equivalent to `ensure "$1 != $2".`

```bash
source /path/to/baux/lib/ensure.sh

one=1

ensure_isnt "$one" "1.0" "$one is not 1"  # OK
ensure_isnt "$one" "1" "$one is not 1"    # will die

echo "Can not be here."
```

#### Implicit Assertion

`ensure_like "$1" "$2"` is equivalent to `ensure "$1 =~ $2"`

```bash
source /path/to/baux/lib/ensure.sh

str="This is a test"

ensure_like "$str" "a" "$str does not like a"           # OK
ensure_like "$str" "test" "$str does not like test"     # OK

ensure_like "$str" "check" "$str does not like check"   # will die

echo "Can not be here."
```

`ensure_unlike "$1" "$2"` is equivalent to `ensure "! $1 =~ $2"`

```bash
source /path/to/baux/lib/ensure.sh

str="This is a test"

ensure_unlike "$str" "TEST" "$str like TEST"    # OK
ensure_unlike "$str" "IS" "$str like IS"        # OK

ensure_unlike "$str" "test" "$str like test"    # will die

echo "Can not be here."
```

#### Assertion Switch

The `BAUX_ENSURE_DEBUG` variable act as a switch to turn on or off the assertion, its default value is `1`, which means turn on assertion, if you want to turn off, you can set `BAUX_ENSURE_DEBUG` to `0` before sourcing the `ensure.sh`.

###  Utility (`utils.sh`)

#### Get Options

```bash
source /path/to/baux/lib/utils.sh

# need to declare two associative arrays
# one for options and one for arguments

declare -A opts args

# The first arg is array NAME for options
# The second arg is array NAME for arguments
# The third arg is the options string, a letter for an option,
# letter follow with ':' means a option argument
# The remain args are needed to be parsed

getoptions opts args "n:vh" "$@"

# after getoptions, need to correct the option index
shift $((OPTIND - 1))

# now you can check options and arguments
[[ ${opts[h]} -eq 1 ]] && echo "Option 'h' invoke"
[[ ${opts[v]} -eq 1 ]] && echo "Option 'v' invoke"
[[ ${opts[n]} -eq 1 ]] && echo "Option 'n' invoke, argument is ${args[n]}"

# an invoked option will be assigned with 1
# an invoked option with an argument, the argument value will be stored
```

#### Read Config File

```bash
source /path/to/baux/lib/utils.sh

# need to declare an associative array for storing config value
declare -A CONFIGS

# config name and value are seperated with '='
# strings follow '#' means comment
# each line allows one name-value pair
# leading and tailing spaces is allowed
# spaces on both sides of '=' is allowed, too

echo "NAME=ishbguy" >>my.config
echo "EMAIL=ishbguy@hotmail.com" >>my.config

read_config CONFIGS my.config

# you will notice that all config name will convert to lower case
echo "my name is ${CONFIGS[name]}"
echo "my email is ${CONFIGS[email]}"

read_config CONFIGS file-not-exsit # will not fail, just return 1
```

#### Other Utilities

```bash
source /path/to/baux/lib/utils.sh

cecho red "This message will print in red" # color can be: black, red, green
                                           # yellow, blue, magenta, cyan, white

realdir /path/to/script # similar to realpath, this will print /path/to
realdir /p1/script1 /p2/script2 # will print /p1 /p2

check_tool sed awk realpath # check needed tools in PATH
check_tool tools-not-exsit  # will die
```

### Debugging (`log.sh, trace.sh`)

`BAUX` has a simple `log` function which can accept a log level and message string args, then print the log mesages to `stdout` or a specified log file.

`BAUX` also has a simple `callstack` function to print out the call stack when encountering error.

#### Logging (`log.sh`)

```bash
source /path/to/baux/lib/log.sh

# log has 5 log level and priority from low to high is:
#
# debug < info < warn < error < fatal < panic < quiet
#
# default log output level is debug, means that the log priority higher than
# debug will be printed.

log debug "This is a log test"  # this will print a log message to stdout

BAUX_LOG_OUTPUT_LEVEL=info      # set log output level to info
log debug "a debug message"     # will not print
log info "a info message"       # will print into stdout

# set a log output file, default is empty which will print into stdout
# if test.log is not exsit, log will create it

BAUX_LOG_OUTPUT_FILE=test.log   

log info "write into a log file"    # this will write into test.log
```

#### Callstack (`trace.sh`)

```bash
source /path/to/baux/lib/trace.sh

# callstack need a start index of the function stack array
# if index is 0, which will print also the callstack 0, if index is 1,
# which will not print callstack line, and start to print from function
# three.

one() {
    two
}
two() {
    three
}
three() {
    callstack 0
}

one
```

Run the above test script, will print the callstack to stdout like:

```bash
+ callstack 0 [./test.sh:16:three]
  + three [./test.sh:13:two]
    + two [./test.sh:10:one]
      + one [./test.sh:19:main]
```

### Testing (`var.sh, test.sh`)

#### Variable Type Check (`var.sh`)

```bash
source /path/to/baux/lib/var.sh

declare -a var

type_array  var && echo "this is an index array"
type_map    var && echo "this is an associative array"
type_int    var && echo "this is an integer var"
type_func   var && echo "this is a function name"
type_ref    var && echo "this is a var reference"
type_export var && echo "this is an exported var"
type_lower  var && echo "var's value has lower case attribute"
type_upper  var && echo "var's value has upper case attribute"
```

#### Unit Test (`test.sh`)

`BAUX`'s test functions are similar to `Perl`'s [`Test::More`](https://metacpan.org/pod/Test::More) module.

##### Simple test

```bash
source /path/to/baux/lib/test.sh

# ok $expr test is equivalent to [[ $expr ]]
ok '1 == 1' 'Test equal'        # pass
ok '1 != 0' 'Test not equal'    # pass

# is $a $b test is equivalent to [[ $a == $b ]]
is 1 1 "Test equal"             # pass
is 1 0 "Test not equal"         # fail

# isnt $a $b test is equivalent to [[ $a != $b ]]
isnt 1 1 "Test equal"           # fail
isnt 1 0 "Test not equal"       # pass

# like $a $b test is equivalent to [[ $a =~ $b ]]
like "apple" "app" "Test like"      # pass
like "apple" "App" "Test not like"  # fail

# unlike $a $b test is equivalent to [[ ! $a =~ $b ]]
unlike "apple" "app" "Test like"      # fail
unlike "apple" "App" "Test not like"  # pass

# each test status will print when that test finish

# finally, report a summary with the numbers of:
# total, pass, fail and skip
summary
```

##### Run command test with `run_ok`

```bash
source /path/to/baux/lib/test.sh

# run_ok like ok, but run_ok provide $status, $output inside to test the
# exit status and cmd output. When use these 2 variables, you need to single
# quote the expr to avoid expanded outside run_ok. And the given cmd is run
# in a subshell like output=$(eval "$cmd" 2>&1), you can check both nomral
# and error message in $output.

run_ok '$status -eq 0' exit 0       # pass
run_ok '$status -eq 1' exit 1       # pass
run_ok '$output =~ "command not found"' cmd_not_found   # pass
run_ok '$output =~ "hello world"' echo "hello world"    # pass

# you can also do like this for the test statement inside run_ok is equivalent
# to [[ $expr ]]

run_ok '$status -eq 0 && $(echo $output | wc -l) -eq 1' echo "test" # pass

summary
```

##### Run `subtest`

`subtest` will group the your tests in a single sub-test, if one of the tests in `subtest` fails, the `subtest` will fail, and the total and fail counters will increase 1.

```bash
source /path/to/baux/lib/test.sh

# format like: subtest "test name" 'tests cmds'

subtest 'subtest PASS' "
    is 1 1 'test equal'
    isnt 1 0 'test not equal'
"

summary
```

##### `skip` a following test

```bash
source /path/to/baux/lib/test.sh

is 1 1      # pass
skip
isnt 1 1    # this will skip
isnt 0 1    # this will run and pass

summary
```

##### Customize test outputs

You can customize test's total, pass, fail, skip prompt strings and colors.

```bash
source /path/to/baux/lib/test.sh

# these are default prompt strings
BAUX_TEST_PROMPTS[TOTAL]="TOTAL"
BAUX_TEST_PROMPTS[PASS]="PASS"
BAUX_TEST_PROMPTS[FAIL]="FAIL"
BAUX_TEST_PROMPTS[SKIP]="SKIP"

# these are default colors, you can change color which cecho accept
BAUX_TEST_COLORS[TOTAL]="blue"
BAUX_TEST_COLORS[PASS]="green"
BAUX_TEST_COLORS[FAIL]="red"
BAUX_TEST_COLORS[SKIP]="yellow"
BAUX_TEST_COLORS[EMSG]="red"
```

### Exception (`except.sh`)

### Array (`array.sh`)

### Pattern (`pattern.sh`)

## :hibiscus: Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## :boy: Authors

+ [ishbguy](https://github.com/ishbguy)

## :scroll: License

Released under the terms of [MIT License](https://opensource.org/licenses/MIT).
