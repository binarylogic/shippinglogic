module Shippinglogic
  class UPS
    # Methods relating to building and sending a request to UPS's web services.
    module Request
      private
        # Convenience method for sending requests to UPS
        def request(body)
          real_class.post(base.url + real_class.path, :body => body)
        end
        
        # Convenience method to create a builder object so that our builder options are consistent across
        # the various services.
        #
        # Ex: if I want to change the indent level to 3 it should change for all requests built.
        def builder
          b = Builder::XmlMarkup.new(:indent => 2)
          b.instruct!
          b
        end
        
        # A convenience method for building the authentication block in your XML request
        def build_authentication(b)
          b.AccessRequest(:"xml:lang" => "en-US") do
            b.AccessLicenseNumber base.key
            b.UserId base.account
            b.Password base.password
          end
        end
        
        # A convenience method for choosing the appropriate tracking reference number to include a
        # UPS tracking XML request.
        def build_effective_tracking_number(b)
          if tracking_number
            b.TrackingNumber tracking_number
          elsif shipment_identification_number
            b.ShipmentIdentificationNumber shipment_identification_number
          elsif reference_number
            b.ReferenceNumber reference_number
          else
            b.TrackingNumber
          end
        end
    end
  end
end