require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Service Attributes" do
  before(:all) do
    class Service
      ATTRIBUTE_TYPES = %w(array integer float decimal boolean string text datetime)
      
      include Shippinglogic::Attributes
      
      ATTRIBUTE_TYPES.each do |type|
        attribute :"#{type}_without_default",     type
        attribute :"#{type}_with_default_value",  type, :default => 1
        attribute :"#{type}_with_default_proc",   type, :default => lambda{ Time.now }
      end
    end
  end
  
  after(:all) do
    Object.send(:remove_const, :Service)
  end
  
  it "should allow setting attributes upon initialization" do
    service = Service.new(:string_without_default => "TEST")
    service.string_without_default.should == "TEST"
  end
  
  it "should allow setting attributes individually" do
    service = Service.new
    service.string_without_default = "TEST"
    service.string_without_default.should == "TEST"
  end
  
  it "should allow setting attributes with a hash" do
    service = Service.new
    service.attributes = {:string_without_default => "TEST"}
    service.string_without_default.should == "TEST"
  end
  
  it "should allow reading attributes" do
    service = Service.new
    service.attributes = {:string_without_default => "TEST"}
    service.attributes.should be_a(Hash)
    service.attributes.should have_key(:string_without_default)
    service.attributes[:string_without_default].should == "TEST"
  end
  
  it "should implement defaults" do
    service = Service.new
    service.integer_with_default_value.should == 1
  end
  
  it "should use blank array as defaults for arrays" do
    service = Service.new
    service.array_without_default.should == []
  end
  
  it "should call procs during run time if a default is a proc" do
    service = Service.new
    service.datetime_with_default_proc.to_s.should == Time.now.to_s
  end
  
  it "should parse string representations of times" do
    service = Service.new
    service.datetime_without_default = "19551105000000"
    service.datetime_without_default.should be_a(Time)
    service.datetime_without_default.strftime("%B") == "November"
    service.datetime_without_default.day.should == 5
    service.datetime_without_default.year.should == 1955
  end
end
