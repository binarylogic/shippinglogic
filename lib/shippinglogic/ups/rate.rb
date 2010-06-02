module Shippinglogic
  class UPS
    # An interface to the rate services provided by UPS. Allows you to get an array of rates from UPS for a shipment,
    # or a single rate for a specific service.
    #
    # == Options
    # === Shipper options
    #
    # * <tt>shipper_name</tt> - name of the shipper.
    # * <tt>shipper_streets</tt> - street part of the address, separate multiple streets with a new line, dont include blank lines.
    # * <tt>shipper_city</tt> - city part of the address.
    # * <tt>shipper_state_</tt> - state part of the address, use state abreviations.
    # * <tt>shipper_postal_code</tt> - postal code part of the address. Ex: zip for the US.
    # * <tt>shipper_country</tt> - country code part of the address. UPS expects abbreviations, but Shippinglogic will convert full names to abbreviations for you.
    #
    # === Recipient options
    #
    # * <tt>recipient_name</tt> - name of the recipient.
    # * <tt>recipient_streets</tt> - street part of the address, separate multiple streets with a new line, dont include blank lines.
    # * <tt>recipient_city</tt> - city part of the address.
    # * <tt>recipient_state</tt> - state part of the address, use state abreviations.
    # * <tt>recipient_postal_code</tt> - postal code part of the address. Ex: zip for the US.
    # * <tt>recipient_country</tt> - country code part of the address. UPS expects abbreviations, but Shippinglogic will convert full names to abbreviations for you.
    # * <tt>recipient_residential</tt> - a boolean value representing if the address is redential or not (default: false)
    #
    # === Packaging options
    #
    # One thing to note is that UPS does support multiple package shipments. The problem is that all of the packages must be identical.
    # UPS specifically notes in their documentation that mutiple package specifications are not allowed. So your only option for a
    # multi package shipment is to increase the package_count option and keep the dimensions and weight the same for all packages. Then again,
    # the documentation for the UPS web services is terrible, so I could be wrong. Any tests I tried resulted in an error though.
    #
    # * <tt>packaging_type</tt> - one of PACKAGE_TYPES. (default: YOUR_PACKAGING)
    # * <tt>package_count</tt> - the number of packages in your shipment. (default: 1)
    # * <tt>package_weight</tt> - a single packages weight.
    # * <tt>package_weight_units</tt> - either LB or KG. (default: LB)
    # * <tt>package_length</tt> - a single packages length, only required if using YOUR_PACKAGING for packaging_type.
    # * <tt>package_width</tt> - a single packages width, only required if using YOUR_PACKAGING for packaging_type.
    # * <tt>package_height</tt> - a single packages height, only required if using YOUR_PACKAGING for packaging_type.
    # * <tt>package_dimension_units</tt> - either IN or CM. (default: IN)
    #
    # === Monetary options
    #
    # * <tt>currency_type</tt> - the type of currency. (default: nil, because UPS will default to your account preferences)
    # * <tt>insured_value</tt> - the value you want to insure, if any. (default: nil)
    # * <tt>payor_account_number</tt> - if the account paying for this ship is different than the account you specified then
    #   you can specify that here. (default: your account number)
    #
    # === Delivery options
    #
    # * <tt>service_type</tt> - one of SERVICE_TYPES, this is optional, leave this blank if you want a list of all
    #   available services. (default: nil)
    # * <tt>delivery_deadline</tt> - whether or not to include estimated transit times. (default: true)
    # * <tt>dropoff_type</tt> - one of DROP_OFF_TYPES. (default: REGULAR_PICKUP)
    #
    # === Misc options
    #
    # * <tt>documents_only</tt> - whether the package consists of only documents (default: false)
    #
    # == Simple Example
    #
    # Here is a very simple example. Mix and match the options above to get more accurate rates:
    #
    #   ups = Shippinglogic::UPS.new(key, password, account)
    #   rates = ups.rate(
    #     :shipper_postal_code => "10007",
    #     :shipper_country => "US",
    #     :recipient_postal_code => "75201",
    #     :recipient_country_code => "US",
    #     :package_weight => 24,
    #     :package_length => 12,
    #     :package_width => 12,
    #     :package_height => 12
    #   )
    #
    #   rates.first
    #   #<Shippinglogic::UPS::Rates::Rate @currency="USD", @name="First Overnight", @cost=#<BigDecimal:19ea290,'0.7001E2',8(8)>,
    #     @deadline=Fri Aug 07 08:00:00 -0400 2009, @type="FIRST_OVERNIGHT", @saturday=false>
    #   
    #   # to show accessor methods
    #   rates.first.name
    #   # => "First Overnight"
    class Rate < Service
      def self.path
        "/Rate"
      end
      
      # Each rate result is an object of this class
      class Service; attr_accessor :name, :type, :speed, :rate, :currency; end
      
      VERSION = {:major => 6, :intermediate => 0, :minor => 0}
      
      # shipper options
      attribute :shipper_name,                :string
      attribute :shipper_streets,             :string
      attribute :shipper_city,                :string
      attribute :shipper_state,               :string
      attribute :shipper_postal_code,         :string
      attribute :shipper_country,             :string,      :modifier => :country_code
      
      # recipient options
      attribute :recipient_name,              :string
      attribute :recipient_streets,           :string
      attribute :recipient_city,              :string
      attribute :recipient_state,             :string
      attribute :recipient_postal_code,       :string
      attribute :recipient_country,           :string,      :modifier => :country_code
      attribute :recipient_residential,       :boolean,     :default => false
      
      # packaging options
      attribute :packaging_type,              :string,      :default => "00"
      attribute :package_count,               :integer,     :default => 1
      attribute :package_weight,              :float
      attribute :package_weight_units,        :string,      :default => "LBS"
      attribute :package_length,              :float
      attribute :package_width,               :float
      attribute :package_height,              :float
      attribute :package_dimension_units,     :string,      :default => "IN"
      
      # monetary options
      attribute :currency_type,               :string
      attribute :insured_value,               :decimal
      attribute :payor_account_number,        :string,      :default => lambda { |shipment| shipment.base.account }
      
      # delivery options
      attribute :service_type,                :string
      attribute :dropoff_type,                :string,      :default => "01"
      attribute :saturday,                    :boolean,     :default => false
      
      # misc options
      attribute :documents_only,              :boolean,     :default => false
      
      private
        def target
          @target ||= parse_response(request(build_request))
        end
        
        def build_request
          b = builder
          build_authentication(b)
          b.instruct!
          
          b.RatingServiceSelectionRequest do
            b.Request do
              b.RequestAction "Rate"
              b.RequestOption service_type ? "Rate" : "Shop"
            end
            
            b.PickupType do
              b.Code dropoff_type
            end
            
            b.Shipment do
              b.Shipper do
                b.Name shipper_name
                b.ShipperNumber payor_account_number
                build_address(b, :shipper)
              end
              
              b.ShipTo do
                b.CompanyName recipient_name
                build_address(b, :recipient)
              end
              
              if service_type
                b.Service do
                  b.Code service_type
                end
              end
              
              b.DocumentsOnly if documents_only
              
              package_count.times do |i|
                b.Package do
                  b.PackagingType do
                    b.Code packaging_type
                  end
                  
                  b.Dimensions do
                    b.UnitOfMeasurement do
                      b.Code package_dimension_units
                    end
                    
                    b.Length "%.2f" % package_length
                    b.Width "%.2f" % package_width
                    b.Height "%.2f" % package_height
                  end
                  
                  b.PackageWeight do
                    b.UnitOfMeasurement do
                      b.Code package_weight_units
                    end
                    
                    b.Weight "%.1f" % package_weight
                  end
                  
                  b.PackageServiceOptions do
                    if insured_value
                      b.InsuredValue do
                        b.MonetaryValue insured_value
                        b.CurrencyCode currency_type
                      end
                    end
                  end
                end
              end
              
              b.ShipmentServiceOptions do
                b.SaturdayDelivery if saturday
              end
            end
          end
        end
        
        def parse_response(response)
          puts response.inspect
          return [] if !response[:rated_shipment]
          
          response[:rated_shipment].collect do |details|
            service = Service.new
            service.name = Enumerations::SERVICE_TYPES[details[:service][:code]]
            service.type = service.name
            service.speed = (days = details[:guaranteed_days_to_delivery]) && (days.to_i * 86400)
            service.rate = BigDecimal.new(details[:total_charges][:monetary_value])
            service.currency = details[:total_charges][:currency_code]
            service
          end
        end
    end
  end
end