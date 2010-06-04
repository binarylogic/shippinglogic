require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FedEx Track" do
  it "should cancel the shipment" do
    use_response(:cancel_not_found)
    fedex = new_fedex
    cancel = fedex.cancel(:tracking_number => fedex_tracking_number)
    lambda { cancel.perform }.should raise_error(Shippinglogic::FedEx::Error, "Unable to retrieve record from database")
  end
end
