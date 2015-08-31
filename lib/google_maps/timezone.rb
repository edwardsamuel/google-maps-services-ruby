module GoogleMaps

  # Performs requests to the Google Maps Directions API."""
  module TimeZone

    # Get time zone for a location on the earth, as well as that location's
    # time offset from UTC.
    #
    # @param [Hash, Array] location The latitude/longitude value representing the location to
    #     look up.
    # @param [Integer, DateTime] timestamp Timestamp specifies the desired time as seconds since
    #     midnight, January 1, 1970 UTC. The Time Zone API uses the timestamp to
    #     determine whether or not Daylight Savings should be applied. Times
    #     before 1970 can be expressed as negative values. Optional. Defaults to
    #     ``datetime.now()``.
    # @param [String] language The language in which to return results.
    #
    # @return [Hash]
    def timezone(location, timestamp=nil, language=nil)
      location = GoogleMaps::Convert.latlng(location)
      timestamp = GoogleMaps::Convert.time(timestamp || DateTime.now)

      params = {
        "location": location,
        "timestamp": timestamp
      }

      params["language"] = language if language

      return get( "/maps/api/timezone/json", params)
    end
  end
end