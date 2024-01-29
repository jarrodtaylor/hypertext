HyperText
=========
HyperText is a CLI for building simple, static sites.

Using an up-to-date version of macOS, download the latest executable from the
[releases page][releases] and add it to your path.

> You might be able to build and run HyperText on Linux. I haven't tried it yet.

Full documentation is at [hypertext.sh][hypertext.sh].

Quick Start
-----------
```bash
$ hypertext --help
USAGE: hypertext <source> <target> [--stream]

ARGUMENTS:
  <source>                Relative path to source directory.
  <target>                Relative path to target directory.

OPTIONS:
  --stream                Stream changes from source to target.
  -h, --help              Show help information.
```

### Building

### Streaming

```bash
$ hypertext src public --stream
```

? Modified files -- when do files get built?

Static Files
------------

Static files are copied directly from `source` to `target`.

Rendered Files
--------------

### Variables

### Includes

### Layouts

[hypertext.sh]: https://hypertext.sh
[releases]: https://github.com/jarrodtaylor/hypertext/releases