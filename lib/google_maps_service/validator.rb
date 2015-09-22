require_relative './convert'

module GoogleMapsService

  # Validate value that is accepted by Google Maps.
  module Validator
    module_function

    # Validate travel mode. The valid value of travel mode are `driving`, `walking`, `bicycling` or `transit`.
    #
    # @param [String, Symbol] mode Travel mode to be validated.
    #
    # @raise ArgumentError The travel mode is invalid.
    #
    # @return [String] Valid travel mode.
    def travel_mode(mode)
      # NOTE(broady): the mode parameter is not validated by the Maps API
      # server. Check here to prevent silent failures.
      unless [:driving, :walking, :bicycling, :transit].include?(mode.to_sym)
        raise ArgumentError, 'Invalid travel mode.'
      end
      mode
    end

    # Validate route restriction. The valid value of route restriction are `tolls`, `highways` or `ferries`.
    #
    # @param [String, Symbol] avoid Route restriction to be validated.
    #
    # @raise ArgumentError The route restriction is invalid.
    #
    # @return [String] Valid route restriction.
    def avoid(avoid)
      unless [:tolls, :highways, :ferries].include?(avoid.to_sym)
        raise ArgumentError, 'Invalid route restriction.'
      end
      avoid
    end
  end
end