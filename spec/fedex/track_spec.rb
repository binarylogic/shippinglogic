require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FedEx Track" do
  it "should track the package" do
    use_response(:track_defaults)
    
    fedex = new_fedex
    track_details = fedex.track(:tracking_number => fedex_tracking_number)
    
    track_details.origin_city.should == "NASHVILLE"
    track_details.origin_state.should == "TN"
    track_details.origin_country.should == "US"
    track_details.should_not be_origin_residential
    
    track_details.destination_city.should == "Sacramento"
    track_details.destination_state.should == "CA"
    track_details.destination_country.should == "US"
    track_details.should_not be_destination_residential
    
    track_details.signature_name.should == "KKING"
    track_details.service_type.should == "FEDEX_GROUND"
    track_details.status.should == "Delivered"
    track_details.delivery_at.should == Time.parse("2008-12-08T07:43:37-08:00")
    track_details.tracking_number.should == "077973360403984"
    
    track_details.events.size.should == 7
    event = track_details.events.first
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
