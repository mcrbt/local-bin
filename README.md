# local-bin


## General

This is a collection of various unrelated `bash`, `perl`, and `fish` scripts.

The scripts had initially been written for *Arch Linux*. Some may not work
"out of the box" on every machine as some files could reside at different
locations or some software may not be present on the system, at all.
A lot of scripts are wrappers around other Linux command line tools, some
are almost one-liners and only few are a little bit more sophisticated somehow.

All scripts are licensed under the **GNU General Public License**, version 3.

The source code of the scripts can be used as example to write tools working
for specific platforms and configuration.


## Installation

In order to enhance daily Linux experience the scripts can be placed under
`/usr/bin` or `/usr/local/bin` with their filename extension stripped.

For example, to use the tool `battery.pl`, it can be "installed" by running:

```
$ cp /home/<user>/Downloads/local-bin/battery.pl /usr/local/bin/battery
```

To get the battery status `battery.pl` can then simply be run as "native"
command:

```
$ battery
```

Alternatively a symbolic link to the script could be created which would
do the same trick:

```
$ ln -sv /home/<user>/Downloads/local-bin/battery.pl /usr/local/bin/battery
```

Of course the tools need to be made executable first:

```
$ chmod 755 <script>
```

(*&lt;user&gt;* needs to be substituted with the respective username and
*&lt;script&gt;* with the respective script to be set executable. If the
scripts had not been downloaded to the `Downloads` folder but the
repository was cloned elsewhere the path to the scripts needs to be
changed in the above commands, as well, obviously.)


## Description

The collection currently contains the following **27 scripts**:

