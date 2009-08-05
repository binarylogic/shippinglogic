require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Fedex" do
  it "should return the default options" do
    Shippinglogic::Fedex.options.should == {
      :test => true,
      :production_url => "https://gateway.fedex.com:443/xml",
      :test_url => "https://gatewaybeta.fedex.com:443/xml"
    }
  end
end
