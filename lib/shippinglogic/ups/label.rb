require "base64"

module Shippinglogic
  class UPS
    class Label < Service
      def self.path
        "/LabelRecovery"
      end
      
      class Details
        attr_accessor :format, :content
        
        def initialize(response)
          return unless details = response.fetch(:label_results, {})[:label_image]
          
          self.format   = label[:label_image_format][:code]
          self.content  = label[:graphic_image]
        end
      end
      
      attribute :tracking_number, :string
      
      private
        def target
          @target ||= Details.new(request(build_request))
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
    end
  end
end