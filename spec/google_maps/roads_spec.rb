require 'spec_helper'

describe GoogleMapsService::Roads do
  include_context 'HTTP client'

  context '#snap_to_roads' do
    before(:example) do
      stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/snapToRoads/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"snappedPoints":["foo"]}')
    end

    context 'snap' do
      it 'should call Google Maps Web Service' do
        results = client.snap_to_roads(path: [40.714728, -73.998672])
        expect(a_request(:get, 'https://roads.googleapis.com/v1/snapToRoads?path=40.714728%%2C-73.998672&key=%s' % api_key)).to have_been_made
      end
    end
  end

  context '#snapped_speed_limits' do
    before(:example) do
      stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"speedLimits":["foo"]}')
    end

    context 'path' do
      it 'should call Google Maps Web Service' do
        results = client.snapped_speed_limits(path: [[1, 2],[3, 4]])
        expect(a_request(:get, "https://roads.googleapis.com/v1/speedLimits?path=1.000000%%2C2.000000|3.000000%%2C4.000000&key=%s" % api_key)).to have_been_made
      end
    end
  end

  context '#speed_limits' do
    before(:example) do
      stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"speedLimits":["foo"]}')
    end

    context 'speedlimits' do
      it 'should call Google Maps Web Service' do
        results = client.speed_limits(place_ids: "id1")
        expect(a_request(:get, "https://roads.googleapis.com/v1/speedLimits?placeId=id1&key=%s" % api_key)).to have_been_made
      end
    end

    context 'speedlimits multiple' do
      it 'should call Google Maps Web Service' do
        results = client.speed_limits(place_ids: ["id1", "id2", "id3"])
        expect(a_request(:get, 'https://roads.googleapis.com/v1/speedLimits?placeId=id1&placeId=id2&placeId=id3&key=%s' % api_key)).to have_been_made
      end
    end
  end

  context 'with client_id and client_secret' do
    let(:client) do
      GoogleMapsService::Client.new(client_id: 'asdf', client_secret: 'asdf')
    end

    it 'should raise ArgumentError' do
      expect { client.speed_limits("foo") }.to raise_error ArgumentError
    end
  end

  # context 'retry' do
  #   it 'should call Google Maps Web Service' do
  #     class request_callback:
  #         def __init__(self):
  #             self.first_req = True
  #         def __call__(self, req):
  #             if self.first_req:
  #                 self.first_req = False
  #                 return (500, {}, 'Internal Server Error.')
  #             return (200, {}, '{"speedLimits":[]}')
  #
  #     responses.add_callback(responses.GET,
  #             "https://roads.googleapis.com/v1/speedLimits",
  #             content_type="application/json",
  #             callback=request_callback())
  #
  #     client.speed_limits([])
  #
  #     self.assertEqual(2, len(responses.calls))
  #     self.assertEqual(responses.calls[0].request.url, responses.calls[1].request.url)
  #   end
  # end
end