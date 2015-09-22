require 'spec_helper'
require 'date'

describe GoogleMapsService::Polyline do
  context '.decode' do
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
        GoogleMapsService::Polyline.decode(syd_mel_route)
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

  context '.encode' do
    context 'with decoded polyline' do
      it 'should be same as original polyline' do
        test_polyline = ("gcneIpgxzRcDnBoBlEHzKjBbHlG`@`IkDxIi" \
                         "KhKoMaLwTwHeIqHuAyGXeB~Ew@fFjAtIzExF")
        points = GoogleMapsService::Polyline.decode(test_polyline)
        actual_polyline = GoogleMapsService::Polyline.encode(points)
        expect(actual_polyline).to eq (test_polyline)
      end
    end
  end
end