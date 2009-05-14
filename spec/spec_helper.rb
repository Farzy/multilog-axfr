# multilog-axfr RSpec test suite
# 
# Date : 2009-04-22
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

# Use Mocha
Spec::Runner.configure do |config|
  config.mock_with :mocha
end

require 'fileutils'

path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'bin'))
$LOAD_PATH.unshift(path)
require 'multilog-axfr'
