$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'shippinglogic'
require 'spec'
require 'spec/autorun'
require 'ruby-debug'
require 'fakeweb'
require File.dirname(__FILE__) + "/lib/interceptor"

Shippinglogic::FedEx.options[:test] = true

Spec::Runner.configure do |config|
  config.before(:each) do
    FakeWeb.clean_registry
    
    if File.exists?(File.dirname(__FILE__) + "/responses/_new.xml")
      raise "You have a new response in your response folder, you need to rename this before we can continue testing."
    end
  end
  
  def new_fedex
    Shippinglogic::FedEx.new(
      fedex_credentials["key"],
      fedex_credentials["password"],
      fedex_credentials["account"],
      fedex_credentials["meter"]
    )
  end
  
  def fedex_credentials
    return @fedex_credentials if defined?(@fedex_credentials)
    
    fedex_credentials_path = File.dirname(__FILE__) + "/fedex_credentials.yml"
    
    if !File.exists?(fedex_credentials_path)
      raise "You need to add your own FedEx test credentials in spec/fedex_credentials.yml. See spec/fedex_credentials.example.yml for an example."
    end
    
    @fedex_credentials = YAML.load(File.read(fedex_credentials_path))
  end
  
  def fedex_tracking_number
    "077973360403984"
  end
  
  def fedex_shipper
    {
      :shipper_name => "Name",
      :shipper_title => "Title",
      :shipper_company_name => "Company",
      :shipper_phone_number => "2222222222",
      :shipper_email => "a@a.com",
      :shipper_streets => "260 Broadway",
      :shipper_city => "New York",
      :shipper_state => "NY",
      :shipper_postal_code => "10007",
      :shipper_country => "US"
    }
  end
  
  def fedex_recipient
    {
      :recipient_name => "Name",
      :recipient_title => "Title",
      :recipient_department => "Department",
      :recipient_company_name => "Dallas City Hall",
      :recipient_phone_number => "2222222222",
      :recipient_email => "a@a.com",
      :recipient_streets => "1500 Marilla Street",
      :recipient_city => "Dallas",
      :recipient_state => "TX",
      :recipient_postal_code => "75201",
      :recipient_country => "US"
    }
  end
  
  def fedex_package
    {
      :package_weight => 2,
      :package_length => 2,
      :package_width => 2,
      :package_height => 2
    }
  end
  
  def use_response(key, options = {})
    path = File.dirname(__FILE__) + "/responses/#{key}.xml"
    if File.exists?(path)
      options[:content_type] ||= "text/xml"
      options[:body] ||= File.read(path)
      FakeWeb.register_uri(:post, "https://gatewaybeta.fedex.com:443/xml", options)
    end
  end
end
