module Shippinglogic
  class UPS
    # An interface to the shipment canceling service provided by UPS. Allows you to cancel a shipment
    #
    # == Accessor methods / options
    #
    # * <tt>tracking_number</tt> - the tracking number
    #
    # === Simple Example
    #
    #   ups = Shippinglogic::UPS.new(key, password, account)
    #   cancel = ups.cancel(:tracking_number => "my number")
    #   cancel.perform
    #   # => true
    class Cancel < Service
      def self.path
        "/Void"
      end
      
      attribute :tracking_number, :string
      
      # Our services are set up as a proxy. We need to access the underlying object, to trigger the request
      # to UPS. So calling this method is a way to do that since there really is no underlying object
      def perform
        target && true
      end
      
      private
        # The parent class Service requires that we define this method. This is our kicker. This method is only
        # called when we need to deal with information from FedEx. Notice the caching into the @target variable.
        def target
          @target ||= request(build_request)
        end
        
        # Just building some XML to send off to FedEx. FedEx require this particualr format.
        def build_request
          b = builder
          build_authentication(b)
          b.instruct!
          
          b.VoidShipmentRequest do
            b.Request do
              b.RequestAction "1"
            end
            
            #TODO Determine whether tracking numbers are valid shipment identification numbers.
            b.ShipmentIdentificationNumber tracking_number
          end
        end
    end
  end
end