Puppet perlbrew Module
======================

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Overview](#overview)
* [Description](#description)
* [Usage](#usage)
  * [Examples](#examples)
    * [Hiera](#hiera)
    * [Puppet code](#puppet-code)
* [Limitations](#limitations)
  * [Tested Platforms](#tested-platforms)
* [Versioning](#versioning)
* [Support](#support)
* [See Also](#see-also)

<!-- vim-markdown-toc -->

Overview
--------

Manages `perlbrew` based Perl5 installations


Description
-----------

This is a puppet module for basic management of
[`perlbrew`](http://perlbrew.pl/) based Perl5 installations.  It is designed to manage a single instance
of perlbrew (which can have multiple versions of perl installed into it).

Usage
-----

See the [REFERENCE.md](REFERENCE.md) file for a complete reference.

### Examples

#### Hiera

It can be fully implement in Hiera like this:

```
classes:
  - perlbrew

perlbrew::versions::install:
  - 5.32.1
  - 5.36.0
perlbrew::versions::purge_builds: true
perlbrew::modules::install:
  5.32.1:
  - Module::Build
  5.36.0:
  - Module::Build
  - String::ShortHostname
```

#### Puppet code

Th class can be invoked via code, but it's still designed to be configured via Hiera, the versions
and modules installed are still best specified through Hiera.

```puppet
class { 'perlbrew': 
  install_root => /usr/local/perlbrew,
  owner => 'perl',
  group => 'perl',
  create_user => true,
  rc_files => ['/etc/profile.d/perlbrew.sh'],
}
```

Limitations
-----------

At present, this module is only capable of supporting one perlbrew installation per system.  Let me
if there is a use case for multiple installs.  I'm thinking with the advent of containers, really unique
requirements as better addressed by them.  Individual users can still have there own modules installed
via `local::lib` and their desired perl version set while the perl versions are updated for the whole host.  

### Tested Platforms

 * openSUSE 15.4 (should work on any *NIX environment though)

Versioning
----------

This module is versioned according to the [Semantic Versioning
2.0.0](http://semver.org/spec/v2.0.0.html) specification.


Support
-------

Please log tickets and issues at
[github](https://github.com/Q-Technologies/puppet-perlbrew/issues)


See Also
--------

* [`perlbrew`](http://perlbrew.pl/)
