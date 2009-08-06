module Shippinglogic
  class FedEx
    # If FedEx responds with an error, we try our best to pull the pertinent information out of that
    # response and raise it with this object. Any time FedEx says there is a problem an object of this
    # class will be raised.
    #
    # === Tip
    #
    # If you want to see the raw respose catch the error object and call the response method. Ex:
    #
    #   begin
    #     # my fedex code
    #   rescue Shippinglogic::FedEx::Error => e
    #     # do whatever you want here, just do:
    #     # e.response
    #     # to get the raw response from fedex
    #   end
    class Error < StandardError
      attr_accessor :code, :message, :response
      
      def initialize(response)
        self.response = response
        
        if response.blank?
          self.message = "The response from FedEx was blank."
        elsif !response.is_a?(Hash)
          self.message = "The response from FedEx was malformed and was not in a valid XML format."
        elsif notifications = response[:notifications]
          self.code = notifications[:code]
          self.message = notifications[:message]
        elsif response[:"soapenv:fault"] && detail = response[:"soapenv:fault"][:detail][:"con:fault"]
          self.code = detail[:"con:error_code"]
          self.message = detail[:"con:reason"]
        else
          self.message = "There was a problem with your fedex request, and we couldn't locate a specific error message. This means your response " +
            "was in an unexpected format. You might try glancing at the raw response by using the 'response' method on this error object."
        end
        
        error_message = ""
        error_message += "(Error: #{code}) " if code
        error_message = message
        
        super(error_message)
      end
    end
  end
end