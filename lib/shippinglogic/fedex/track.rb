module Shippinglogic
  class FedEx
    # An interface to the track services provided by FedEx. Allows you to get an array of events for a specific
    # tracking number.
    #
    # == Accessor methods / options
    #
    # * <tt>tracking_number</tt> - the tracking number
    #
    # === Simple Example
    #
    # Here is a very simple example:
    #
    #   fedex = Shippinglogic::FedEx.new(key, password, account, meter)
    #   tracking = fedex.track(:tracking_number => "my number")
    #   tracking.first
    #   # => #<Shippinglogic::FedEx::Track::Event @postal_code="95817", @name="Delivered", @state="CA", @residential=false,
    #   #     @city="Sacramento", @type="DL", @country="US", @occured_at=Mon Dec 08 10:43:37 -0500 2008>
    #   
    #   tracking.first.name
    #   # => "Delivered"
    #
    # === Note
    #
    # FedEx does support locating packages through means other than a tracking number.
    # These are not supported and probably won't be until someone needs them. It should
    # be fairly simple to add, but I could not think of a reason why anyone would want to track
    # a package with anything other than a tracking number.
    class Track < Service
      # Each tracking result is an object of this class
      class Event; attr_accessor :name, :type, :occured_at, :city, :state, :postal_code, :country, :residential; end
      
      VERSION = {:major => 3, :intermediate => 0, :minor => 0}
      
      attribute :tracking_number, :string
      
      private
        # The parent class Service requires that we define this method. This is our kicker. This method is only
        # called when we need to deal with information from FedEx. Notice the caching into the @target variable.
        def target
          @target ||= parse_response(request(build_request))
        end
        
        # Just building some XML to send off to FedEx. FedEx require this particualr format.
        def build_request
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
        
        # Grabbing the response from FedEx and making sense of it. There is a lot of unneeded information
        # in the response.
        def parse_response(response)
          response[:track_details][:events].collect do |details|
            event = Event.new
            event.name = details[:event_description]
            event.type = details[:event_type]
            event.occured_at = Time.parse(details[:timestamp])
            event.city = details[:address][:city]
            event.state = details[:address][:state_or_province_code]
            event.postal_code = details[:address][:postal_code]
            event.country = details[:address][:country_code]
            event.residential = details[:address][:residential] == "true"
            event
          end
        end
    end
  end
end