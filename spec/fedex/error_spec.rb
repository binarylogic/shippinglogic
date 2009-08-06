require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FedEx Error" do
  it "should handle blank response errors" do
    use_response(:blank)
    lambda { new_fedex.track(:tracking_number => fedex_tracking_number).size }.should raise_error(Shippinglogic::FedEx::Error, "The response from FedEx was blank.")
  end
  
  it "should pass through malformed errors" do
    use_response(:malformed, :content_type => "")
    lambda { new_fedex.track(:tracking_number => fedex_tracking_number).size }.should raise_error(Shippinglogic::FedEx::Error, "The response from FedEx was malformed and was not in a valid XML format.")
  end
  
  it "should pass through authentication errors" do
    use_response(:failed_authentication)
    fedex = Shippinglogic::FedEx.new("", "", "", "")
    lambda { fedex.track(:tracking_number => fedex_tracking_number).size }.should raise_error(Shippinglogic::FedEx::Error, "Authentication Failed")
  end
  
  it "should pass through unexpected errors" do
    use_response(:unexpected)
    lambda { new_fedex.track(:tracking_number => fedex_tracking_number).size }.should raise_error(Shippinglogic::FedEx::Error, "There was a problem with your fedex request, and " +
      "we couldn't locate a specific error message. This means your response was in an unexpected format. You might try glancing at the raw response " +
      "by using the 'response' method on this error object.")
  end
end
