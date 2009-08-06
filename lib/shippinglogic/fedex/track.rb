module Shippinglogic
  class FedEx
    # An interface to the track services provided by FedEx. See the track method for more info. Alternatively, you can
    # read up on the track services documentation on the FedEx website.
    class Track < Service
      class Event; attr_accessor :name, :type, :occured_at, :city, :state, :zip, :country, :residential; end
      
      VERSION = {:major => 3, :intermediate => 0, :minor => 0}
      
      attribute :tracking_number, :string
      
      private
        # This returns the various tracking information for a specific tracking number.
        #
        # === Note
        #
        # FedEx does support locating packages through means other than a tracking number.
        # These are not supported and probably won't be until someone needs them. It should
        # be fairly simple to add, but I could not think of a reason why anyone would want to track
        # a package with anything other than a tracking number.
        def target
          @target ||= parse_track_response(request(build_track_request))
        end
        
        def build_track_request
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
          response[:track_details][:events].collect do |details|
            event = Event.new
            event.name = details[:event_description]
            event.type = details[:event_type]
            event.occured_at = Time.parse(details[:timestamp])
            event.city = details[:address][:city]
            event.state = details[:address][:state_or_province_code]
            event.zip = details[:address][:postal_code]
            event.country = details[:address][:country_code]
            event.residential = details[:address][:residential] == "true"
            event
          end
        end
    end
  end
end