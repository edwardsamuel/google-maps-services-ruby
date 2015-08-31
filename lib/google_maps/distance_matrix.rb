module GoogleMaps

  # Performs requests to the Google Maps Distance Matrix API.
  module DistanceMatrix

    # Gets travel distance and time for a matrix of origins and destinations.
    #
    # @param [Array<String>, Array<Hash>, Array<Array>] origins One or more addresses and/or latitude/longitude values,
    #         from which to calculate distance and time. If you pass an address
    #         as a string, the service will geocode the string and convert it to
    #         a latitude/longitude coordinate to calculate directions.
    # @param [Array<String>, Array<Hash>, Array<Array>] destinations One or more addresses and/or lat/lng values, to
    #         which to calculate distance and time. If you pass an address as a
    #         string, the service will geocode the string and convert it to a
    #         latitude/longitude coordinate to calculate directions.
    # @param [String] mode Specifies the mode of transport to use when calculating
    #         directions. Valid values are "driving", "walking", "transit" or
    #         "bicycling".
    # @param [String] language The language in which to return results.
    # @param [String] avoid Indicates that the calculated route(s) should avoid the
    #     indicated features. Valid values are "tolls", "highways" or "ferries"
    # @param [String] units Specifies the unit system to use when displaying results.
    #     Valid values are "metric" or "imperial"
    # @param [Integer, DateTime] departure_time Specifies the desired time of departure.
    # @param [Integer, DateTime] arrival_time Specifies the desired time of arrival for transit
    #     directions. Note: you can't specify both departure_time and
    #     arrival_time.
    # @param [String, Array<String>] transit_mode Specifies one or more preferred modes of transit.
    #     This parameter may only be specified for requests where the mode is
    #     transit. Valid values are "bus", "subway", "train", "tram", "rail".
    #     "rail" is equivalent to ["train", "tram", "subway"].
    # @param [String] transit_routing_preference Specifies preferences for transit
    #     requests. Valid values are "less_walking" or "fewer_transfers"
    #
    # @return matrix of distances. Results are returned in rows, each row
    #     containing one origin paired with each destination.
    def distance_matrix(origins, destinations,
                        mode=nil, language=nil, avoid=nil, units=nil,
                        departure_time=nil, arrival_time=nil, transit_mode=nil,
                        transit_routing_preference=nil)
      params = {
        "origins": _convert_path(origins),
        "destinations": _convert_path(destinations)
      }

      if mode
        # NOTE(broady): the mode parameter is not validated by the Maps API
        # server. Check here to prevent silent failures.
        unless ["driving", "walking", "bicycling", "transit"].contains?(mode)
          raise ArgumentError, "Invalid travel mode."
        end
        params["mode"] = mode
      end

      params["language"] = language if language

      if avoid
        unless ["tolls", "highways", "ferries"].contains?(avoid)
          raise ArgumentError, "Invalid route restriction."
        end
        params["avoid"] = avoid
      end


      params["units"] = units if units
      params["departure_time"] = convert.time(departure_time) if departure_time
      params["arrival_time"] = convert.time(arrival_time) if arrival_time

      if departure_time and arrival_time
        raise ArgumentError, "Should not specify both departure_time and arrival_time."
      end

      params["transit_mode"] = convert.join_list("|", transit_mode) if transit_mode
      params["transit_routing_preference"] = transit_routing_preference if transit_routing_preference

      return get("/maps/api/distancematrix/json", params)
    end

    private
      def _convert_path(waypoints)
        waypoints = GoogleMaps::Convert.as_list(waypoints)
        return GoogleMaps::Convert.join_list("|", waypoints.map { |k| k.kind_of?(String) ? k : GoogleMaps::Convert.latlng(k) })
      end
  end
end