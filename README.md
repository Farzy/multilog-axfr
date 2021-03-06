multilog-axfr: A DNS NOTIFY implementation for djbdns
=====================================================

Version 1.2
Copyright (C) 2009 Farzad FARID <ffarid@pragmatic-source.com>

Introduction
------------

**[djbdns](http://cr.yp.to/djbdns.html)** is a powerful and secure DNS server.
But it lacks some features, sometimes called "bugs" by the djbdns author and
contributors, usually found in the **BIND** software.

For example it doesn't handle **NOTIFY** messages as a slave server and therefore
it can't update its database immediatly if the master server running BIND is
modified and sends an update request to all of its slave DNS.

Given the facts that:
*  BIND is a very popular DNS software and won't disappear soon,
*  the NOTIFY message is pretty standard,

This script lets you use djbdns as a slave server for BIND and not be
 worried by unreasonable update delays.

Please note that this script does **not** handle all zone transfer actions, it
only catches the NOTIFY event and calls other programs, like `axfr-get`,
to do the zone transfer
itself.

Installation
------------

multilog-axfr depends on:
*  djbdns's tinydns server
*  daemontools
*  autoaxfr
*  Ruby

« ruby », « tinydns » and « daemontools » must be installed the usual way, their
installation process is not covered here.

### Installing autoaxfr (optionnal)

[autoaxfr](http://www.lickey.com/autoaxfr/) is an extension
to djbdns. Autoaxfr implements « *master BIND* » to « *slave djbdns* » zone
transfers, but does not react to NOTIFY messages. multilog-axfr uses (and
completes) autoaxfr's directories and tools.

When installing « autoaxfr » you **must** use the same user id and group id as
« tinydns » for the log files.

Check that autoaxfr is running correctly, including the crontab that runs
tinydns's Makefile.

### Installing multilog-axfr.rb

Lets suppose that:
* All djbdns services are availables under « `/etc/service` ». This is the case
  on [Debian](http://www.debian.org/) systems. If *djbdns* was installed manually
  the path is « `/service` ».
* The present script is at `/usr/local/bin/multilog-axfr.rb`.
* The configuration file is at `/usr/local/etc/multilog-axfr.conf`,
* Both the logfiles of tinydns and the zones files of autoaxfr are created
  with the uid/gid « `Gdnslog` ».

Do the following:

*  Copy `multilog-axfr.rb` to a directory in your PATH (usually `/usr/local/bin`)

*  Rename and copy `multilog-axfr.conf-sample` to a configuration directory (usually
`/etc` or `/usr/local/etc`).

*  Modify the « `run` » script of tinydns's logger to use « `multilog-axfr.rb` »
instead of « `multilog` ». Here is sample « `/etc/service/tinydns/log/run` »:


    #!/bin/sh
    exec setuidgid Gdnslog /usr/local/bin/multilog-axfr.rb --conf /usr/local/etc/multilog-axfr.conf t ./main

*  You can use all of multilog's regular option on the command line
*  Restart tinydns's logger:


  svc -t /etc/service/tinydns/log

### Configuration files

#### /usr/local/etc/multilog-axfr.conf

    # Configuration file for multilog-axfr, the djbdns helper that
    # implements the Bind NOTIFY functionnality.
    # This file is in the YAML format (http://www.yaml.org).

    # autoaxfr's root directory
    axfr_root: /etc/service/autoaxfr/root

#### /etc/service/autoaxfr/root/slaves/*

In this directory create one file per zone in the following format:
*  Each file should be named after the zone/domain. For example « `linux.com` »
*  Each file contains the list of the authorized master DNS servers' IP, one per line.
*  A special zone file named « `any` », if it exists, will authorize DNS NOTIFY
   messages for any domain as long as it's coming from the IPs listed in the file.

For example, if « `example.com` » is a domain handled by 192.168.42.42 and
« `other.sample.com` » is handled by 192.168.69.69 and 10.10.34.84 then the
following commands will configure both `autoaxfr` and `multilog-axfr` for you:

    cd /etc/service/autoaxfr/root/slaves
    echo 192.168.42.42 > example.com
    echo 192.168.69.69 > other.sample.com
    echo 10.10.34.84  >> other.sample.com
    echo 1.2.3.4 > any

The last list says that DNS server 1.2.3.4 can notify us for any domain.

Testing the code
----------------

This tool uses [RSpec](http://rspec.info/) and Mocha for testing purposes.
Install the **rake**, **rspec** & **mocha** Ruby gems first, you can then
run the following command to test multilog-axfr:

    cd /usr/src/multilog-axfr
    rake spec


License
-------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

Consult the LICENSE file for a full copy of the GNU General Public License.


References
----------

This script was largely inspired by *multilog.pl*.

* **Author's page**: <http://www.pragmatic-source.com>
* **multilog-axfr's home page**: <http://opensource.pragmatic-source.com/projects/show/multilog-axfr>
* **djbdns FAQ** (article about NOTIFY): <http://www.fefe.de/djbdns/#axfr>
* **multilog.pl**, the source of inspiration for this script: <http://www.fefe.de/djbdns/multilog.pl>

