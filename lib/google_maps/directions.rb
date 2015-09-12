module GoogleMaps

  # Performs requests to the Google Maps Directions API.
  module Directions

    # Get directions between an origin point and a destination point.
    #
    # @param [String, Hash, Array] origin The address or latitude/longitude value from which you wish
    #         to calculate directions.
    # @param [String, Hash, Array] destination The address or latitude/longitude value from which
    #     you wish to calculate directions.
    # @param [String] mode Specifies the mode of transport to use when calculating
    #     directions. One of "driving", "walking", "bicycling" or "transit"
    # @param [Array<String>, Array<Hash>, Array<Array>] waypoints Specifies an array of waypoints. Waypoints alter a
    #     route by routing it through the specified location(s).
    # @param [Boolean] alternatives If True, more than one route may be returned in the
    #     response.
    # @param [Array, String] avoid Indicates that the calculated route(s) should avoid the
    #     indicated features.
    # @param [String] language The language in which to return results.
    # @param [String] units Specifies the unit system to use when displaying results.
    #     "metric" or "imperial"
    # @param [String] region The region code, specified as a ccTLD ("top-level domain"
    #     two-character value.
    # @param [Integer, DateTime] departure_time Specifies the desired time of departure.
    # @param [Integer, DateTime] arrival_time Specifies the desired time of arrival for transit
    #     directions. Note: you can't specify both departure_time and
    #     arrival_time.
    # @param [Boolean] optimize_waypoints Optimize the provided route by rearranging the
    #     waypoints in a more efficient order.
    # @param [String, Array<String>] transit_mode Specifies one or more preferred modes of transit.
    #     This parameter may only be specified for requests where the mode is
    #     transit. Valid values are "bus", "subway", "train", "tram", "rail".
    #     "rail" is equivalent to ["train", "tram", "subway"].
    # @param [String] transit_routing_preference Specifies preferences for transit
    #     requests. Valid values are "less_walking" or "fewer_transfers"
    #
    # @return List of routes
    def directions(origin, destination,
        mode=nil, waypoints=nil, alternatives=false, avoid=nil,
        language=nil, units=nil, region=nil, departure_time=nil,
        arrival_time=nil, optimize_waypoints=false, transit_mode=nil,
        transit_routing_preference=nil)

      params = {
        origin: _convert_waypoint(origin),
        destination: _convert_waypoint(destination)
      }

      if mode
        # NOTE(broady): the mode parameter is not validated by the Maps API
        # server. Check here to prevent silent failures.
        unless ["driving", "walking", "bicycling", "transit"].contains?(mode)
          raise ArgumentError, "Invalid travel mode."
        end
        params[:mode] = mode
      end

      if waypoints
        waypoints = GoogleMaps::Convert.as_list(waypoints)
        waypoints = waypoints.map { |waypoint| _convert_waypoint(waypoint) }
        waypoints = ["optimize:true"] + waypoints if optimize_waypoints

        params[:waypoints] = GoogleMaps::Convert.join_list("|", waypoints)
      end

      params[:alternatives] = "true" if alternatives
      params[:avoid] = GoogleMaps::Convert.join_list("|", avoid) if avoid
      params[:language] = language if language
      params[:units] = units if units
      params[:region] = region if region
      params[:departure_time] = GoogleMaps::Convert.time(departure_time) if departure_time
      params[:arrival_time] = GoogleMaps::Convert.time(arrival_time) if arrival_time

      if departure_time and arrival_time
        raise ArgumentError, "Should not specify both departure_time and arrival_time."
      end

      params[:transit_mode] = GoogleMaps::Convert.join_list("|", transit_mode) if transit_mode
      params[:transit_routing_preference] = transit_routing_preference if transit_routing_preference

      return get("/maps/api/directions/json", params)[:routes]
    end

    private
      def _convert_waypoint(waypoint)
        if waypoint.kind_of?(String)
          return waypoint
        end
        return GoogleMaps::Convert.latlng(waypoint)
      end
  end
end