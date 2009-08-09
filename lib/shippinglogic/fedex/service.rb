require "shippinglogic/fedex/attributes"
require "shippinglogic/fedex/request"
require "shippinglogic/fedex/response"
require "shippinglogic/fedex/validation"

module Shippinglogic
  class FedEx
    class Service
      alias_method :real_class, :class
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^real_class$|^send$|^object_id$)/ }
      
      include Attributes
      include HTTParty
      include Request
      include Response
      include Validation
      
      attr_accessor :base
      
      # Accepts the base service object as a single parameter so that we can access
      # authentication credentials and options.
      def initialize(base, attributes = {})
        self.base = base
        super
      end
      
      private
        # We undefined a lot of methods at the beginning of this class. The only methods present in this
        # class are ones that we need, everything else is delegated to our target object.
        def method_missing(name, *args, &block)
          target.send(name, *args, &block)
        end
        
        # Allows the cached response to be reset, specifically when an attribute changes
        def reset_target
          @target = nil
        end
        
        # For each service you need to overwrite this method. This is where you make the call to fedex
        # and do your magic. See the child classes for examples on how to define this method. It is very
        # important that you cache the result into a variable to avoid uneccessary requests.
        def target
          raise ImplementationError.new("You need to implement a target method that the proxy class can delegate method calls to")
        end
    end
  end
end