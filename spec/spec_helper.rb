$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'shippinglogic'
require 'spec'
require 'spec/autorun'
require 'ruby-debug'
require 'fakeweb'
require File.dirname(__FILE__) + "/lib/interceptor"

Shippinglogic::Fedex.options[:test] = true

Spec::Runner.configure do |config|
  config.before(:each) do
    FakeWeb.clean_registry
    
    if File.exists?(File.dirname(__FILE__) + "/responses/_new.xml")
      raise "You have a new response in your response folder, you need to rename this before we can continue testing."
    end
  end
  
  def new_fedex
    Shippinglogic::Fedex.new(
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
      :street_lines => "260 Broadway",
      :city => "New York",
      :state_or_province_code => "NY",
      :postal_code => "10007",
      :country_code => "US"
    }
  end
  
  def fedex_recipient
    {
      :street_lines => "1500 Marilla Street",
      :city => "Dallas",
      :state_or_province_code => "TX",
      :postal_code => "75201",
      :country_code => "US"
    }
  end
  
  def fedex_package
    {
      :weight => {:value => 2},
      :dimensions => {
        :length => 2,
        :width => 2,
        :height => 2
      }
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
