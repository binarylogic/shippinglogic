require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FedEx Validation" do
  it "should not be valid" do
    use_response(:blank)
    rates = new_fedex.rate
    rates.valid?.should == false
    rates.errors.should == ["The response from FedEx was blank."]
  end
end
