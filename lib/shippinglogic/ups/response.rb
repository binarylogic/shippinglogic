module Shippinglogic
  class UPS
    # Methods relating to receiving a response from UPS and cleaning it up.
    module Response
      SUCCESSFUL_SEVERITIES = ["Warning"]
      
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
          response.is_a?(Hash) && response[:response][:response_status_code] == "1"
        end
        
        # Cleans the response and returns it in a more 'user friendly' format that is easier
        # to work with.
        def clean_response(response)
          cut_to_the_chase(sanitize_response_keys(response))
        end
        
        # FedEx likes nested XML tags, because they send quite a bit of them back in responses.
        # This method just 'cuts to the chase' and get to the heart of the response.
        def cut_to_the_chase(response)
          response.values.first
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

        # Underscores and symbolizes incoming UPS response keys.
        def sanitize_response_key(key)
          key.gsub(/([a-z])([A-Z])/, '\1_\2').downcase.to_sym
        end
    end
  end
end