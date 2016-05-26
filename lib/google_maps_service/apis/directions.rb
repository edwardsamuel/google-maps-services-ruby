require_relative './base'

module GoogleMapsService
  module Apis
    # Performs requests to the Google Maps Directions API.
    class Directions < Base
      # Base path of Directions API
      BASE_PATH = '/maps/api/directions/json'.freeze

      # Get directions between an origin point and a destination point.
      #
      # @example Simple directions
      #   routes = client.directions('Sydney', 'Melbourne')
      #
      # @example Complex bicycling directions
      #   routes = client.directions('Sydney', 'Melbourne',
      #       mode: 'bicycling',
      #       avoid: ['highways', 'tolls', 'ferries'],
      #       units: 'metric',
      #       region: 'au')
      #
      # @example Public transportation directions
      #    an_hour_from_now = Time.now - (1.0/24)
      #    routes = client.directions('Sydney Town Hall', 'Parramatta, NSW',
      #        mode: 'transit',
      #        arrival_time: an_hour_from_now)
      #
      # @example Walking with alternative routes
      #    routes = client.directions('Sydney Town Hall', 'Parramatta, NSW',
      #       mode: 'walking',
      #       alternatives: true)
      #
      # @param [String, Hash, Array] origin The address or latitude/longitude
      #     value from which you wish to calculate directions.
      # @param [String, Hash, Array] destination The address or
      #     latitude/longitude value from which you wish to calculate
      #     directions.
      # @option options [String] mode Specifies the mode of transport to use
      #     when calculating directions. One of `driving`, `walking`,
      #     `bicycling` or `transit`.
      # @option options [Array<String>, Array<Hash>, Array<Array>] waypoints
      #     Specifies an array of waypoints. Waypoints alter a route by routing
      #     it through the specified location(s).
      # @option options [Boolean] alternatives If True, more than one route
      #     may be returned in the response.
      # @option options [Array, String] avoid Indicates that the calculated
      #     route(s) should avoid the indicated features.
      # @option options [String] language The language in which to return
      #     results.
      # @option options [String] units Specifies the unit system to use when
      #     displaying results: `metric` or `imperial`.
      # @option options [String] region The region code, specified as a ccTLD
      #     (_top-level domain_) two-character value.
      # @option options [Integer, DateTime] departure_time Specifies the desired
      #     time of departure.
      # @option options [Integer, DateTime] arrival_time Specifies the desired
      #     time of arrival for transit directions.
      #     Note: you can not specify both `departure_time` and `arrival_time`.
      # @option options [Boolean] optimize_waypoints Optimize the provided route
      #     by rearranging the waypoints in a more efficient order.
      # @option options [String, Array<String>] transit_mode Specifies one or
      #     more preferred modes of transit.
      #     This parameter may only be specified for requests where the mode is
      #     transit. Valid values are `bus`, `subway`, `train`, `tram` or
      #     `rail`. The `rail` is equivalent to `["train", "tram", "subway"]`.
      # @option options [String] transit_routing_preference Specifies
      #     preferences for transit requests. Valid values are `less_walking` or
      #     `fewer_transfers`.
      # @option options [String] traffic_model Specifies the predictive travel
      #    time model to use.
      #    The valid values are `best_guess`, `optimistic` or `pessimistic`.
      #
      # @return [Array] Array of routes.
      def directions(origin, destination, options = {})
        params = options.clone
        params[:origin] = origin
        params[:destination] = destination

        if params[:waypoints]
          waypoints = GoogleMapsService::Convert.waypoints(params[:waypoints])
          if params[:optimize_waypoints]
            waypoints = ['optimize:true', waypoints]
            params.delete(:optimize_waypoints)
          end
          params[:waypoints] = waypoints
        end
        params[:alternatives] = 'true' if params[:alternatives]

        convert params, :departure_time, :arrival_time, with: :time
        convert params, :avoid, :waypoints, :transit_mode, with: :join_list

        validate params, :mode, with: :travel_mode

        if params[:arrival_time] && params[:departure_time]
          raise ArgumentError, 'Should not specify both departure_time '\
                               'and arrival_time.'
        end

        get(BASE_PATH, params)[:routes]
      end
    end
  end
end
