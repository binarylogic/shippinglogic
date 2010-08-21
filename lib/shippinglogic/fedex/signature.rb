require "base64"

module Shippinglogic
  class FedEx
    # An interface to the signature proof of delivery services provided by FedEx. Allows you to get an image
    # of the signature, or you can tell fedex to fax it to a fax number.
    #
    # == Accessor methods / options
    #
    # * <tt>tracking_number</tt> - the tracking number
    # * <tt>image_type</tt> - one of Enumerations::SIGNATURE_IMAGE_TYPES. (default: LETTER)
    # * <tt>image_file_type</tt> - one of Enumerations::LABEL_FILE_TYPES. (default: PDF)
    # * <tt>fax_number</tt> - if image_type is set to FAX you must provide a fax number here. (default: nil)
    #
    # === Simple Example
    #
    # Here is a very simple example:
    #
    #   fedex = Shippinglogic::FedEx.new(key, password, account, meter)
    #   signature = fedex.signature(:tracking_number => "my number")
    #
    #   signature.inspect
    #   # => #<Shippinglogic::FedEx::Signature::Signature image:string(base64 decoded) >
    #   
    #   signature.image
    #   # => "a bunch of garble (write this to a file and save it)"
    class Signature < Service
      # Each tracking result is an object of this class
      class Signature; attr_accessor :image; end
      
      VERSION = {:major => 3, :intermediate => 0, :minor => 0}
      
      attribute :image_type,      :string,  :default => "LETTER"
      attribute :image_file_type, :string,  :default => "PDF"
      attribute :tracking_number, :string
      attribute :fax_number,      :string
      
      private
        # The parent class Service requires that we define this method. This is our kicker. This method is only
        # called when we need to deal with information from FedEx. Notice the caching into the @target variable.
        def target
          @target ||= parse_response(request(build_request))
        end
        
        # Just building some XML to send off to FedEx. FedEx require this particualr format.
        def build_request
          b = builder
          xml = b.SignatureProofOfDeliveryRequest(:xmlns => "http://fedex.com/ws/track/v#{VERSION[:major]}") do
            build_authentication(b)
            build_version(b, "trck", VERSION[:major], VERSION[:intermediate], VERSION[:minor])
            
            b.Type image_type
            b.TrackingNumber tracking_number
            b.FaxDetail fax_number if fax_number
            b.LetterFormat image_file_type
          end
        end
        
        # Grabbing the response from FedEx and making sense of it. There is a lot of unneeded information
        # in the response.
        def parse_response(response)
          signature = Signature.new
          signature.image = response[:letter] && Base64.decode64(response[:letter])
          signature
        end
    end
  end
end