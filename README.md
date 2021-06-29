# local-bin


## General

This is a collection of various unrelated `bash`, `perl`, and `fish` scripts.

The scripts had initially been written for *Arch Linux*. Some may not work
out of the box on every machine as some files could reside at different
locations or some software may not be present on the system, at all.
A lot of scripts are wrappers around other Linux command line tools, some
are almost one-liners and only few are a little bit more sophisticated somehow.

All scripts are licensed under the **GNU General Public License**, version 3.

The source code of the scripts can be used as example to write tools working
for specific platforms and/or configurations.


## Installation

First, this repository needs to be cloned to a local directory. Then, scripts
being used may be made executable.

In order to *install* scripts, they may be placed (or linked) under `/usr/bin`,
or `/usr/local/bin`, with their filename extension stripped.

For example, to use the tool `battery.pl`, it can be installed by running:

```
$ git clone https://github.com/mcrbt/local-bin.git
$ chmod 755 battery.pl
$ cp $(pwd)/local-bin/battery.pl /usr/local/bin/battery
```

To get the battery status, `battery.pl` can then simply be run as:

```
$ battery
```

Alternatively, a symbolic link to the script may be created, which would
do the same trick:

```
$ ln -sv $(pwd)/local-bin/battery.pl /usr/local/bin/battery
```


## Description

The collection currently contains the following **31 scripts**:

