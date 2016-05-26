require_relative '../validator'
require_relative '../../core_extensions/extract_options'

module GoogleMapsService
  module Apis
    class Base
      def initialize(client)
        @client = client
      end

      protected

      def get(path, params, options = {})
        @client.get(path, params, options)
      end

      def convert(params, *args)
        options = args.extract_options!
        assigner(GoogleMapsService::Convert, params, args, options)
      end

      def validate(params, *args)
        options = args.extract_options!
        assigner(GoogleMapsService::Validator, params, args, options)
      end

      def assigner(modifier, params, keys, options)
        keys.each do |key|
          if params[key]
            params[key] = modifier.send(options[:with], params[key])
          end
        end
      end
    end
  end
end
