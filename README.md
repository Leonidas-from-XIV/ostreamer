OStreamer
=========

A streaming library for OCaml mainly binding libarchive for extensive
compressuin format support in your favorite programming language.

Started as bachelor thesis of [Marek Kubica](http://xivilization.net/) at the
[Technische Universität München](http://www.tum.de/),
[Department of Computer Science](http://www.in.tum.de/),
[Chair of Robotics and Embedded Systems](http://www6.in.tum.de/) under
supervision of [Markus Weißmann](http://www.mweissmann.de/).

Prerequisites
-------------

 * OCaml, of course. Tested with 4.00.1 but should work with older versions as
   well.
 * libarchive, newer than git revision `3ae99fbc24`. Should be part of the
   release *after* 3.1.2. On some distributions you might need the `-dev` or
   `-devel` packages from your package manager as well.
 * OASIS 0.3 for building.

Building
--------

```shell
oasis setup
ocaml setup.ml -configure
ocaml setup.ml -build
```

License
-------

Free Software under the  LGPL 2.1 + OCaml linking exception, so feel free to
use it in your software.
