require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FedEx Signature" do
  it "should return an image of the signature" do
    use_response(:basic_signature)
    fedex = new_fedex
    signature = fedex.signature(:tracking_number => fedex_tracking_number)
    signature.image.should_not be_nil
  end
end
