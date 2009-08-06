require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FedEx Track" do
  it "should track the package" do
    use_response(:basic_track)
    fedex = new_fedex
    events = fedex.track(:tracking_number => fedex_tracking_number)
    
    events.size.should == 7
    event = events.first
    event.name.should == "Delivered"
    event.type.should == "DL"
    event.occured_at.should == Time.parse("Mon Dec 08 10:43:37 -0500 2008")
    event.city.should == "Sacramento"
    event.state.should == "CA"
    event.postal_code.should == "95817"
    event.country.should == "US"
    event.residential.should == false
  end
end
