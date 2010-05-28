require "shippinglogic/fedex/enumerations"
require "shippinglogic/fedex/service"
require "shippinglogic/fedex/cancel"
require "shippinglogic/fedex/rate"
require "shippinglogic/fedex/ship"
require "shippinglogic/fedex/signature"
require "shippinglogic/fedex/track"

module Shippinglogic
  class FedEx
    # A hash representing default the options. If you are using this in a Rails app the best place
    # to modify or change these options is either in an initializer or your specific environment file. Keep
    # in mind that these options can be modified on the instance level when creating an object. See #initialize
    # for more details.
    #
    # === Options
    #
    # * <tt>:test</tt> - this basically tells us which url to use. If set to true we will use the FedEx test URL, if false we
    #   will use the production URL. If you are using this in a rails app, unless you are in your production environment, this
    #   will default to true automatically.
    # * <tt>:test_url</tt> - the test URL for FedEx's webservices. (default: https://gatewaybeta.fedex.com:443/xml)
    # * <tt>:production_url</tt> - the production URL for FedEx's webservices. (default: https://gateway.fedex.com:443/xml)
    def self.options
      @options ||= {
        :test => !!(defined?(Rails) && !Rails.env.production?),
        :production_url => "https://gateway.fedex.com:443/xml",
        :test_url => "https://gatewaybeta.fedex.com:443/xml"
      }
    end

    attr_accessor :key, :password, :account, :meter, :options

    # Before you can use the FedEx web services you need to provide 4 credentials:
    #
    # 1. Your fedex web service key
    # 2. Your fedex password
    # 3. Your fedex account number
    # 4. Your fedex meter number
    #
    # You can easily get these things by logging into your fedex account and going to:
    #
    # https://www.fedex.com/wpor/wpor/editConsult.do
    #
    # If for some reason this link no longer works because FedEx changed it, just go to the
    # developer resources area and then navigate to the FedEx web services for shipping area. Once
    # there you should see a link to apply for a develop test key.
    #
    # The last parameter allows you to modify the class options on an instance level. It accepts the
    # same options that the class level method #options accepts. If you don't want to change any of
    # them, don't supply this parameter.
    def initialize(key, password, account, meter, options = {})
      self.key = key
      self.password = password
      self.account = account
      self.meter = meter
      self.options = self.class.options.merge(options)
    end
    
    # A convenience method for accessing the endpoint URL for the FedEx API.
    def url
      options[:test] ? options[:test_url] : options[:production_url]
    end
    
    def cancel(attributes = {})
      @cancel ||= Cancel.new(self, attributes)
    end
    
    def rate(attributes = {})
      @rate ||= Rate.new(self, attributes)
    end
    
    def ship(attributes = {})
      @ship ||= Ship.new(self, attributes)
    end
    
    def signature(attributes = {})
      @signature ||= Signature.new(self, attributes)
    end
    
    def track(attributes = {})
      @track ||= Track.new(self, attributes)
    end
  end
end