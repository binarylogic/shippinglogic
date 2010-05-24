require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "UPS" do
  it "should return the default options" do
    spec_helper_options = Shippinglogic::UPS.options
    Shippinglogic::UPS.instance_variable_set("@options", nil)

    Shippinglogic::UPS.options.should == {
      :test => false,
      :production_url => "https://www.ups.com:443/ups.app/xml",
      :test_url => "https://wwwcie.ups.com:443/ups.app/xml"
    }

    Shippinglogic::UPS.instance_variable_set("@options", spec_helper_options)
  end
end
