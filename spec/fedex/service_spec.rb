require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FedEx Service" do
  it "should not hit fedex until needed" do
    # If fedex was hit we would get an exception before the response is blank
    use_response(:blank)
    lambda { new_fedex.track(:tracking_number => fedex_tracking_number) }.should_not raise_error
  end
  
  it "should hit fedex when needed" do
    use_response(:blank)
    lambda { new_fedex.track(:tracking_number => fedex_tracking_number).size }.should raise_error(Shippinglogic::FedEx::Error)
  end
  
  it "should delegate the class method to the target" do
    use_response(:track_defaults)
    new_fedex.track(:tracking_number => fedex_tracking_number).class.should == Shippinglogic::FedEx::Track::Details
  end
end
