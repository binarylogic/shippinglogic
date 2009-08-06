module Shippinglogic
  class FedEx
    module Validation
      def self.included(klass)
        klass.class_eval do
          attr_accessor :errors
        end
      end
      
      def errors
        @errors ||= []
      end
      
      def valid?
        begin
          target
          true
        rescue Error => e
          errors.clear
          self.errors << e.message
          false
        end
      end
    end
  end
end