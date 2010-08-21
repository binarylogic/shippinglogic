require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Shippinglogic::UPS.options[:test] = true

Spec::Runner.configure do |config|
  config.before(:each) do
    FakeWeb.clean_registry
    
    if File.exists?("#{SPEC_ROOT}/ups/responses/_new.xml")
      raise "You have a new response in your response folder, you need to rename this before we can continue testing."
    end
  end
  
  def new_ups
    Shippinglogic::UPS.new(*ups_credentials.values_at("key", "password", "account"))
  end
  
  def ups_credentials
    return @ups_credentials if defined?(@ups_credentials)
    
    ups_credentials_path = "#{SPEC_ROOT}/config/ups_credentials.yml"
    
    unless File.exists?(ups_credentials_path)
      raise "You need to add your own UPS test credentials in spec/config/ups_credentials.yml. See spec/config/ups_credentials.example.yml for an example."
    end
    
    @ups_credentials = YAML.load(File.read(ups_credentials_path))
  end
  
  def ups_tracking_number
    "1ZX799331320416102"
  end
  
  def use_response(service, key, options = {})
    path = "#{SPEC_ROOT}/ups/responses/#{key}.xml"
    if File.exists?(path)
      options[:content_type] ||= "text/xml"
      options[:body] ||= File.read(path)
      url = Shippinglogic::UPS.options[:test_url] + service
      FakeWeb.register_uri(:post, url, options)
    end
  end
end
