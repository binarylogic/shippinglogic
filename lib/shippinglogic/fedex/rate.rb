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
    # * <tt>shipper_country</tt> - country code part of the address, use abbreviations, ex: 'US'
    # * <tt>shipper_residential</tt> - a boolean value representing if the address is redential or not (default: false)
    #
    # === Recipient options
    #
    # * <tt>recipient_streets</tt> - street part of the address, separate multiple streets with a new line, dont include blank lines.
    # * <tt>recipient_city</tt> - city part of the address.
    # * <tt>recipient_state</tt> - state part of the address, use state abreviations.
    # * <tt>recipient_postal_code</tt> - postal code part of the address. Ex: zip for the US.
    # * <tt>recipient_country</tt> - country code part of the address, use abbreviations, ex: 'US'
    # * <tt>recipient_residential</tt> - a boolean value representing if the address is redential or not (default: false)
    #
    # === Packaging options
    #
    # * <tt>packaging_type</tt> - one of PACKAGE_TYPES. (default: YOUR_PACKAGING)
    # * <tt>packages</tt> - an array of packages included in the shipment. This should be an array of hashes with the following keys:
    #   * <tt>:weight</tt> - the weight
    #   * <tt>:weight_units</tt> - either LB or KG. (default: LB)
    #   * <tt>:length</tt> - the length.
    #   * <tt>:width</tt> - the width.
    #   * <tt>:height</tt> - the height.
    #   * <tt>:dimension_units</tt> - either IN or CM. (default: IN)
    #
    # === Date options
    #
    # * <tt>ship_time</tt> - a Time object representing when you want to ship the package. (default: Time.now)
    # * <tt>include_transit_times</tt> - whether or not to include estimated transit times. (default: true)
    # * <tt>delivery_deadline</tt> - whether or not to include estimated transit times. (default: true)
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
    # === Misc options
    #
    # * <tt>service_type</tt> - one of SERVICE_TYPES, this is optional, leave this blank if you want a list of all
    #   available services. (default: nil)
    # * <tt>dropoff_type</tt> - one of DROP_OFF_TYPES. (default: REGULAR_PICKUP)
    # * <tt>special_services_requested</tt> - any exceptions or special services FedEx needs to be aware of, this should be
    #   one or more of SPECIAL_SERVICES. (default: nil)
    # * <tt>rate_request_types</tt> - one or more of RATE_REQUEST_TYPES. (default: ACCOUNT)
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
    #     :recipient_country_code => "US"
    #     :packages => [{:weight => 24, :length => 12, :width => 12, :height => 12}]
    #   )
    #   rates.first
    #   #<Shippinglogic::FedEx::Rates::Rate @currency="USD", @name="First Overnight", @cost=#<BigDecimal:19ea290,'0.7001E2',8(8)>,
    #     @deadline=Fri Aug 07 08:00:00 -0400 2009, @type="FIRST_OVERNIGHT", @saturday=false>
    #   
    #   rates.first.name
    #   # => "First Overnight"
    class Rate < Service
      # Each rate result is an object of this class
      class Rate; attr_accessor :name, :type, :saturday, :deadline, :rate, :currency; end
      
      VERSION = {:major => 6, :intermediate => 0, :minor => 0}
      
      # shipper options
      attribute :shipper_streets,             :string
      attribute :shipper_city,                :string
      attribute :shipper_state,               :string
      attribute :shipper_postal_code,         :string
      attribute :shipper_country,             :string
      attribute :shipper_residential,         :boolean,     :default => false
      
      # recipient options
      attribute :recipient_streets,           :string
      attribute :recipient_city,              :string
      attribute :recipient_state,             :string
      attribute :recipient_postal_code,       :string
      attribute :recipient_country,           :string
      attribute :recipient_residential,       :boolean,     :default => false
      
      # packaging options
      attribute :packaging_type,              :string,      :default => "YOUR_PACKAGING"
      attribute :packages,                    :array
      
      # date options
      attribute :ship_time,                   :datetime,    :default => lambda { |rate| Time.now }
      attribute :include_transit_times,       :boolean,     :default => true
      attribute :delivery_deadline,           :datetime
      
      # monetary options
      attribute :currency_type,               :string
      attribute :insured_value,               :big_decimal
      attribute :payment_type,                :string,      :default => "SENDER"
      attribute :payor_account_number,        :string,      :default => lambda { |shipment| shipment.base.account }
      attribute :payor_country,               :string
      
      # misc options
      attribute :service_type,                :string
      attribute :dropoff_type,                :string,      :default => "REGULAR_PICKUP"
      attribute :special_services_requested,  :array
      attribute :rate_request_types,          :array,       :default => ["ACCOUNT"]
      
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
              b.TotalInsuredValue insured_value if insured_value
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
              b.PackageCount packages.size
              b.PackageDetail "INDIVIDUAL_PACKAGES"
              
              packages.each_with_index { |package, index| build_package(b, package, index + 1) }
            end
          end
        end
        
        def parse_response(response)
          response[:rate_reply_details].collect do |details|
            shipment_detail = details[:rated_shipment_details].is_a?(Array) ? details[:rated_shipment_details].first : details[:rated_shipment_details]
            cost = shipment_detail[:shipment_rate_detail][:total_net_charge]
            deadline = details[:delivery_timestamp] && Time.parse(details[:delivery_timestamp])
            
            next if delivery_deadline && !meets_deadline?(delivery_deadline)
            
            rate = Rate.new
            rate.name = details[:service_type].titleize
            rate.type = details[:service_type]
            rate.saturday = details[:applied_options] == "SATURDAY_DELIVERY"
            rate.deadline = details[:delivery_timestamp] && Time.parse(details[:delivery_timestamp])
            rate.rate = BigDecimal.new(cost[:amount])
            rate.currency = cost[:currency]
            rate
          end
        end
        
        def meets_deadline?(delivery_deadline)
          !deadline || deadline > delivery_deadline
        end
    end
  end
end