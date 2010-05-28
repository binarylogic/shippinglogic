require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "shippinglogic"
    gem.summary = "A simple and clean library to interface with shipping carriers"
    gem.description = "Easily use FedEx, UPS, USPS web services with an elegant and simple syntax."
    gem.email = "bjohnson@binarylogic.com"
    gem.homepage = "http://github.com/binarylogic/shippinglogic"
    gem.authors = ["Ben Johnson of Binary Logic"]
    gem.rubyforge_project = "shippinglogic"
    gem.add_development_dependency "rspec"
    gem.add_dependency "httparty", ">= 0.4.4"
    gem.add_dependency "builder", ">= 2.1.2"
  end
  Jeweler::RubyforgeTasks.new
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

task :spec => :check_dependencies

task :default => :spec
