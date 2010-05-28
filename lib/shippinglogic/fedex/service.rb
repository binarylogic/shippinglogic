require "shippinglogic/fedex/request"
require "shippinglogic/fedex/response"

module Shippinglogic
  class FedEx
    class Service < Shippinglogic::Service
      include Request
      include Response
    end
  end
end