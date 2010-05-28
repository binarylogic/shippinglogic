require "shippinglogic/error"

module Shippinglogic
  # This module is more for application integration, so you can do something like:
  #
  #   tracking = fedex.tracking
  #   if tracking.valid?
  #     # render a successful response
  #   else
  #     # do something with the errors: fedex.errors
  #   end
  module Validation
    # Just an array of errors that were encounted if valid? returns false.
    def errors
      @errors ||= []
    end
    
    # Allows you to determine if the request is valid or not. All validation is delegated to the FedEx
    # services, so what this does is make a call to FedEx and rescue any errors, then it puts those
    # error into the 'errors' array.
    def valid?
      begin
        target
        true
      rescue Error => e
        errors.clear
        self.errors << e.message
        false
      end
    end
  end
end