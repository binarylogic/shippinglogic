require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "shippinglogic"
    gem.summary = "A simple and clean library to interface with shipping carriers"
    gem.description = "A simple and clean library to interface with shipping carriers"
    gem.email = "bjohnson@binarylogic.com"
    gem.homepage = "http://github.com/binarylogic/shippinglogic"
    gem.authors = ["Ben Johnson of Binary Logic"]
    gem.rubyforge_project = "shippinglogic"
    gem.add_dependency "activesupport", ">= 2.2.0"
    gem.add_dependency "httparty", ">= 0.4.4"
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do
    desc "Release gem to RubyForge"
    task :release => ["rubyforge:release:gem"]
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end

