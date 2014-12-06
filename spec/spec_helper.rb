require 'pagerduty_cli'
require 'rspec'

RSpec.configure

# stub for exercising common
class StubPagerdutyCliActor
  include PagerdutyCli::Common
  attr_accessor :options
  def initialize
    @me = 'Stub Actor'
    @options = {}
  end
end
