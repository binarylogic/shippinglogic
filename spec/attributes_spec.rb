require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Service
  ATTRIBUTE_TYPES = %w(array integer float decimal boolean string text datetime)
  
  include Shippinglogic::Attributes
  
  attribute :tracking_number,             :string
  attribute :packaging_type,              :string,    :default => "YOUR_PACKAGING"
  attribute :special_services_requested,  :array
  attribute :ship_time,                   :datetime,  :default => lambda { |shipment| Time.now }
end

describe "Service Attributes" do
  after(:all) do
    Object.send(:remove_const, :Service)
  end
  
  it "should allow setting attributes upon initialization" do
    service = Service.new(:tracking_number => "TEST")
    service.tracking_number.should == "TEST"
  end
  
  it "should allow setting attributes individually" do
    service = Service.new
    service.tracking_number = "TEST"
    service.tracking_number.should == "TEST"
  end
  
  it "should allow setting attributes with a hash" do
    service = Service.new
    service.attributes = {:tracking_number => "TEST"}
    service.tracking_number.should == "TEST"
  end
  
  it "should allow reading attributes" do
    service = Service.new
    service.attributes = {:tracking_number => "TEST"}
    service.attributes.should be_a(Hash)
    service.attributes.should have_key(:tracking_number)
    service.attributes[:tracking_number].should == "TEST"
  end
  
  it "should implement defaults" do
    service = Service.new
    service.packaging_type.should == "YOUR_PACKAGING"
  end
  
  it "should use blank array as defaults for arrays" do
    service = Service.new
    service.special_services_requested.should == []
  end
  
  it "should call procs during run time if a default is a proc" do
    service = Service.new
    service.ship_time.to_s.should == Time.now.to_s
  end
  
  it "should parse string representations of times" do
    service = Service.new
    service.ship_time = "19551105000000"
    service.ship_time.should be_a(Time)
    service.ship_time.strftime("%B") == "November"
    service.ship_time.day.should == 5
    service.ship_time.year.should == 1955
  end
end
