require_relative './base'

module GoogleMapsService
  module Apis
    # Performs requests to the Google Maps Distance Matrix API.
    class DistanceMatrix < Base
      # Base path of Distance Matrix API
      BASE_PATH = '/maps/api/distancematrix/json'.freeze

      # Gets travel distance and time for a matrix of origins and destinations.
      #
      # @example Simple distance matrix
      #   origins = ["Perth, Australia", "Sydney, Australia",
      #              "Melbourne, Australia", "Adelaide, Australia",
      #              "Brisbane, Australia", "Darwin, Australia",
      #              "Hobart, Australia", "Canberra, Australia"]
      #   destinations = ["Uluru, Australia",
      #                   "Kakadu, Australia",
      #                   "Blue Mountains, Australia",
      #                   "Bungle Bungles, Australia",
      #                   "The Pinnacles, Australia"]
      #   matrix = client.distance_matrix(origins, destinations)
      #
      # @example Complex distance matrix
      #   origins = [
      #               "Bobcaygeon ON",
      #               [41.43206, -81.38992]
      #             ]
      #   destinations = [
      #                    [43.012486, -83.6964149],
      #                    {lat: 42.8863855, lng: -78.8781627}
      #                  ]
      #   matrix = client.distance_matrix(origins, destinations,
      #       mode: 'driving',
      #       language: 'en-AU',
      #       avoid: 'tolls',
      #       units: 'imperial')
      #
      # @param [Array] origins One or more addresses and/or lat/lon pairs,
      #         from which to calculate distance and time.
      #         If you pass an address as a string, the service will geocode
      #         the string and convert it to a lat/lon coordinate to calculate
      #         directions.
      # @param [Array] destinations One or more addresses and/or lat/lon pairs,
      #         to which to calculate distance and time.
      #         If you pass an address as a string, the service will geocode
      #         the string and convert it to a lat/lon coordinate to calculate
      #         directions.
      # @option options [String] mode Specifies the mode of transport to use
      #         when calculating directions.
      #         Valid values are `driving`, `walking`, `transit` or `bicycling`.
      # @option options [String] language The language in which to return
      #         results.
      # @option options [String] avoid Indicates that the calculated route(s)
      #         should avoid the indicated features.
      #         Valid values are `tolls`, `highways` or `ferries`.
      # @option options [String] units Specifies the unit system to use when
      #         displaying results.
      #         Valid values are `metric` or `imperial`.
      # @option options [Integer, DateTime] departure_time Specifies the desired
      #         time of departure.
      # @option options [Integer, DateTime] arrival_time Specifies the desired
      #         time of arrival for transit directions.
      #         Note: you can not specify both `departure_time` and
      #         `arrival_time`.
      # @option options [String, Array<String>] transit_mode Specifies one or
      #         more preferred modes of transit. This parameter may only be
      #         specified for requests where the mode is transit.
      #         Valid values are `bus`, `subway`, `train`, `tram`, or `rail`.
      #         `rail` is equivalent to `["train", "tram", "subway"]`.
      # @option options [String] transit_routing_preference Specifies
      #         preferences for transit requests.
      #         Valid values are `less_walking` or `fewer_transfers`.
      #
      # @return [Hash] Matrix of distances. Results are returned in rows,
      #         each row containing one origin paired with each destination.
      def distance_matrix(origins, destinations, options = {})
        params = options.clone
        params[:origins] = origins
        params[:destinations] = destinations

        convert params, :origins, :destinations, with: :waypoints
        convert params, :departure_time, :arrival_time, with: :time
        convert params, :transit_mode, with: :join_list
        validate params, :mode, with: :travel_mode
        validate params, :avoid, with: :avoid

        if params[:departure_time] && params[:arrival_time]
          raise ArgumentError, 'Should not specify both departure_time ' \
                               'and arrival_time.'
        end

        get(BASE_PATH, params)
      end
    end
  end
end
