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

path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'bin'))
$LOAD_PATH.unshift(path)
require 'multilog-axfr'
require 'fileutils'

describe Multilog::SlaveZones do
  before(:all) do
    sample_path = File.join(File.dirname(__FILE__), '..', 'samples')
    sample_root = File.join(sample_path, 'root')
    @test_root   = File.join(sample_path, 'root_spec_' + rand(2**16).to_s)
    FileUtils.rm_rf(@test_root)
    FileUtils.cp_r(sample_root, @test_root)
    @zone_files = Dir[File.join(@test_root, 'slaves', '*')]
    @slave_zones = Multilog::SlaveZones.new(@test_root)
  end

  after(:all) do
    FileUtils.rm_rf(@test_root)
  end

  it "creation should fail if an unknown path is provided" do
    lambda { Multilog::SlaveZones.new(rand(2**16).to_s) }.should raise_error(ArgumentError, /autoaxfr root directory '.*' not found/)
  end

  it "should authorize a valid ip/domain" do
    @zone_files.each do |file|
      domain = File.basename(file)
      File.read(file).split.each do |ip|
        @slave_zones.authorized?(ip, domain).should be_true
      end
    end
  end

  it "should reject invalid ips/domains" do
    valid_domain = File.basename(@zone_files.first)
    valid_ip = File.read(@zone_files.first).split.first

    @slave_zones.authorized?(valid_ip, "false.com").should be_false
    @slave_zones.authorized?("1.2.3.4", valid_domain).should be_false
    @slave_zones.authorized?("1.2.3.4", "false.com").should be_false
  end

  it "should detect deleted zones on reload" do
    deleted_domain = File.basename(@zone_files.first)
    deleted_ip = File.read(@zone_files.first).split.first
    FileUtils.rm(@zone_files.first)

    lambda { @slave_zones.reload! }.should_not raise_error
    @slave_zones.authorized?(deleted_ip, deleted_domain).should be_false
  end

  it "should detect added zones on reload" do
    added_domain = "my-test-domain-#{rand(2**16)}.com"
    added_ip = (1..4).map { rand(256)+1 }.join('.')
    File.open(File.join(@test_root, 'slaves', added_domain), 'w') { |f| f.puts(added_ip) }

    lambda { @slave_zones.reload! }.should_not raise_error
    @slave_zones.authorized?(added_ip, added_domain).should be_true
  end

  it "should accept all domains if the 'any' zone exists" do
    generic_domain = "any"
    added_ip = (1..4).map { rand(256)+1 }.join('.')
    File.open(File.join(@test_root, 'slaves', generic_domain), 'w') { |f| f.puts(added_ip) }

    lambda { @slave_zones.reload! }.should_not raise_error
    3.times do |i|
      @slave_zones.authorized?(added_ip, "any-domain-#{i}.com").should be_true
    end
  end
end

