require 'spec_helper'
require 'date'

describe GoogleMapsService::Convert do
  describe '.latlng' do
    context 'with a lat/lng pair' do
      it 'should return comma-separated string' do
        expect(GoogleMapsService::Convert.latlng({lat: 1, lng: 2})).to eq("1.000000,2.000000")
        expect(GoogleMapsService::Convert.latlng({latitude: 1, longitude: 2})).to eq("1.000000,2.000000")
        expect(GoogleMapsService::Convert.latlng({"lat" => 1, "lng" => 2})).to eq("1.000000,2.000000")
        expect(GoogleMapsService::Convert.latlng({"latitude" => 1, "longitude" => 2})).to eq("1.000000,2.000000")
        expect(GoogleMapsService::Convert.latlng([1, 2])).to eq("1.000000,2.000000")
      end
    end

    context 'without a lat/lng pair' do
      it 'should raise ArgumentError' do
        expect { GoogleMapsService::Convert.latlng(1) }.to raise_error ArgumentError
        expect { GoogleMapsService::Convert.latlng("test") }.to raise_error ArgumentError
      end
    end
  end

  context '.join_list' do
    context 'with a single value array' do
      it 'should return its value' do
        expect(GoogleMapsService::Convert.join_list("|", "asdf")).to eq("asdf")
      end
    end

    context 'with a multiple values array' do
      it 'should return separated value string' do
        expect(GoogleMapsService::Convert.join_list(",", ["1", "2", "A"])).to eq("1,2,A")
      end
    end

    context 'with an empty array' do
      it 'should return empty string' do
        expect(GoogleMapsService::Convert.join_list(",", [])).to eq("")
      end
    end
  end

  context '.as_list' do
    context 'with a single value' do
      it 'should return an array contains the value' do
        expect(GoogleMapsService::Convert.as_list(1)).to eq([1])
        expect(GoogleMapsService::Convert.as_list("string")).to eq(["string"])

        a_hash = {"a": 1}
        expect(GoogleMapsService::Convert.as_list(a_hash)).to eq([a_hash])
      end
    end

    context 'with an array' do
      it 'should return the same array' do
        expect(GoogleMapsService::Convert.as_list([1, 2, 3])).to eq([1, 2, 3])
      end
    end
  end


  context '.time' do
    context 'with an integer' do
      it 'should return the integer as string' do
        expect(GoogleMapsService::Convert.time(1409810596)).to eq("1409810596")
      end
    end

    context 'with a Time' do
      it 'should return the epoch time as string' do
        t = Time.at(1409810596)
        expect(GoogleMapsService::Convert.time(t)).to eq("1409810596")
      end
    end

    context 'with a DateTime' do
      it 'should return the epoch time as string' do
        dt = Time.at(1409810596).to_datetime
        expect(GoogleMapsService::Convert.time(dt)).to eq("1409810596")
      end
    end
  end


  context '.components' do
    context 'with single hash entry' do
      it 'should return key:value pair string' do
        c = {"country": "US"}
        expect(GoogleMapsService::Convert.components(c)).to eq("country:US")
      end
    end

    context 'with multiple hash entries' do
      it 'should return key:value pairs separated by "|"' do
        c = {"country": "US", "foo": 1}
        expect(GoogleMapsService::Convert.components(c)).to eq("country:US|foo:1")
      end
    end

    context 'with non-hash' do
      it 'should raise ArgumentError' do
        expect { GoogleMapsService::Convert.components("test") }.to raise_error ArgumentError
        expect { GoogleMapsService::Convert.components(1) }.to raise_error ArgumentError
      end
    end
  end


  context '.bounds' do
    context 'with northeast and southwest hash' do
      it 'should return string representation of bounds' do
        ne = {"lat": 1, "lng": 2}
        sw = [3, 4]
        b = {northeast: ne, southwest: sw}
        expect(GoogleMapsService::Convert.bounds(b)).to eq("3.000000,4.000000|1.000000,2.000000")
        b = {"northeast" => ne, "southwest" => sw}
        expect(GoogleMapsService::Convert.bounds(b)).to eq("3.000000,4.000000|1.000000,2.000000")
      end
    end

    context 'with string' do
      it 'should raise ArgumentError' do
        expect { GoogleMapsService::Convert.bounds("test") }.to raise_error ArgumentError
      end
    end
  end

  context '.decode_polyline' do
    context 'with Sydney to Melbourne polyline' do
      let (:decoded_points) do
        syd_mel_route = ("rvumEis{y[`NsfA~tAbF`bEj^h{@{KlfA~eA~`AbmEghAt~D|e@j" \
                         "lRpO~yH_\\v}LjbBh~FdvCxu@`nCplDbcBf_B|wBhIfhCnqEb~D~" \
                         "jCn_EngApdEtoBbfClf@t_CzcCpoEr_Gz_DxmAphDjjBxqCviEf}" \
                         "B|pEvsEzbE~qGfpExjBlqCx}BvmLb`FbrQdpEvkAbjDllD|uDldD" \
                         "j`Ef|AzcEx_Gtm@vuI~xArwD`dArlFnhEzmHjtC~eDluAfkC|eAd" \
                         "hGpJh}N_mArrDlr@h|HzjDbsAvy@~~EdTxpJje@jlEltBboDjJdv" \
                         "KyZpzExrAxpHfg@pmJg[tgJuqBnlIarAh}DbN`hCeOf_IbxA~uFt" \
                         "|A|xEt_ArmBcN|sB|h@b_DjOzbJ{RlxCcfAp~AahAbqG~Gr}AerA" \
                         "`dCwlCbaFo]twKt{@bsG|}A~fDlvBvz@tw@rpD_r@rqB{PvbHek@" \
                         "vsHlh@ptNtm@fkD[~xFeEbyKnjDdyDbbBtuA|~Br|Gx_AfxCt}Cj" \
                         "nHv`Ew\\lnBdrBfqBraD|{BldBxpG|]jqC`mArcBv]rdAxgBzdEb" \
                         "{InaBzyC}AzaEaIvrCzcAzsCtfD~qGoPfeEh]h`BxiB`e@`kBxfA" \
                         "v^pyA`}BhkCdoCtrC~bCxhCbgEplKrk@tiAteBwAxbCwuAnnCc]b" \
                         "{FjrDdjGhhGzfCrlDruBzSrnGhvDhcFzw@n{@zxAf}Fd{IzaDnbD" \
                         "joAjqJjfDlbIlzAraBxrB}K~`GpuD~`BjmDhkBp{@r_AxCrnAjrC" \
                         "x`AzrBj{B|r@~qBbdAjtDnvCtNzpHxeApyC|GlfM`fHtMvqLjuEt" \
                         "lDvoFbnCt|@xmAvqBkGreFm~@hlHw|AltC}NtkGvhBfaJ|~@riAx" \
                         "uC~gErwCttCzjAdmGuF`iFv`AxsJftD|nDr_QtbMz_DheAf~Buy@" \
                         "rlC`i@d_CljC`gBr|H|nAf_Fh{G|mE~kAhgKviEpaQnu@zwAlrA`" \
                         "G~gFnvItz@j{Cng@j{D{]`tEftCdcIsPz{DddE~}PlnE|dJnzG`e" \
                         "G`mF|aJdqDvoAwWjzHv`H`wOtjGzeXhhBlxErfCf{BtsCjpEjtD|" \
                         "}Aja@xnAbdDt|ErMrdFh{CzgAnlCnr@`wEM~mE`bA`uD|MlwKxmB" \
                         "vuFlhB|sN`_@fvBp`CxhCt_@loDsS|eDlmChgFlqCbjCxk@vbGxm" \
                         "CjbMba@rpBaoClcCk_DhgEzYdzBl\\vsA_JfGztAbShkGtEhlDzh" \
                         "C~w@hnB{e@yF}`D`_Ayx@~vGqn@l}CafC")
        GoogleMapsService::Convert.decode_polyline(syd_mel_route)
      end

      it 'should start in Sydney' do
        expect(decoded_points[0][:lat]).to be_within(0.000001).of(-33.86746)
        expect(decoded_points[0][:lng]).to be_within(0.000001).of(151.207090)
      end

      it 'should end in Melbourne' do
        expect(decoded_points[-1][:lat]).to be_within(0.000001).of(-37.814130)
        expect(decoded_points[-1][:lng]).to be_within(0.000001).of(144.963180)
      end
    end
  end

  context '.encode_polyline' do
    context 'with decoded polyline' do
      it 'should be same as original polyline' do
        test_polyline = ("gcneIpgxzRcDnBoBlEHzKjBbHlG`@`IkDxIi" \
                         "KhKoMaLwTwHeIqHuAyGXeB~Ew@fFjAtIzExF")
        points = GoogleMapsService::Convert.decode_polyline(test_polyline)
        actual_polyline = GoogleMapsService::Convert.encode_polyline(points)
        expect(actual_polyline).to eq (test_polyline)
      end
    end
  end
end