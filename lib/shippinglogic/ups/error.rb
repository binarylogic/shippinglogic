module Shippinglogic
  class UPS
    # If UPS responds with an error, we try our best to pull the pertinent information out of that
    # response and raise it with this object. Any time UPS says there is a problem an object of this
    # class will be raised.
    #
    # === Tip
    #
    # If you want to see the raw request / respose catch the error object and call the request / response method. Ex:
    #
    #   begin
    #     # my UPS code
    #   rescue Shippinglogic::UPS::Error => e
    #     # do whatever you want here, just do:
    #     # e.request
    #     # e.response
    #     # to get the raw response from UPS
    #   end
    class Error < Shippinglogic::Error
      def initialize(request, response)
        super
        
        if response.blank?
          add_error("The response from UPS was blank.")
        elsif !response.is_a?(Hash)
          add_error("The response from UPS was malformed and was not in a valid XML format.")
        elsif errors = response.fetch(:response, {})[:error]
          errors = errors.is_a?(Array) ? errors : [errors]
          errors.delete_if { |error| Response::SUCCESSFUL_SEVERITIES.include?(error[:error_severity]) }
          errors.each { |error| add_error(error[:error_description], error[:error_code]) }
        else
          add_error(
            "There was a problem with your UPS request, and we couldn't locate a specific error message. This means your response " +
            "was in an unexpected format. You might try glancing at the raw response by using the 'response' method on this error object."
          )
        end
        
        super(errors.collect { |error| error[:message] }.join(", "))
      end
    end
  end
end