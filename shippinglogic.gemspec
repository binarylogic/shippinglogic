# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shippinglogic}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Johnson of Binary Logic"]
  s.date = %q{2009-08-06}
  s.description = %q{A simple and clean library to interface with shipping carriers}
  s.email = %q{bjohnson@binarylogic.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "lib/shippinglogic.rb",
     "lib/shippinglogic/fedex.rb",
     "lib/shippinglogic/fedex/attributes.rb",
     "lib/shippinglogic/fedex/error.rb",
     "lib/shippinglogic/fedex/rates.rb",
     "lib/shippinglogic/fedex/request.rb",
     "lib/shippinglogic/fedex/response.rb",
     "lib/shippinglogic/fedex/service.rb",
     "lib/shippinglogic/fedex/track.rb",
     "lib/shippinglogic/fedex/validation.rb",
     "spec/fedex/attributes_spec.rb",
     "spec/fedex/error_spec.rb",
     "spec/fedex/rates_spec.rb",
     "spec/fedex/service_spec.rb",
     "spec/fedex/track_spec.rb",
     "spec/fedex/validation_spec.rb",
     "spec/fedex_credentials.example.yaml",
     "spec/fedex_spec_no.rb",
     "spec/lib/interceptor.rb",
     "spec/responses/basic_rate.xml",
     "spec/responses/basic_track.xml",
     "spec/responses/blank.xml",
     "spec/responses/failed_authentication.xml",
     "spec/responses/malformed.xml",
     "spec/responses/unexpected.xml",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/binarylogic/shippinglogic}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{shippinglogic}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A simple and clean library to interface with shipping carriers}
  s.test_files = [
    "spec/fedex/attributes_spec.rb",
     "spec/fedex/error_spec.rb",
     "spec/fedex/rates_spec.rb",
     "spec/fedex/service_spec.rb",
     "spec/fedex/track_spec.rb",
     "spec/fedex/validation_spec.rb",
     "spec/fedex_spec_no.rb",
     "spec/lib/interceptor.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.0"])
      s.add_runtime_dependency(%q<httparty>, [">= 0.4.4"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.2.0"])
      s.add_dependency(%q<httparty>, [">= 0.4.4"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.2.0"])
    s.add_dependency(%q<httparty>, [">= 0.4.4"])
  end
end
