module Shippinglogic
  class Error < StandardError
    attr_accessor :errors, :request, :response
    
    def initialize(request, response)
      self.request = request
      self.response = response
    end
    
    def add_error(error, code = nil)
      errors << {:message => error, :code => code}
    end
    
    def errors
      @errors ||= []
    end
    
    def message
      errors.collect { |e| e[:message] }.join(", ")
    end
  end
end