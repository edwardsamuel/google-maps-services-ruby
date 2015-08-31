require 'minitest_helper'
require 'date'
# require 'awesome_print'

class GeocodingTest < Minitest::Test

  def setup
    GoogleMaps.configure do |c|
      c.key = "AIza"
    end

    @client = GoogleMaps::Client.new
  end

  def test_simple_geocode
    result = @client.geocode('Sydney')
    # awesome_print result
  end

end
