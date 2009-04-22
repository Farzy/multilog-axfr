# -*- ruby -*-

require 'rake'
require 'spec/rake/spectask'

desc "Run all RSpec examples"
Spec::Rake::SpecTask.new('test') do |t|
  t.spec_files = FileList['test/**/*_spec.rb']
  t.spec_opts = [ '--color --format nested' ]
end