* [**`aphwaddr.sh`**](https://github.com/mcrbt/local-bin/blob/master/aphwaddr.sh)
    - print hardware address (i.e. *MAC address*) of the wireless
      access point currently connected to
    - depends on: `awk`, `basename`, `bash`, `grep`, `ip`, `iw`

* [**`battery.pl`**](https://github.com/mcrbt/local-bin/blob/master/battery.pl)
    - print capacity (percentage) of one or two installed batteries
      and their charging status
    - if two batteries are installed a cumulated capacity is calculated
    - *design capacity* is used as maximium, thus *100%* may never be
      reached (can easily be changed)
    - the path of the battery system files may be changed accordingly
    - depends on: `perl`

* [**`cfgsync.sh`**](https://github.com/mcrbt/local-bin/blob/master/cfgsync.sh)
    - copy e.g. configuration files of user `root` to all other user's home
      directories
    - configuration directories (`.config/openbox/`) can be copied recursively
    - intended for single user systems with an additional non-privileged
      user, e.g. to execute riskier tasks
    - allows to only modify the configuration file of user `root` and then to
      "synchronize" with all other user accounts that have a home directory under
      `/home/`
    - configuration is to be done within the script using the global constant
      `QUIET` to control *verbosity*, and `SYNC_LIST` for a space (' ')
      separated list of file names (with or without `/root/` prefix)
    - *alternatively* to the files given in `SYNC_LIST`, filenames (resp.
      directories) can be provided via command line, each as its own argument
      (e.g. `$ cfgsync .bashrc .xinitrc`; see `$ cfgsync --help` for details)
    - **CAUTION**: this script has to be used with care as it is intended to
      **override existing configuration files** of local users
    - depends on: `basename`, `bash`, `cp`, `dirname`, `mkdir`

* [**`clfish.fish`**](https://github.com/mcrbt/local-bin/blob/master/clfish.fish)
    - clear the history of the `fish` shell (*friendly interactive shell*)
    - if `fish` is used within a `bash` environment, an additional command
      for clearing the `bash` history can be added, as well (see `histdel.sh`,
      for instance)
    - depends on: `fish`

* [**`cpall.sh`**](https://github.com/mcrbt/local-bin/blob/master/cpall.sh)
    - copy all files from one location to another while optionally
      prepending or appending a prefix or suffix to the copied files
    - depends on: `basename`, `bash`, `cp`

* [**`ddg.sh`**](https://github.com/mcrbt/local-bin/blob/master/ddg.sh)
    - open `firefox` and search a pattern with *DuckDuckGo* search engine
      from command line
    - depends on: `bash`, `firefox`, `sed`

* [**`dictcc.sh`**](https://github.com/mcrbt/local-bin/blob/master/dictcc.sh)
    - translate a pattern on &lt;[https://www.dict.cc](https://www.dict.cc)&gt;
    - the pattern is supplied as command line arguments and can consist of
      multiple words
    - the web browser to open can be configured by altering the variable
      `BROWSER` (defaults to `firefox`)
    - depends on: `bash`, `firefox`, `sed`

* [**`dns.sh`**](https://github.com/mcrbt/local-bin/blob/master/dns.sh)
    - retrieve IP address for a specific host name and vice versa using
      the `host` tool
    - depends on: `awk`, `basename`, `bash`, `head`, `host`, `perl`, `sed`

* [**`doxystrip.sh`**](https://github.com/mcrbt/local-bin/blob/master/doxystrip.sh)
    - strip documentation and comments from a `doxygen` *Doxyfile*
    - a default Doxyfile can be generated by `doxygen` using the command
      `$ doxygen -g` which contains lots of very useful documentation comments
    - unfortunately that file is approximately 2500 lines and `112 kB`
    - `doxystrip` removes comments from the *Doxyfile* to let it only be
      about 330 lines and `12 kB`
    - depends on: `bash`, `date`, `mv`, `rm`

* [**`fdiff.sh`**](https://github.com/mcrbt/local-bin/blob/master/fdiff.sh)
    - wrapper around `diff` system tool to get more specialized output
    - depends on: `awk`, `basename`, `bash`, `diff`

* [**`hex.pl`**](https://github.com/mcrbt/local-bin/blob/master/hex.pl)
    - convert a plain ASCII string to its hexadecimal ASCII representation
      and vice versa
    - depends on: `perl`

* [**`histdel.sh`**](https://github.com/mcrbt/local-bin/blob/master/histdel.sh)
    - clear `bash` history of current user
    - depends on: `bash`

* [**`ifinfo.sh`**](https://github.com/mcrbt/local-bin/blob/master/ifinfo.sh)
    - extract information about the network interface currently used
      and its assigned IP addresses
    - depends on: `awk`, `bash`, `grep`, `ip`, `wc`

* [**`invoke.sh`**](https://github.com/mcrbt/local-bin/blob/master/invoke.sh)
    - start any program, including its arguments, from command line
      as background task with definitely no output
    - most useful for software with graphical user interface to detach
      the background task from the current shell
    - depends on: `bash`

* [**`ipstat.sh`**](https://github.com/mcrbt/local-bin/blob/master/ipstat.sh)
    - print active network interface, private IP address (LAN),
      public IP address (WAN), and TOR exit node IP address, if any
    - depends on: `awk`, `bash`, `curl`, `grep`, `ip`, `ps`, `sed`

* [**`isgd.sh`**](https://github.com/mcrbt/local-bin/blob/master/isgd.sh)
    - command line URL shortener using &lt;[https://is.gd](https://is.gd)&gt;
    - depends on: `basename`, `bash`, `curl`, `grep`, `perl`, `ps`

* [**`lock.sh`**](https://github.com/mcrbt/local-bin/blob/master/lock.sh)
    - lock the screen
    - alternative screen locking solution to using a *display manager*
    - the script is a wrapper around `xsecurelock` and hence a configuration
      example
    - depends on: `bash`, `env`, `xdg-screensaver`, `xsecurelock`

* [**`manline.sh`**](https://github.com/mcrbt/local-bin/blob/master/manline.sh)
    - view *manual pages* online
    - let `firefox` connect to
      &lt;[https://www.man7.org](https://www.man7.org/linux/man-pages/)&gt;
    - depends on: `basename`, `bash`, `firefox`

* [**`monitor.sh`**](https://github.com/mcrbt/local-bin/blob/master/monitor.sh)
    - quick information about connected monitors
    - wrapper around `xrandr` to *list* or *count* available monitors
    - depends on: `awk`, `basename`, `bash`, `xrandr`

* [**`mounts.sh`**](https://github.com/mcrbt/local-bin/blob/master/mounts.sh)
    - list relevant devices (hard drives, USB storage devices, SD cards)
      currently mounted
    - depends on: `awk`, `bash`, `grep`, `mount`

* [**`normalize.pl`**](https://github.com/mcrbt/local-bin/blob/master/normalize.pl)
    - adapt file names for use with Linux file systems
    - whitespaces and lots of special characters are replaced with underscore
      ("\_"), German umlauts and other graphemes are converted to their ASCII
      representation (e.g. "ä"->"ae", "â"->"a", ...)
    - depends on: `perl`

* [**`pacpurge.sh`**](https://github.com/mcrbt/local-bin/blob/master/pacpurge.sh)
    - delete cached or orphaned packages
    - for use with `pacman` package manager on *Arch Linux* based systems
    - *TODO*: additional support for `AUR` package managers
    - depends on: `awk`, `bash`, `du`, `ls`, `pacman`, `perl`, `tr`, `wc`

* [**`refrestore.sh`**](https://github.com/mcrbt/local-bin/blob/master/refrestore.sh)
    - reopen hyperlinks stored in separate "`.href`" or "`.url`" files or
      a single file containing one hyperlink per line
    - depends on: `basename`, `bash`, `cat`, `firefox`, `sleep`

* [**`rmscreen.sh`**](https://github.com/mcrbt/local-bin/blob/master/rmscreen.sh)
    - remove the last screenshot accidently taken
    - needs to be adapted in order to work with the screenshot taking
      application (i.e. file naming conventions, and storage location)
    - depends on: `bash`, `date`, `head`, `ls`, `rm`

* [**`tinyurl.sh`**](https://github.com/mcrbt/local-bin/blob/master/tinyurl.sh)
    - command line URL shortener using
      &lt;[https://tinyurl.com](https://tinyurl.com)&gt;
    - depends on: `basename`, `bash`, `curl`, `grep`, `perl`

* [**`trackpad.sh`**](https://github.com/mcrbt/local-bin/blob/master/trackpad.sh)
    - disables/ re-enables the *trackpad* device (and the *TrackPoint&reg;*
      device of *Lenovo&reg; ThinkPad&reg;* laptops if available)
    - if no parameter is given the *trackpad* is disabled if an *optical USB
      mouse* is detected and enabled if there is no such mouse
    - depends on: `basename`, `bash`, `grep`, `xinput`

* [**`wikipedia.sh`**](https://github.com/mcrbt/local-bin/blob/master/wikipedia.sh)
    - open a specific *Wikipedia* article from command line
    - support for German and English language but easily extensible
    - depends on: `basename`, `bash`, `firefox`, `sed`, `tr`


## Copyright

Copyright &copy; 2018-2020 Daniel Haase

All scripts of `local-bin` are licensed under the
**GNU General Public License**, version 3.


## License disclaimer

```

local-bin - collection of various unrelated scripts
Copyright (C) 2018-2020  Daniel Haase

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
