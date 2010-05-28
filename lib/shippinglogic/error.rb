module Shippinglogic
  class Error < StandardError
    attr_accessor :errors
    
    def add_error(error, code = nil)
      errors << {:message => error, :code => code}
    end
    
    def errors
      @errors ||= []
    end
  end
end