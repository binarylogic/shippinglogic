require "builder"

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
        
        # A convenience method for building the address block in your XML request
        def build_address(b, type)
          address_lines = send("#{type}_streets").to_s.split(/(?:\s*\n\s*)+/m, 3)
          
          b.Address do
            b.AddressLine1 address_lines[0] if address_lines[0]
            b.AddressLine2 address_lines[1] if address_lines[1]
            b.AddressLine3 address_lines[2] if address_lines[2]
            b.City send("#{type}_city") if send("#{type}_city")
            b.StateProvinceCode send("#{type}_state") if send("#{type}_state")
            b.PostalCode send("#{type}_postal_code") if send("#{type}_postal_code")
            b.CountryCode send("#{type}_country") if send("#{type}_country")
            b.ResidentialAddressIndicator attribute_names.include?("#{type}_residential") && send("#{type}_residential")
          end
        end
    end
  end
end