multilog-axfr: A DNS NOTIFY implementation for djbdns
=====================================================

Copyright (C) 2009 Farzad FARID <ffarid@pragmatic-source.com>

Introduction
------------

[djbdns](http://cr.yp.to/djbdns.html) is a powerful and secure DNS server.
But it lacks some features, sometimes called "bugs" by the djbdns author and
aficionados, usually found in the BIND software.

Especially it doesn't handle NOTIFY messages as a slave server and therefore
it can't update its database immediatly if the master server is running BIND.

Given the facts that:
* BIND is a very popular DNS software and won't disappear soon,
* the NOTIFY message is pretty standard,
* not every DNS administrator is a hardcore overzealous djbdns lover,

.. this script lets you use djbdns as a slave server for BIND a not be worried
by unreasonable update delays.

Please note that this script does **not** handle all zone transfer action, it
only catches the NOTIFY event and calls other programs to do the zone transfer
itself.

Installation
------------

multilog-axfr depends on:
* djbdns's tinydns server
* daemontools
* autoaxfr
* Ruby

« ruby », « tinydns » and « daemontools » must be installed the usual way, their
installation process is not covered here.

### Installing autoaxfr

[autoaxfr](http://www.lickey.com/autoaxfr/) is an extension
to djbdns. Autoaxfr implements « *master BIND* » to « *slave djbdns* » zone
transfers, but does not react to NOTIFY messages. multilog-axfr uses (and
completes) autoaxfr's directories and tools.

When installing « autoaxfr » you **must** use the same user id and group id as
« tinydns » for the log files.

Check that autoaxfr is running correctly, including the crontab that runs
tinydns's Makefile.

### Installing multilog-axfr.rb

Copy multilog-axfr.rb to a directory in your PATH (usually `/usr/local/bin`)

Rename and copy multilog-axfr.conf-sample to a configuration directory (usually
`/etc` or `/usr/local/etc`).

Modify the « `run` » script of tinydns's logger to use « multilog-axfr.rb »
instead of « multilog »

Restart tinydns's logger:

### Example configuration

Lets suppose that:
* All djbdns services are availables under « `/etc/service` »
* The script is at `/usr/local/bin/multilog-axfr.rb`,
* The configuration file is at `/usr/local/etc/multilog-axfr.conf`,
* Both the logfiles of tinydns and the zones files of autoaxfr are created
  with the uid/gid « `Gdnslog` ».

Modify « `/etc/service/tinydns/log/run` » to be like:

    #!/bin/sh
    exec setuidgid Gdnslog /usr/local/bin/multilog-axfr.rb --conf /usr/local/etc/multilog-axfr.conf t ./main

Restart tinydns's logger:

    svc -t /etc/service/tinydns/log


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
* **multilog-axfr's home page**: <http://github.com/Farzy/multilog-axfr>
* **djbdns FAQ** (article about NOTIFY): <http://www.fefe.de/djbdns/#axfr>
* **multilog.pl**, the source of inspiration for this script: <http://www.fefe.de/djbdns/multilog.pl>
