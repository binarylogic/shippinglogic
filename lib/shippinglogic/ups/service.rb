require "shippinglogic/ups/request"
require "shippinglogic/ups/response"

module Shippinglogic
  class UPS
    class Service < Shippinglogic::Service
      include Request
      include Response
    end
  end
end