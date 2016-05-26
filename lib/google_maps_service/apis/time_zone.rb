require_relative './base'
require 'date'

module GoogleMapsService
  module Apis
    # Performs requests to the Google Maps TimeZone API.
    class TimeZone < Base
      # Base path of TimeZone API
      BASE_PATH = '/maps/api/timezone/json'.freeze

      # Get time zone for a location on the earth, as well as that location's
      # time offset from UTC.
      #
      # @example Current time zone
      #   timezone = client.timezone([39.603481, -119.682251])
      #
      # @example Time zone at certain time
      #   timezone = client.timezone([39.603481, -119.682251],
      #                              timestamp: Time.at(1608))
      #
      # @param [Hash, Array] location The latitude/longitude value representing
      #     the location to look up.
      # @option options [Integer, DateTime] timestamp Timestamp specifies
      #     the desired time as seconds since midnight, January 1, 1970 UTC.
      #     The Time Zone API uses the timestamp to determine whether or not
      #     Daylight Savings should be applied. Times before 1970 can be
      #     expressed as negative values. Optional. Defaults to `Time.now`.
      # @option options [String] language The language in which to return
      #     results.
      #
      # @return [Hash] Time zone object.
      def timezone(location, options = {})
        params = options.clone
        params[:location] = location
        params[:timestamp] ||= Time.now

        convert params, :location, with: :latlng
        convert params, :timestamp, with: :time

        get(BASE_PATH, params)
      end
    end
  end
end
