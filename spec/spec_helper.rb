$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'shippinglogic'
require 'spec'
require 'spec/autorun'
begin; require 'ruby-debug'; rescue LoadError; end
require 'fakeweb'

SPEC_ROOT = File.dirname(__FILE__).freeze
require SPEC_ROOT + "/lib/interceptor"
