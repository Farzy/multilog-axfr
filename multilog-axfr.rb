#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
# vim: sw=2 sts=2:

# multilog.rb : Wrapper for djbdns's multilog program that receives
# and handles DNS NOTIFY queries sent for example by the BIND server.
#
# Date : 2009/04/10
#
# This script was largely inspired by multilog.pl by anti@spin.de (2002-06-12),
# available at http://www.fefe.de/djbdns/multilog.pl and
# listed in the djbdns FAQ (http://www.fefe.de/djbdns/#axfr)
#
# Copyright (C) 2009 Farzad FARID <ffarid@pragmatic-source.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'optparse'
require 'ostruct'
require 'yaml'

class App
  VER = "1.0"

  def initialize(argv)
    progname = File.basename($0)

    # Default configuration
    @configfile = "/etc/djbdns-axfr.conf"
    @axfr_root = "/etc/services/autoaxfr/root"

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{progname} [options] multilog-options"
      opts.separator ""
      opts.on("-c", "--conf CONFIG_FILE", String,
              "Path of the IP/zones authorization file") do |path|
        @configfile = path
      end
    end
    opts.parse!(argv)

    # Read config file and check
    begin
      config = YAML.load(IO.read(@configfile))
      @axfr_ip_zones = config['axfr']
      @axfr_root = config['axfr_root'] if !config['axfr_root'].nil?

      raise ArgumentError, "Zone file not found" if @axfr_ip_zones.nil?
      raise ArgumentError, "autoaxfr root directory '#{@axfr_root}' not found" if !File.directory?(@axfr_root)
      raise ArgumentError, "multilog arguments missing" if argv.nil?
    rescue Errno::ENOENT, ArgumentError => exc
      $stderr.puts "#{progname}: Configuration error. #{exc}"
      exit 1
    end

    # The other arguments will be passed as is to 'multilog'
    @multilog_args = argv.join(" ")
  end

  def run
    logger = IO.popen("multilog " + @multilog_args, "w")
    STDOUT.reopen(logger)

    puts "multilog-axfr v#{VER} started."

    while line = $stdin.gets
      print line
      ip_port_qid, sid, qtype, domain = line.chomp.split(/ /)
      next if [ip_port_qid, sid, qtype, domain].any? { |s| s.nil? }
      # Select NOTIFY messages
      next unless sid == "I" and qtype == "0006"
      hexip, hexport, sid = ip_port_qid.split(/:/)
      # Convert hexadecimal IP, like "A343D5F3", to "163.67.213.243"
      ip = [hexip].pack("H8").unpack("C*").join(".")
      zones = @axfr_ip_zones[ip]
      next unless zones

      if zones.first == "any" or zones.include?(domain)
        `logger -t axfr-watch "rcvd NTFY #{ip} (#{domain})"`;
        `logger -t axfr-watch "send AXFR #{ip} (#{domain})"`;
        cmd = [ 'tcpclient', ip, '53', 'axfr-get', domain,
                File.join(@axfr_root, 'zones', domain),
                File.join(@axfr_root, 'temp', domain + '.temp') ]
        pid = fork do
          File.delete(File.join(@axfr_root, 'zones', domain)) rescue nil
          exec(*cmd)
        end
        Process.detach(pid)
        # XXX call method to update your data.cdb here...
      else
        `logger -t axfr-watch "nvld NTFY #{ip} (#{ip_port_qid} #{sid} #{qtype} #{domain})"`;
      end
    end

    exit 0
  end

  def test
    require 'pp'
    pp self
  end
end

# Entry point
if $0 == __FILE__
  app = App.new(ARGV)
  app.run
end

