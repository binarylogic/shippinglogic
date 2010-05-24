require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FedEx" do
  it "should return the default options" do
    spec_helper_options = Shippinglogic::FedEx.options
    Shippinglogic::FedEx.instance_variable_set("@options", nil)

    Shippinglogic::FedEx.options.should == {
      :test => false,
      :production_url => "https://gateway.fedex.com:443/xml",
      :test_url => "https://gatewaybeta.fedex.com:443/xml"
    }

    Shippinglogic::FedEx.instance_variable_set("@options", spec_helper_options)
  end
end
