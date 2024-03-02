import numpy as np

from finpy.indicator_types.categories import EntryIndicator,ExitIndicator
from finpy.indicator_types.utils import _get_price_translator

class JurikVoltyBands(EntryIndicator,ExitIndicator):
    """
    Jurik Volty Bands indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - When prices buffer over 0 crosses, its buy signal
        - When prices buffer under 0 and crosses, its sell signal

    Calculation method:
        - calculate_jurik_volty_bands

    Input:
        - OHLC data: market data with open, high, low and close information
        - length: length to make calculations. Default is 14
        - price: price to apply calculations
        - shift: shift to apply to prices
        - normalize: True to normalize prices. Default is False
        - zero_bind: True to bind indicator around 0. Default is True

    Output:
        - upValues, dnValues, miValue, prices

    """
    def calculate_jurik_volty_bands(self, data, length=14, price=0, shift=0, normalize=False,zero_bind=True):
        applied_price = _get_price_translator(price)
        cprice = data[applied_price]
        vprice = cprice.shift(shift)
        upValues,dnValues,miValue = self._iVolty(vprice, length)
        if zero_bind:
            if normalize:
                diff = (upValues-miValue).copy()
                prices = np.where(diff!=0,(cprice - miValue)/diff,0)
                upValues[:] = 1
                dnValues[:] = -1
            else:
                upValues = upValues-miValue
                dnValues = dnValues-miValue
                prices = (cprice-miValue).to_numpy()
            miValue[:] = 0
        else:
            prices = cprice
        return upValues,dnValues,miValue,prices
    
    def _iVolty(self, tprice, length):
        __avg_len = 65
        n = len(tprice)
        len1 = np.max(np.log(np.sqrt(0.5*(length-1)))/np.log(2.0)+2.0,0)
        pow1 = np.max([len1-2.0,0.5])
        
        np_tprice = tprice.to_numpy()
        wrk_vprice = np.zeros(n)
        wrk_bsmax = np.zeros(n)
        wrk_bsmin = np.zeros(n)
        wrk_volty = np.zeros(n)
        wrk_vsum = np.zeros(n)
        wrk_avolty = np.zeros(n)
        _hprice,_lprice = np.zeros(n),np.zeros(n)
        _del1,_del2 = np.zeros(n),np.zeros(n)
        _kv = np.zeros(n)
        for i in range(1, n):
            wrk_vprice[i] = np_tprice[i]
            hprice = np_tprice[i]
            lprice = np_tprice[i]
            for r in range(1,length):
                if i-r<0:
                    break
                hprice = max(wrk_vprice[i-r],hprice)
                lprice = min(wrk_vprice[i-r],lprice)
            
            # Calcular deltas
            del1 = hprice - wrk_bsmax[i-1]
            del2 = lprice - wrk_bsmin[i-1]
            
            _hprice[i]=hprice
            _lprice[i]=lprice
            _del1[i]=del1*10000
            _del2[i]=del2*10000

            wrk_volty[i]=0
            if (abs(del1)>abs(del2)) or (abs(del1)<abs(del2)):
                wrk_volty[i] = max(abs(del1), abs(del2))
            
            # Acumulación y promedio de volatilidad
            wrk_vsum[i] = wrk_vsum[i-1] + 0.1*(wrk_volty[i] - wrk_volty[i-10])

            #suma de promedios
            avg = wrk_vsum[i]
            for r in range(1,__avg_len):
                if i-r<0:
                    break
                avg += wrk_vsum[i-r]
            avg /= (r+1)
            wrk_avolty[i] = avg

            dVolty = 0
            if wrk_avolty[i]>0:
                dVolty = wrk_volty[i]/wrk_avolty[i]
            
            dVolty = np.clip(dVolty, 1, np.power(len1, 1.0 / pow1))

            pow2 = np.power(dVolty,pow1)
            len2 = np.sqrt(0.5*(length-1))*len1
            Kv = np.power(len2/(len2+1),np.sqrt(pow2))
            _kv[i]=Kv
            
            if del1>0:
                wrk_bsmax[i] = hprice
            else:
                wrk_bsmax[i] = hprice - Kv*del1

            if del2<0:
                wrk_bsmin[i] = lprice
            else:
                wrk_bsmin[i] = lprice - Kv*del2
        
        miValue = (wrk_bsmin+wrk_bsmax)/2.0
        return wrk_bsmax,wrk_bsmin,miValue