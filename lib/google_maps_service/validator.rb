require_relative './convert'

module GoogleMapsService
  module Validator
    module_function

    def travel_mode(mode)
      # NOTE(broady): the mode parameter is not validated by the Maps API
      # server. Check here to prevent silent failures.
      unless [:driving, :walking, :bicycling, :transit].include?(mode.to_sym)
        raise ArgumentError, 'Invalid travel mode.'
      end
      mode
    end

    def avoid(avoid)
      unless [:tolls, :highways, :ferries].include?(avoid.to_sym)
        raise ArgumentError, 'Invalid route restriction.'
      end
      avoid
    end
  end
end