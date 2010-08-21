require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Shippinglogic Service" do
  it "should initialize with a single base argument" do
    lambda{ Shippinglogic::Service.new }.should raise_error(ArgumentError)
    lambda{ Shippinglogic::Service.new(nil) }.should_not raise_error(ArgumentError)
  end
  
  it "should inherit from Shippinglogic::Proxy" do
    service = Shippinglogic::Service.new(nil)
    service.real_class.ancestors.should include(Shippinglogic::Proxy)
  end
  
  it "should make its base publicly accessible" do
    Shippinglogic::Service.new(nil).base.should == nil
    Shippinglogic::Service.new("BASE").base.should == "BASE"
  end
  
  it "should raise an error when accessing a nonexistent target" do
    service = Shippinglogic::Service.new(nil)
    lambda{ service.target }.should raise_error(Shippinglogic::Error)
  end
end