* [**`adapt.pl`**](https://github.com/mcrbt/local-bin/blob/master/adapt.pl)
    - adapt names of foreign files for use with Linux filesystems
    - whitespaces and lots of special characters are replaced with underscore
      ("\_"), German umlauts and other graphemes are converted to their ASCII
      representation (e.g. "ä"->"ae", "â"->"a", ...)
    - depends on: `perl`

* [**`aphwaddr.sh`**](https://github.com/mcrbt/local-bin/blob/master/aphwaddr.sh)
    - print hardware address (i.e. *MAC address*) of the wireless
      access point currently connected to
    - depends on: `awk`, `basename`, `bash`, `grep`, `ip`, `iw`

* [**`battery.pl`**](https://github.com/mcrbt/local-bin/blob/master/battery.pl)
    - print capacity (percentage) of one or two installed batteries,
      along with their charging status
    - if two batteries are installed, a cumulated capacity is calculated
    - *design capacity* is used as maximium, thus *100%* may never be
      reached (this can be changed easily)
    - the path of the battery system files may be changed accordingly
    - depends on: `perl`

* [**`cfgsync.sh`**](https://github.com/mcrbt/local-bin/blob/master/cfgsync.sh)
    - copy e.g. configuration files of user `root` to all other user's home
      directories
    - configuration directories (e.g. `.config/openbox/`) can be copied recursively
    - intended for single user systems with an additional non-privileged
      user, e.g. to execute riskier tasks
    - allows to only modify the configuration file of user `root`, and afterwards
      "synchronize" with all other user accounts having a home directory under
      `/home/`
    - configuration is to be done within the script using the global constant
      `QUIET` to control *verbosity*, and `SYNC_LIST` for a space (" ")
      separated list of filenames (with or without `/root/` prefix)
    - *alternatively*, files (resp. directories) can be provided via command
      line, each as its own argument (e.g. `$ cfgsync .bashrc .xinitrc`; see
      `$ cfgsync --help` for details)
    - **CAUTION**: the script is intended to
      **override existing configuration files** of local users
    - depends on: `basename`, `bash`, `cp`, `dirname`, `mkdir`

* [**`clfish.fish`**](https://github.com/mcrbt/local-bin/blob/master/clfish.fish)
    - clear command history of the `fish` shell (i.e. *friendly interactive shell*)
    - if `fish` is used within a `bash` environment, an additional command
      for clearing `bash`'s history can be added, as well (see
      [`histdel.sh`](https://github.com/mcrbt/local-bin/blob/master/histdel.sh),
      for instance)
    - depends on: `fish`

* [**`cpall.sh`**](https://github.com/mcrbt/local-bin/blob/master/cpall.sh)
    - copy multiple files from one location to another, while optionally
      prepending, or appending, a prefix, or suffix, to the copied files
    - depends on: `basename`, `bash`, `cp`

* [**`ddg.sh`**](https://github.com/mcrbt/local-bin/blob/master/ddg.sh)
    - open `firefox` and search a pattern with *DuckDuckGo* search engine
      from command line
    - depends on: `bash`, `firefox`, `sed`

* [**`dictcc.sh`**](https://github.com/mcrbt/local-bin/blob/master/dictcc.sh)
    - translate a pattern on [https://www.dict.cc](https://www.dict.cc)
    - the pattern is supplied as command line arguments and can consist of
      multiple words (i.e. multiple arguments)
    - the web browser may be configured, by altering the variable `BROWSER`
      (defaults to `firefox`)
    - depends on: `bash`, `firefox`, `sed`

* [**`dns.sh`**](https://github.com/mcrbt/local-bin/blob/master/dns.sh)
    - retrieve IP address for a specific host name and vice versa using
      the `host` tool
    - depends on: `awk`, `basename`, `bash`, `head`, `host`, `perl`, `sed`

* [**`doxystrip.sh`**](https://github.com/mcrbt/local-bin/blob/master/doxystrip.sh)
    - strip documentation and comments from a `doxygen` *Doxyfile*
    - a default Doxyfile may be generated by `doxygen` using the command
      `$ doxygen -g`, which contains lots of very useful documentation comments
    - unfortunately, that file is approximately 2500 lines (112 KiB)
    - `doxystrip` removes comments from the Doxyfile, to let it only be
      about 330 lines (12 KiB)
    - depends on: `bash`, `date`, `mv`, `rm`

* [**`fdiff.sh`**](https://github.com/mcrbt/local-bin/blob/master/fdiff.sh)
    - wrapper around `diff` system tool to get more specialized output
    - depends on: `awk`, `basename`, `bash`, `diff`

* [**`hex.pl`**](https://github.com/mcrbt/local-bin/blob/master/hex.pl)
    - convert between plain ASCII strings, and its hexadecimal ASCII
      representation
    - depends on: `perl`

* [**`histdel.sh`**](https://github.com/mcrbt/local-bin/blob/master/histdel.sh)
    - clear `bash` command history of current user
    - depends on: `bash`

* [**`ifinfo.sh`**](https://github.com/mcrbt/local-bin/blob/master/ifinfo.sh)
    - extract information about the default network interface and its
      assigned IP addresses
    - depends on: `awk`, `bash`, `head`, `ip`, `wc`

* [**`invoke.sh`**](https://github.com/mcrbt/local-bin/blob/master/invoke.sh)
    - start any program as background task from command line, with
      definitely no output
    - any arguments are forwarded to the new process
    - most useful for software with graphical user interface, to detach
      the background task from the current shell
    - depends on: `bash`

* [**`ipstat.sh`**](https://github.com/mcrbt/local-bin/blob/master/ipstat.sh)
    - print active network interface, private IP address (LAN),
      public IP address (WAN), and TOR exit node IP address, if any
    - depends on *Arch Linux*'s *init system*, `systemd`
    - depends on: `awk`, `bash`, `curl`, `grep`, `head`, `ip`, `ps`, `systemctl`

* [**`isgd.sh`**](https://github.com/mcrbt/local-bin/blob/master/isgd.sh)
    - command line URL shortener, using [https://is.gd](https://is.gd)
    - depends on: `basename`, `bash`, `curl`, `grep`, `perl`, `ps`

* [**`lock.sh`**](https://github.com/mcrbt/local-bin/blob/master/lock.sh)
    - lock the screen
    - alternative screen locking solution to using a real *display manager*
    - the script is a wrapper around `xsecurelock`, and hence a configuration
      example
    - depends on: `bash`, `env`, `xdg-screensaver`, `xsecurelock`

* [**`manline.sh`**](https://github.com/mcrbt/local-bin/blob/master/manline.sh)
    - view *manual pages* online, at
      [https://www.man7.org](https://www.man7.org/linux/man-pages/)
    - depends on: `basename`, `bash`, `firefox`

* [**`monitor.sh`**](https://github.com/mcrbt/local-bin/blob/master/monitor.sh)
    - quick information about connected monitors
    - wrapper around `xrandr` to *list* or *count* available monitors
    - depends on: `awk`, `basename`, `bash`, `xrandr`

* [**`mounts.sh`**](https://github.com/mcrbt/local-bin/blob/master/mounts.sh)
    - list "relevant" devices (hard drives, USB storage devices, SD cards),
      currently mounted
    - depends on: `awk`, `bash`, `grep`, `mount`

* [**`mspmacro.sh`**](https://github.com/mcrbt/local-bin/blob/master/mspmacro.sh)
    - search for C preprocessor macros or *special function register* declarations
      in the specified (or default) MSP430 header file
    - assumes the *Texas Instruments&reg;* `mspgcc` toolchain
    - default MSP430 include path, as well as default target device (e.g.
      `msp430f5529`) can be configured
    - prints whatever the `grep` command returns, or "nothing found"
    - example usage: `$ mspmacro msp430f5529 UCB0TXBUF`
    - depends on: `bash`, `grep`

* [**`pacpurge.sh`**](https://github.com/mcrbt/local-bin/blob/master/pacpurge.sh)
    - delete cached and orphaned packages
    - for use on *Arch Linux* based systems, with `pacman` package manager, only
    - depends on: `awk`, `bash`, `du`, `ls`, `pacman`, `perl`, `tr`, `wc`

* [**`pdfalign.sh`**](https://github.com/mcrbt/local-bin/blob/master/pdfalign.sh)
    - align all pages of a PDF document to *DIN A4* (210mm x 297mm) using `pdfjam`
    - `pdfjam` uses `pdflatex` to modify PDF documents
    - optionally sets PDF meta information *title*, and *author*
    - depends on: `awk`, `bash`, `cp`, `file`, `grep`, `mv`, `pdfjam`, `pdflatex`,
      `rm`, `sed`, `tr`

* [**`pw.sh`**](https://github.com/mcrbt/local-bin/blob/master/pw.sh)
    - generate passwords of configurable lengths
    - wrapper around [`secpwgen`](https://github.com/itoffshore/secpwgen) from
      [Zeljko Vrba](http://zvrba.net)
    - depends on: `awk`, `bash`, `head`, `secpwgen`, `tail`

* [**`refrestore.sh`**](https://github.com/mcrbt/local-bin/blob/master/refrestore.sh)
    - reopen hyperlinks stored in separate "`.href`" or "`.url`" files, or
      a single file containing one hyperlink per line
    - depends on: `basename`, `bash`, `cat`, `firefox`, `sleep`

* [**`rmscreen.sh`**](https://github.com/mcrbt/local-bin/blob/master/rmscreen.sh)
    - remove the last screenshot, accidently taken
    - needs to be adapted in order to work with screenshot taking application
      (regards file naming conventions, and storage location)
    - depends on: `bash`, `date`, `head`, `ls`, `rm`

* [**`tinyurl.sh`**](https://github.com/mcrbt/local-bin/blob/master/tinyurl.sh)
    - command line URL shortener using [https://tinyurl.com](https://tinyurl.com)
    - depends on: `basename`, `bash`, `curl`, `grep`, `perl`

* [**`torcircuit.sh`**](https://github.com/mcrbt/local-bin/blob/master/torcircuit.sh)
    - open a new *TOR* circuit by restarting the `tor` service
    - it is supposed, that the `tor` daemon is already running
    - when done, the old, as well as the new exit node IP address is printed
    - depends on *Arch Linux*'s *init system*, `systemd`, for managing `tor` service
    - depends on: `awk`, `bash`, `curl`, `grep`, `ip`, `ps`, `systemctl`, `tor`

* [**`trackpad.sh`**](https://github.com/mcrbt/local-bin/blob/master/trackpad.sh)
    - disables/ re-enables the *trackpad* device (and the *TrackPoint&reg;*
      device of *Lenovo&reg; ThinkPad&reg;* laptops, if available)
      - if no parameter is given, the *trackpad* is disabled if an
      *optical USB mouse* is detected, and enabled if there is no such mouse
    - depends on: `basename`, `bash`, `grep`, `xinput`

* [**`wikipedia.sh`**](https://github.com/mcrbt/local-bin/blob/master/wikipedia.sh)
    - open a specific *Wikipedia* article from command line
    - support for German and English translations (easily extensible)
    - depends on: `basename`, `bash`, `firefox`, `sed`, `tr`


## Copyright

Copyright &copy; 2018-2021 Daniel Haase

All scripts of `local-bin` are licensed under the
**GNU General Public License**, version 3.


## License disclaimer

```

local-bin - collection of various unrelated scripts
Copyright (C) 2018-2021  Daniel Haase

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see
<https://www.gnu.org/licenses/gpl-3.0.txt>.
```

[GPL (version 3)](https://www.gnu.org/licenses/gpl-3.0.txt)
