module Shippinglogic
  class UPS
    # A hash representing default the options. If you are using this in a Rails app the best place
    # to modify or change these options is either in an initializer or your specific environment file. Keep
    # in mind that these options can be modified on the instance level when creating an object. See #initialize
    # for more details.
    #
    # === Options
    #
    # * <tt>:test</tt> - this basically tells us which url to use. If set to true we will use the UPS test URL, if false we
    #   will use the production URL. If you are using this in a rails app, unless you are in your production environment, this
    #   will default to true automatically.
    # * <tt>:test_url</tt> - the test URL for UPS's webservices. (default: https://wwwcie.ups.com:443/ups.app/xml)
    # * <tt>:production_url</tt> - the production URL for UPS's webservices. (default: https://www.ups.com:443/ups.app/xml)
    def self.options
      @options ||= {
        :test => !!(defined?(Rails) && !Rails.env.production?),
        :production_url => "https://www.ups.com:443/ups.app/xml",
        :test_url => "https://wwwcie.ups.com:443/ups.app/xml"
      }
    end

    attr_accessor :key, :password, :account, :meter, :options

    # Before you can use the UPS web services you need to provide 3 credentials:
    #
    # 1. Your UPS access key
    # 2. Your UPS password
    # 3. Your UPS user ID
    #
    #TODO Explain how to acquire those 3 credentials.
    #
    # The last parameter allows you to modify the class options on an instance level. It accepts the
    # same options that the class level method #options accepts. If you don't want to change any of
    # them, don't supply this parameter.
    def initialize(key, password, account, options = {})
      self.key = key
      self.password = password
      self.account = account
      self.options = self.class.options.merge(options)
    end
  end
end