module Shippinglogic
  class FedEx
    # Methods relating to building and sending a request to FedEx's web services.
    module Request
      private
        # Convenience method for sending requests to FedEx
        def request(body)
          real_class.post(base.options[:test] ? base.options[:test_url] : base.options[:production_url], :body => body)
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
          b.WebAuthenticationDetail do
            b.UserCredential do
              b.Key base.key
              b.Password base.password
            end
          end
          
          b.ClientDetail do
            b.AccountNumber base.account
            b.MeterNumber base.meter
          end
        end
        
        # A convenience method for building the version block in your XML request
        def build_version(b, service, major, intermediate, minor)
          b.Version do
            b.ServiceId service
            b.Major major
            b.Intermediate intermediate
            b.Minor minor
          end
        end
        
        def build_contact(b, type)
          b.Contact do
            b.Contact send("#{type}_name") if send("#{type}_name")
            b.CompanyName send("#{type}_company_name") if send("#{type}_company_name")
            b.PhoneNumber send("#{type}_phone_number") if send("#{type}_phone_number")
          end
        end
        
        def build_address(b, type)
          b.Address do
            b.StreetLines send("#{type}_streets") if send("#{type}_streets")
            b.City send("#{type}_city") if send("#{type}_city")
            b.StateOrProvinceCode send("#{type}_state") if send("#{type}_state")
            b.PostalCode send("#{type}_postal_code") if send("#{type}_postal_code")
            b.CountryCode send("#{type}_country") if send("#{type}_country")
            b.Residential send("#{type}_residential")
          end
        end
        
        def validate_package(package)
          raise ArgumentError.new("Each package much be in a Hash format") if !package.is_a?(Hash)
          package.assert_valid_keys(:weight, :weight_units, :length, :height, :width, :dimension_units)
        end
        
        def build_package(b, package, count)
          package.symbolize_keys! if package.respond_to?(:symbolize_keys!)
          validate_package(package)
          
          b.RequestedPackages do
            b.SequenceNumber count
            
            b.Weight do
              b.Units package[:weight_units] || "LB"
              b.Value package[:weight]
            end
            
            b.Dimensions do
              b.Length package[:length]
              b.Width package[:width]
              b.Height package[:height]
              b.Units package[:dimension_units] || "IN"
            end
          end
        end
    end
  end
end