require "httparty"
require "shippinglogic/proxy"
require "shippinglogic/attributes"
require "shippinglogic/validation"

module Shippinglogic
  class Service < Proxy
    include Attributes
    include HTTParty
    include Validation
    
    attr_accessor :base
    
    # Accepts the base service object as a single parameter so that we can access
    # authentication credentials and options.
    def initialize(base, attributes = {})
      self.base = base
      super
    end
    
    private
      # Allows the cached response to be reset, specifically when an attribute changes
      def reset_target
        @target = nil
      end
      
      # Resets the target before deferring to the +write_attribute+ method as defined by the
      # +Attributes+ module. This keeps +Attributes+ dissociated from any proxy or service specific
      # code, making testing simpler.
      def write_attribute(*args)
        reset_target
        super
      end
      
      # For each service you need to overwrite this method. This is where you make the call to the API
      # and do your magic. See the child classes for examples on how to define this method. It is very
      # important that you cache the result into a variable to avoid uneccessary requests.
      def target
        raise NotImplementedError.new("You need to implement a target method that the proxy class can delegate method calls to")
      end
  end
end