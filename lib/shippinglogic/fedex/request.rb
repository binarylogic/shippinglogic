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
    end
  end
end