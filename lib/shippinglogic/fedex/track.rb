module Shippinglogic
  class Fedex
    # An interface to the track services provided by Fedex. See the track method for more info. Alternatively, you can
    # read up on the track services documentation on the FedEx website.
    module Track
      VERSION = {:major => 3, :intermediate => 0, :minor => 0}
      
      # This returns the various tracking information for a specific tracking number.
      #
      # === Note
      #
      # FedEx does support locating packages through means other than a tracking number.
      # These are not supported and probably won't be until someone needs them. It should
      # be fairly simple to add, but I could not think of a reason why anyone would want to track
      # a package with anything other than a tracking number.
      def track(tracking_number)
        xml = build_track_request(tracking_number)
        response = request(xml)
        parse_track_response(response)
      end
      
      private
        def build_track_request(tracking_number)
          b = builder
          xml = b.TrackRequest(:xmlns => "http://fedex.com/ws/track/v#{VERSION[:major]}") do
            build_authentication(b)
            build_version(b, "trck", VERSION[:major], VERSION[:intermediate], VERSION[:minor])
            
            b.PackageIdentifier do
              b.Value tracking_number
              b.Type "TRACKING_NUMBER_OR_DOORTAG"
            end
            
            b.IncludeDetailedScans true
          end
        end
        
        def parse_track_response(response)
          response[:track_details][:events].collect do |event|
            item = {
              :name => event[:event_description],
              :type => event[:event_type],
              :occured_at => Time.parse(event[:timestamp]),
              :address => event[:address]
            }
            item[:address][:residential] = item[:address][:residential] == "true"
            item
          end
        end
    end
  end
end