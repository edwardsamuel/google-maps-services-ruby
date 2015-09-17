require 'spec_helper'

describe GoogleMapsService::TimeZone do
  include_context 'HTTP client'

  before(:example) do
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/timezone\/.*/)
      .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OK","results":[]}')
  end

  context 'los angeles' do
    it 'should call Google Maps Web Service' do
      ts = 1331766000
      timezone = client.timezone(location: [39.603481, -119.682251], timestamp: ts)
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/timezone/json?location=39.603481,-119.682251&timestamp=%d&key=%s' % [ts.to_i, api_key])).to have_been_made
    end
  end

  context 'los angeles with no timestamp' do
    before (:example) do
      allow(Time).to receive_messages(:now => Time.at(1608))
    end

    it 'should call Google Maps Web Service' do
      timezone = client.timezone(location: [39.603481, -119.682251])
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/timezone/json?location=39.603481,-119.682251&timestamp=%d&key=%s' % [1608, api_key])).to have_been_made
    end
  end
end