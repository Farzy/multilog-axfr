# -*- ruby -*-

require 'rake'
require 'spec/rake/spectask'

desc "Convert README.md to html"
task :readme => "README.html"

file "README.html" => "README.md" do
  sh "markdown README.md > README.html"
end

desc "Run all RSpec examples"
Spec::Rake::SpecTask.new do |t|
  #t.spec_files = FileList['test/**/*_spec.rb']
  t.spec_opts = [ '--color --format nested' ]
end
