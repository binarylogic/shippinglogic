require "shippinglogic/fedex/error"

module Shippinglogic
  class FedEx
    # Methods relating to receiving a response from FedEx and cleaning it up.
    module Response
      SUCCESSFUL_SEVERITIES = ["SUCCESS", "NOTE", "WARNING"]
      
      private
        # Overwriting the request method to clean the response and handle errors.
        def request(body)
          response = clean_response(super)
          
          if success?(response)
            response
          else
            raise Error.new(body, response)
          end
        end
        
        # Was the response a success?
        def success?(response)
          response.is_a?(Hash) && SUCCESSFUL_SEVERITIES.include?(response[:highest_severity])
        end
        
        # Cleans the response and returns it in a more 'user friendly' format that is easier
        # to work with.
        def clean_response(response)
          cut_to_the_chase(sanitize_response_keys(response))
        end
        
        # FedEx likes nested XML tags, because they send quite a bit of them back in responses.
        # This method just 'cuts to the chase' and get to the heart of the response.
        def cut_to_the_chase(response)
          if response.is_a?(Hash) && response.keys.first && response.keys.first.to_s =~ /_reply(_details)?$/
            response.values.first
          else
            response
          end
        end
        
        # Recursively sanitizes the response object by clenaing up any hash keys.
        def sanitize_response_keys(response)
          if response.is_a?(Hash)
            response.inject({}) do |r, (key, value)|
              r[sanitize_response_key(key)] = sanitize_response_keys(value)
              r
            end
          elsif response.is_a?(Array)
            response.collect { |r| sanitize_response_keys(r) }
          else
            response
          end
        end

        # FedEx returns a SOAP response. I just want the plain response without all of the SOAP BS.
        # It basically turns this:
        #
        #   {"v3:ServiceInfo" => ...}
        #
        # into:
        #
        #   {:service_info => ...}
        #
        # I also did not want to use the underscore method provided by ActiveSupport because I am trying
        # to avoid using that as a dependency.
        def sanitize_response_key(key)
          key.to_s.sub(/^(v[0-9]|ns):/, "").gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase.to_sym
        end
    end
  end
end