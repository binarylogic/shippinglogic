require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FedEx Attributes" do
  it "should allow setting attributes upon initialization" do
    tracking = new_fedex.track(:tracking_number => fedex_tracking_number)
    tracking.tracking_number.should == fedex_tracking_number
  end
  
  it "should allow setting attributes individually" do
    tracking = new_fedex.track
    tracking.tracking_number = fedex_tracking_number
    tracking.tracking_number.should == fedex_tracking_number
  end
  
  it "should allow setting attributes with a hash" do
    tracking = new_fedex.track
    tracking.attributes = {:tracking_number => fedex_tracking_number}
    tracking.tracking_number.should == fedex_tracking_number
  end
  
  it "should allow reading attributes" do
    tracking = new_fedex.track
    tracking.attributes = {:tracking_number => fedex_tracking_number}
    tracking.attributes.should == {:tracking_number => fedex_tracking_number}
  end
  
  it "should implement defaults" do
    rates = new_fedex.rate
    rates.shipper_residential.should == false
  end
  
  it "should use blank array as defaults for arrays" do
    rates = new_fedex.rate
    rates.special_services_requested.should == []
  end
  
  it "should call procs during run time if a default is a proc" do
    rates = new_fedex.rate
    rates.ship_time.to_s.should == Time.now.to_s
  end
  
  it "should reset the cached response if an attribute changes" do
    use_response(:rate_defaults)
    
    fedex = new_fedex
    rates = fedex.rate
    rates.attributes = fedex_shipper
    rates.attributes = fedex_recipient
    rates.attributes = fedex_package
    rates.size.should == 6
    
    use_response(:rate_non_custom_packaging)
    
    rates.packaging_type = "FEDEX_ENVELOPE"
    rates.package_weight = 0.1
    rates.size.should == 5
  end
end
