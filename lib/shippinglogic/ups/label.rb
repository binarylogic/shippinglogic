require "base64"

module Shippinglogic
  class UPS
    class Label < Service
      def self.path
        "/LabelRecovery"
      end
      
      attribute :tracking_number, :string
      
      private
        def target
          @target ||= parse_response(request(build_request))
        end
        
        # Just building some XML to send off to USP using our various options
        def build_request
          b = builder
          build_authentication(b)
          b.instruct!
          
          b.LabelRecoveryRequest do
            b.Request do
              b.RequestAction "LabelRecovery"
            end
            
            b.LabelSpecification do
              b.LabelImageFormat do
                b.Code "GIF"
              end
            end
            
            b.Translate do
              b.LanguageCode "eng"
              b.DialectCode "US"
              b.Code "01"
            end
            
            b.TrackingNumber tracking_number
          end
        end
        
        def parse_response(response)
          return unless details = response.fetch(:label_results, {})[:label_image]
          Base64.decode64(details[:graphic_image])
        end
    end
  end
end