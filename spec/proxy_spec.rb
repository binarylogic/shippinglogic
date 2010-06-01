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
  
  it "should preserve the send method" do
    proxy = Shippinglogic::Proxy.new(nil)
    proxy.send(:real_class).should == proxy.real_class
  end
  
  it "should preserve the double-underscore methods" do
    target = "TARGET"
    proxy = Shippinglogic::Proxy.new(target)
    proxy.__id__.should_not == target.__id__
    proxy.__send__(:real_class).should == proxy.real_class
  end
  
  it "should preserve the object_id method" do
    target = "TARGET"
    proxy = Shippinglogic::Proxy.new(target)
    proxy.object_id.should_not == target.object_id
  end
  
  it "should delegate all other methods to the target" do
    target = ["TESTING", 1, 2, 3]
    proxy = Shippinglogic::Proxy.new(target)
    proxy.class.should == target.class
    proxy.size.should == target.size
  end
end