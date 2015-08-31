require 'minitest_helper'
require 'date'

class GeocodingTest < Minitest::Test

  def setup
    GoogleMaps.configure do |c|
      c.key = "AIzaS"
    end

    @client = GoogleMaps::Client.new
  end

  def test_simple_geocode
    result = @client.geocode('Sydney')
  end

end
