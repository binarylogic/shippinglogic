require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Fedex Response" do
  it "should handle blank response errors" do
    use_response(:blank)
    fedex = new_fedex
    lambda { fedex.track(fedex_tracking_number) }.should raise_error(Shippinglogic::Fedex::Error, "The response from Fedex was blank.")
  end
  
  it "should pass through malformed errors" do
    use_response(:malformed, :content_type => "")
    fedex = new_fedex
    lambda { fedex.track(fedex_tracking_number) }.should raise_error(Shippinglogic::Fedex::Error, "The response from Fedex was malformed and was not in a valid XML format.")
  end
  
  it "should pass through authentication errors" do
    use_response(:failed_authentication)
    fedex = Shippinglogic::Fedex.new("", "", "", "")
    lambda { fedex.track(fedex_tracking_number) }.should raise_error(Shippinglogic::Fedex::Error, "Authentication Failed")
  end
  
  it "should pass through unexpected errors" do
    use_response(:unexpected)
    fedex = new_fedex
    lambda { fedex.track(fedex_tracking_number) }.should raise_error(Shippinglogic::Fedex::Error, "There was a problem with your fedex request, and " +
      "we couldn't locate a specific error message. This means your response was in an unexpected format. You might try glancing at the raw response " +
      "by using the 'response' method on this error object.")
  end
end
