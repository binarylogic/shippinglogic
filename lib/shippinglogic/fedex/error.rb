module Shippinglogic
  class FedEx
    # If FedEx responds with an error, we try our best to pull the pertinent information out of that
    # response and raise it with this object. Any time FedEx says there is a problem an object of this
    # class will be raised.
    #
    # === Tip
    #
    # If you want to see the raw request / respose catch the error object and call the request / response method. Ex:
    #
    #   begin
    #     # my fedex code
    #   rescue Shippinglogic::FedEx::Error => e
    #     # do whatever you want here, just do:
    #     # e.request
    #     # e.response
    #     # to get the raw response from fedex
    #   end
    class Error < StandardError
      attr_accessor :errors, :request, :response
      
      def initialize(request, response)
        self.request = request
        self.response = response
        
        if response.blank?
          add_error("The response from FedEx was blank.")
        elsif !response.is_a?(Hash)
          add_error("The response from FedEx was malformed and was not in a valid XML format.")
        elsif notifications = response[:notifications]
          notifications = notifications.is_a?(Array) ? notifications : [notifications]
          notifications.delete_if { |notification| Response::SUCCESSFUL_SEVERITIES.include?(notification[:severity]) }
          notifications.each { |notification| add_error(notification[:message], notification[:code]) }
        elsif response[:"soapenv:fault"] && detail = response[:"soapenv:fault"][:detail][:"con:fault"]
          add_error(detail[:"con:reason"], detail[:"con:error_code"])
          
          if detail[:"con:details"] && detail[:"con:details"][:"con1:validation_failure_detail"] && messages = detail[:"con:details"][:"con1:validation_failure_detail"][:"con1:message"]
            messages = messages.is_a?(Array) ? messages : [messages]
            messages.each { |message| add_error(message) }
          end
        else
          add_error(
            "There was a problem with your fedex request, and we couldn't locate a specific error message. This means your response " +
            "was in an unexpected format. You might try glancing at the raw response by using the 'response' method on this error object."
          )
        end
        
        super(errors.collect { |error| error[:message].strip }.to_sentence)
      end
      
      def add_error(error, code = nil)
        errors << {:message => error, :code => code}
      end
      
      def errors
        @errors ||= []
      end
    end
  end
end