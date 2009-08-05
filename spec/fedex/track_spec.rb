require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Fedex Track" do
  it "should track the package" do
    use_response(:basic_track)
    fedex = new_fedex
    events = fedex.track(fedex_tracking_number)
    
    events.size.should == 7
    event = events.first
    event[:name].should == "Delivered"
    event[:type].should == "DL"
    event[:occured_at].should == Time.parse("Mon Dec 08 10:43:37 -0500 2008")
    event[:address].should == {
      :city => "Sacramento",
      :residential => false,
      :state_or_province_code => "CA",
      :postal_code => "95817",
      :country_code => "US"
    }
  end
end
