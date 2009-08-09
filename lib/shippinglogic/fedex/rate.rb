module Shippinglogic
  class FedEx
    # An interface to the rate services provided by FedEx. Allows you to get an array of rates from fedex for a shipment,
    # or a single rate for a specific service.
    #
    # == Options
    # === Shipper options
    #
    # * <tt>shipper_streets</tt> - street part of the address, separate multiple streets with a new line, dont include blank lines.
    # * <tt>shipper_city</tt> - city part of the address.
    # * <tt>shipper_state_</tt> - state part of the address, use state abreviations.
    # * <tt>shipper_postal_code</tt> - postal code part of the address. Ex: zip for the US.
    # * <tt>shipper_country</tt> - country code part of the address. FedEx expects abbreviations, but Shippinglogic will convert full names to abbreviations for you.
    # * <tt>shipper_residential</tt> - a boolean value representing if the address is redential or not (default: false)
    #
    # === Recipient options
    #
    # * <tt>recipient_streets</tt> - street part of the address, separate multiple streets with a new line, dont include blank lines.
    # * <tt>recipient_city</tt> - city part of the address.
    # * <tt>recipient_state</tt> - state part of the address, use state abreviations.
    # * <tt>recipient_postal_code</tt> - postal code part of the address. Ex: zip for the US.
    # * <tt>recipient_country</tt> - country code part of the address. FedEx expects abbreviations, but Shippinglogic will convert full names to abbreviations for you.
    # * <tt>recipient_residential</tt> - a boolean value representing if the address is redential or not (default: false)
    #
    # === Packaging options
    #
    # One thing to note is that FedEx does support multiple package shipments. The problem is that all of the packages must be identical.
    # FedEx specifically notes in their documentation that mutiple package specifications are not allowed. So your only option for a
    # multi package shipment is to increase the package_count option and keep the dimensions and weight the same for all packages. Then again,
    # the documentation for the FedEx web services is terrible, so I could be wrong. Any tests I tried resulted in an error though.
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
    # * <tt>currency_type</tt> - the type of currency. (default: nil, because FedEx will default to your account preferences)
    # * <tt>insured_value</tt> - the value you want to insure, if any. (default: nil)
    # * <tt>payment_type</tt> - one of PAYMENT_TYPES. (default: SENDER)
    # * <tt>payor_account_number</tt> - if the account paying for this ship is different than the account you specified then
    #   you can specify that here. (default: your account number)
    # * <tt>payor_country</tt> - the country code for the account number. (default: US)
    #
    # === Delivery options
    #
    # * <tt>ship_time</tt> - a Time object representing when you want to ship the package. (default: Time.now)
    # * <tt>service_type</tt> - one of SERVICE_TYPES, this is optional, leave this blank if you want a list of all
    #   available services. (default: nil)
    # * <tt>delivery_deadline</tt> - whether or not to include estimated transit times. (default: true)
    # * <tt>dropoff_type</tt> - one of DROP_OFF_TYPES. (default: REGULAR_PICKUP)
    # * <tt>special_services_requested</tt> - any exceptions or special services FedEx needs to be aware of, this should be
    #   one or more of SPECIAL_SERVICES. (default: nil)
    #
    # === Misc options
    #
    # * <tt>rate_request_types</tt> - one or more of RATE_REQUEST_TYPES. (default: ACCOUNT)
    # * <tt>include_transit_times</tt> - whether or not to include estimated transit times. (default: true)
    #
    # == Simple Example
    #
    # Here is a very simple example. Mix and match the options above to get more accurate rates:
    #
    #   fedex = Shippinglogic::FedEx.new(key, password, account, meter)
    #   rates = fedex.rate(
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
    #   #<Shippinglogic::FedEx::Rates::Rate @currency="USD", @name="First Overnight", @cost=#<BigDecimal:19ea290,'0.7001E2',8(8)>,
    #     @deadline=Fri Aug 07 08:00:00 -0400 2009, @type="FIRST_OVERNIGHT", @saturday=false>
    #   
    #   # to show accessor methods
    #   rates.first.name
    #   # => "First Overnight"
    class Rate < Service
      # Each rate result is an object of this class
      class Service; attr_accessor :name, :type, :saturday, :delivered_by, :rate, :currency; end
      
      VERSION = {:major => 6, :intermediate => 0, :minor => 0}
      
      # shipper options
      attribute :shipper_streets,             :string
      attribute :shipper_city,                :string
      attribute :shipper_state,               :string
      attribute :shipper_postal_code,         :string
      attribute :shipper_country,             :string,      :modifier => :country_code
      attribute :shipper_residential,         :boolean,     :default => false
      
      # recipient options
      attribute :recipient_streets,           :string
      attribute :recipient_city,              :string
      attribute :recipient_state,             :string
      attribute :recipient_postal_code,       :string
      attribute :recipient_country,           :string,      :modifier => :country_code
      attribute :recipient_residential,       :boolean,     :default => false
      
      # packaging options
      attribute :packaging_type,              :string,      :default => "YOUR_PACKAGING"
      attribute :package_count,               :integer,     :default => 1
      attribute :package_weight,              :float
      attribute :package_weight_units,        :string,      :default => "LB"
      attribute :package_length,              :integer
      attribute :package_width,               :integer
      attribute :package_height,              :integer
      attribute :package_dimension_units,     :string,      :default => "IN"
      
      # monetary options
      attribute :currency_type,               :string
      attribute :insured_value,               :decimal
      attribute :payment_type,                :string,      :default => "SENDER"
      attribute :payor_account_number,        :string,      :default => lambda { |shipment| shipment.base.account }
      attribute :payor_country,               :string
      
      # delivery options
      attribute :ship_time,                   :datetime,    :default => lambda { |rate| Time.now }
      attribute :service_type,                :string
      attribute :delivery_deadline,           :datetime
      attribute :dropoff_type,                :string,      :default => "REGULAR_PICKUP"
      attribute :special_services_requested,  :array
      
      # misc options
      attribute :rate_request_types,          :array,       :default => ["ACCOUNT"]
      attribute :include_transit_times,       :boolean,     :default => true
      
      private
        def target
          @target ||= parse_response(request(build_request))
        end
        
        def build_request
          b = builder
          xml = b.RateRequest(:xmlns => "http://fedex.com/ws/rate/v#{VERSION[:major]}") do
            build_authentication(b)
            build_version(b, "crs", VERSION[:major], VERSION[:intermediate], VERSION[:minor])
            b.ReturnTransitAndCommit include_transit_times
            b.SpecialServicesRequested special_services_requested.join(",") if special_services_requested.any?
            
            b.RequestedShipment do
              b.ShipTimestamp ship_time.xmlschema if ship_time
              b.ServiceType service_type if service_type
              b.DropoffType dropoff_type if dropoff_type
              b.PackagingType packaging_type if packaging_type
              build_insured_value(b)
              b.Shipper { build_address(b, :shipper) }
              b.Recipient { build_address(b, :recipient) }
              b.ShippingChargesPayment do
                b.PaymentType payment_type if payment_type
                b.Payor do
                  b.AccountNumber payor_account_number if payor_account_number
                  b.CountryCode payor_country if payor_country
                end
              end
              b.RateRequestTypes rate_request_types.join(",") if rate_request_types
              build_package(b)
            end
          end
        end
        
        def parse_response(response)
          return [] if !response[:rate_reply_details]
          
          response[:rate_reply_details].collect do |details|
            shipment_detail = details[:rated_shipment_details].is_a?(Array) ? details[:rated_shipment_details].first : details[:rated_shipment_details]
            cost = shipment_detail[:shipment_rate_detail][:total_net_charge]
            delivered_by = details[:delivery_timestamp] && Time.parse(details[:delivery_timestamp])
            
            if meets_deadline?(delivered_by)
              service = Service.new
              service.name = details[:service_type].titleize
              service.type = details[:service_type]
              service.saturday = details[:applied_options] == "SATURDAY_DELIVERY"
              service.delivered_by = delivered_by
              service.rate = BigDecimal.new(cost[:amount])
              service.currency = cost[:currency]
              service
            end
          end.compact
        end
        
        def meets_deadline?(delivered_by)
          return true if !delivery_deadline
          delivered_by && delivered_by <= delivery_deadline
        end
    end
  end
end