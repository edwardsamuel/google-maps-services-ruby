require 'minitest_helper'
require 'date'

class ConvertTest < Minitest::Test

  def test_latlng
    assert_equal("1.000000,2.000000", GoogleMapsServices::Convert.latlng({"lat": 1, "lng": 2}))
    assert_equal("1.000000,2.000000", GoogleMapsServices::Convert.latlng([1, 2]))

    assert_raises(ArgumentError) { GoogleMapsServices::Convert.latlng(1) }
    assert_raises(ArgumentError) { GoogleMapsServices::Convert.latlng("test") }
  end

  def test_join_list
    assert_equal("asdf", GoogleMapsServices::Convert.join_list("|", "asdf"))
    assert_equal("1,2,A", GoogleMapsServices::Convert.join_list(",", ["1", "2", "A"]))
    assert_equal("", GoogleMapsServices::Convert.join_list(",", []))
  end

  def test_as_list
    assert_equal([1], GoogleMapsServices::Convert.as_list(1))
    assert_equal([1, 2, 3], GoogleMapsServices::Convert.as_list([1, 2, 3]))
    assert_equal(["string"], GoogleMapsServices::Convert.as_list("string"))

    a_dict = {"a": 1}
    assert_equal([a_dict], GoogleMapsServices::Convert.as_list(a_dict))
  end

  def test_time
    assert_equal("1409810596", GoogleMapsServices::Convert.time(1409810596))

    t = Time.at(1409810596)
    assert_equal("1409810596", GoogleMapsServices::Convert.time(t))

    dt = Time.at(1409810596).to_datetime
    assert_equal("1409810596", GoogleMapsServices::Convert.time(dt))
  end

  def test_components
    c = {"country": "US"}
    assert_equal("country:US", GoogleMapsServices::Convert.components(c))

    c = {"country": "US", "foo": 1}
    assert_equal("country:US|foo:1", GoogleMapsServices::Convert.components(c))

    assert_raises(ArgumentError) { GoogleMapsServices::Convert.components("test") }
    assert_raises(ArgumentError) { GoogleMapsServices::Convert.components(1) }
  end

  def test_bounds
    ne = {"lat": 1, "lng": 2}
    sw = [3, 4]
    b = {"northeast": ne, "southwest": sw}
    assert_equal("3.000000,4.000000|1.000000,2.000000", GoogleMapsServices::Convert.bounds(b))

    assert_raises(ArgumentError) { GoogleMapsServices::Convert.bounds("test") }
  end

  def test_polyline_decode
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
    points = GoogleMapsServices::Convert.decode_polyline(syd_mel_route)
    assert_in_delta(-33.86746, points[0]["lat"])
    assert_in_delta(151.207090, points[0]["lng"])
    assert_in_delta(-37.814130, points[-1]["lat"])
    assert_in_delta(144.963180, points[-1]["lng"])
  end

  def test_polyline_round_trip
    test_polyline = ("gcneIpgxzRcDnBoBlEHzKjBbHlG`@`IkDxIi" \
                     "KhKoMaLwTwHeIqHuAyGXeB~Ew@fFjAtIzExF")
    points = GoogleMapsServices::Convert.decode_polyline(test_polyline)
    actual_polyline = GoogleMapsServices::Convert.encode_polyline(points)
    assert_equal(test_polyline, actual_polyline)
  end
end
