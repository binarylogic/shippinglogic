module Shippinglogic
  class FedEx
    # An interface to the shipment canceling service provided by FedEx. Allows you to cancel a shipment
    #
    # == Accessor methods / options
    #
    # * <tt>tracking_number</tt> - the tracking number
    # * <tt>deletion_control</tt> - one of Enumerations::DELETION_CONTROL (default: DELETE_ALL_PACKAGES)
    #
    # === Simple Example
    #
    #   fedex = Shippinglogic::FedEx.new(key, password, account, meter)
    #   cancel = fedex.cancel(:tracking_number => "my number")
    #   cancel.perform
    #   # => true
    class Cancel < Service
      VERSION = {:major => 6, :intermediate => 0, :minor => 0}
      
      attribute :tracking_number,     :string
      attribute :deletion_control,    :string,  :default => "DELETE_ALL_PACKAGES"
      
      # Our services are set up as a proxy. We need to access the underlying object, to trigger the request
      # to fedex. So calling this method is a way to do that since there really is no underlying object
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
          xml = b.DeleteShipmentRequest(:xmlns => "http://fedex.com/ws/ship/v#{VERSION[:major]}") do
            build_authentication(b)
            build_version(b, "ship", VERSION[:major], VERSION[:intermediate], VERSION[:minor])
            b.TrackingNumber tracking_number
            b.DeletionControl deletion_control
          end
        end
    end
  end
end