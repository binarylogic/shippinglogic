require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Shippinglogic Proxy" do
  it "should initialize with a single target argument" do
    lambda{ Shippinglogic::Proxy.new }.should raise_error(ArgumentError)
    lambda{ Shippinglogic::Proxy.new(nil) }.should_not raise_error(ArgumentError)
  end
  
  it "should return the proxy class via the real_class method" do
    proxy = Shippinglogic::Proxy.new(nil)
    proxy.real_class.should == Shippinglogic::Proxy
  end
  
  it "should preserve the double-underscore methods" do
    target = "TARGET"
    proxy = Shippinglogic::Proxy.new(target)
    proxy.__id__.should_not == target.__id__
    proxy.__send__(:real_class).should_not == target.__send__(:class)
  end
  
  it "should delegate all other methods to the target" do
    target = ["TESTING", 1, 2, 3]
    proxy = Shippinglogic::Proxy.new(target)
    proxy.class.should == target.class
    proxy.size.should == target.size
    proxy.object_id.should == target.object_id
  end
end