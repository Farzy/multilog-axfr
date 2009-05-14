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

require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe Multilog::App do
  before(:all) do
    sample_path = File.join(File.dirname(__FILE__), '..', 'samples')
    @test_root   = File.join(sample_path, 'root_spec_' + rand(2**16).to_s)
    FileUtils.rm_rf(@test_root)
    FileUtils.cp_r(File.join(sample_path, 'root'), @test_root)
    # Create test configuration file
    @config_file = File.join(sample_path, "multilog-axfr-test#{rand(2**16)}.conf")
    File.open(@config_file, "w") do |f|
      f.write("axfr_root: #{@test_root}\n")
    end
  end

  after(:all) do
    FileUtils.rm_rf(@test_root)
    FileUtils.rm_f(@config_file)
  end

  it "should fail if the config file is incorrect" do
    expect { Multilog::App.new([ ]) }.to raise_error(Errno::ENOENT)
    expect { Multilog::App.new([ '-c', "/tmp/#{rand(2**16)}.conf" ]) }.to raise_error(Errno::ENOENT)
  end

  it "should fail if not arguments are provided for 'multilog'" do
    expect { Multilog::App.new([ '-c', @config_file ]) }.to raise_error(ArgumentError, "multilog arguments missing")
    expect { Multilog::App.new([ '-c', @config_file, 't', './main' ]) }.to_not raise_error
  end

  it "should have correct variables set" do
    app = Multilog::App.new([ '-c', @config_file, 't', './main' ])
    app.instance_eval { @multilog_args }.should == 't ./main'
    app.instance_eval { @axfr_root }.should == @test_root
  end

  it "should popen 'multilog' on run" do
    app = Multilog::App.new([ '-c', @config_file, 't', './main' ])
    stdout_file = File.open(File.join(@test_root, 'stdout.log'), 'w+')
    IO.expects(:popen).with('multilog t ./main', 'w').returns(stdout_file)
    STDIN.expects(:gets).twice.returns("@4000000049eff7f506811f7c d946b128:8011:4d27 + 0006 pragmatic-services.com\n", false)
    app.run
    stdout_file.rewind
    output = stdout_file.readlines
    output[0].should match(/^multilog-axfr v.* started.$/)
    output[1].should match(/pragmatic-services/)
  end

  it "should treat DNS NOTIFY messages" do
    pending
  end
end

