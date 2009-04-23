#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
# vim: sw=2 sts=2:
# 
# log-parameters.rb : Simple script that logs all of its parameters in the
# file provided as the first argument.
# 
# Date : 2009-04-23
# 
# Copyright (C) 2009 Farzad FARID <ffarid@pragmatic-source.com>
# 
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 

def usage
  msg = <<-EOT
    Usage: log-parameters.rb <filename> [parameters..]

      Create a file named after the first argument and write the rest of the
      command line in it, one parameter per line.

      A typical use for this script is in unit or rspec tests, to simulate
      the execution of an external process.
  EOT
  STDERR.puts msg.gsub(/^ {4}/, '')
  exit 1
end

logfile = ARGV.shift
usage if logfile.nil? or logfile.empty?

File.open(logfile, 'w') { |f| f.puts ARGV }

exit 0
