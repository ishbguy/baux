# [BAUX](https://github.com/ishbguy/baux)

[![Travis][travissvg]][travis] [![Codacy][codacysvg]][codacy] [![Version][versvg]][ver] [![License][licsvg]][lic]

[travissvg]: https://travis-ci.org/ishbguy/baux.svg?branch=master
[travis]: https://travis-ci.org/ishbguy/baux
[codacysvg]: https://api.codacy.com/project/badge/Grade/9a7820362a97474b87652d1519714e1b
[codacy]: https://www.codacy.com/app/ishbguy/baux?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ishbguy/baux&amp;utm_campaign=Badge_Grade
[versvg]: https://img.shields.io/badge/version-v0.0.1-lightgrey.svg
[ver]: https://img.shields.io/badge/version-v0.0.1-lightgrey.svg
[licsvg]: https://img.shields.io/badge/license-MIT-green.svg
[lic]: https://github.com/ishbguy/baux/blob/master/LICENSE

**BAUX** is a bash auxiliary library for writing script.

## Table of Contents

+ [:art: Features](#art-features)
+ [:straight_ruler: Prerequisite](#straight_ruler-prerequisite)
+ [:rocket: Installation](#rocket-installation)
+ [:memo: Configuration](#memo-configuration)
+ [:notebook: Usage](#notebook-usage)
+ [:hibiscus: Contributing](#hibiscus-contributing)
+ [:boy: Authors](#boy-authors)
+ [:scroll: License](#scroll-license)

## :art: Features

+ **Helper**: Basic script writing helper functions, such as getting script's name, version and help message, importing other script once, warning or exit when get a wrong status. (`baux.sh`)
+ **Utility**: Useful utility functions for getting options, reading a simple config file, printing message with color and so on. (`utili.sh`)
+ **Assertion**: Functions for writting reliable APIs, ensuring the pre- or post-condition. (`ensure.sh`)
    - pre- or post- condition: `ensure()`, `ensure_not_empty()`.
    - String ensure: `ensure_like()`, `ensure_unlike()`, `ensure_is()`, `ensure_isnt()`.
+ **Debugging**: Simple functions for logging (`log.sh`) and print callstack when failed (`trace.sh`).
    - Logger: `logger()`.
    - Trace: `callstack()`.
+ **Testing**: Functions for check a variable (`var.sh`) and writing unit tests (`test.sh`).
    - `is` variables check: `is_xxx()`.
    - Unit test: `unit_add()`, `unit_run()`, `unit_sum()`, `unit_setup()`, `unit_teardown()`.
+ **Exception**: (Not yet finished)
    - `try()`, `catch()`, `throw()`.
+ **Array**: Functions for array manipulation. (`array.sh`)
    - Data structure: stack, queue.
    - Sort and search: `sort()`, `bsearch()`.
+ **Regex**: POSIX compatible characters patterns and other common regex. (`ctype.sh`)
    - Pattern match: IP, URL, tele-number, etc.
    - `is` pattern check.

## :straight_ruler: Prerequisite

> + [`bash`](https://www.gnu.org/software/bash/bash.html)
> + [`sed`](https://www.gnu.org/software/sed/)
> + realpath

## :rocket: Installation

You can get this program with `git`:

```
$ git clone https://github.com/ishbguy/baux
```

## :memo: Configuration

no.

## :notebook: Usage

### Library Hierarchy

```bash
lib
├── array.sh    # array manipulate functions
├── baux.sh     # basic helper functions
├── ctype.sh    # POSIX compatible characters patterns and other common regex
├── ensure.sh   # assertion functions
├── except.sh   # not yet finished
├── log.sh      # simple logging
├── test.sh     # unit test functions
├── trace.sh    # simple callstack function
├── utili.sh    # useful tools
└── var.sh      # checking variables
```

### Library Dependence Diagram

```bash
except.sh
    |
    V
array.sh    test.sh
    |           |
    V           V
var.sh      utili.sh    ctype.sh    log.sh      trace.sh
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

#### Information

```bash
#! /usr/bin/env bash
# your script
source /path/to/baux/lib/baux.sh

echo "The script name is $(proname)" # will print the script name

VERSION="v0.0.1" # need define VERSION first, or version will warn
echo "The script version is $(version)" # will print the script version

HELP="This is a help message." # need to define HELP first, or usage will warn
usage                          # print help message
```

#### Importation

```bash
source /path/to/baux/lib/baux.sh

import /path/to/your/lib.sh         # this will import once
import /path/to/your/lib.sh         # OK, but will not import lib.sh again

cmd_from_lib_sh
```

###  Utility (`utili.sh`)

#### Get Options

```bash
source /path/to/baux/lib/utili.sh

# need to declare two associative arrays
# one for options and one for arguments
declare -A opts args

# The first arg is array NAME for options
# The second arg is array NAME for arguments
# The third arg is the options string, a letter for an option,
# letter follow with ':' means a option argument
# The remain args are needed to be parse
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
source /path/to/baux/lib/utili.sh

# need to declare an associative array for storing config value
declare -A CONFIGS

echo "NAME=ishbguy" >>my.config
echo "EMAIL=ishbguy@hotmail.com" >>my.config

read_config CONFIGS my.config

# you will notice that all config name will convert to lower case
echo "my name is ${CONFIGS[name]}"
echo "my email is ${CONFIGS[email]}"
```

#### Other Utilities

```bash
source /path/to/baux/lib/utili.sh

cecho red "This message will print in red" # color can be: black, red, green
                                           # yellow, blue, magenta, cyan, white

check_tool sed awk realpath # check needed tools in PATH, or die

realdir /path/to/script # similar to realpath, this will print /path/to
realdir /p1/script1 /p2/script2 # will print /p1 /p2
```

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
