import numpy as np
import pandas as pd

from finpy.indicator_types.utils import mql4_atr
from finpy.indicator_types.signal_functions import two_cross_signal,one_over_other
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator,BaselineIndicator

class TradeWithTrend(EntryIndicator,ExitIndicator,BaselineIndicator):
    """
    Trade With Trend indicator

    Main use:
        - baseline indicator
        
    Secondary use:
        - entry indicator
        - exit indicator

    Typical use:
        - scenario 1:
            - when signal is 1 and previous signal was 0, its buy signal
            - when signal is -1 and previous signal was 0, its sell signal
       
        
    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - period: period to make calculations. Default is 4
        - multiplier: multiplier for band calculations. Default is 2.0
        
    Output:
        - buffer1, buffer2, signal
    """
    
    def calculate(self,data,period=4,multiplier=2.0):
        atr = mql4_atr(data,period)
        _data = pd.DataFrame()
        _data['close'] = data.CLOSE.copy()
        _data['atr'] = atr
        _data['ld_28'] = (data.HIGH+data.LOW)/2
        _data['lda_20'] = _data.ld_28 + multiplier*_data.atr
        _data['lda_24'] = _data.ld_28 - multiplier*_data.atr
        buffer1,buffer2 = self._iter_prices(_data,multiplier)
        signal = np.where(buffer1>buffer2,1,np.where(buffer1<buffer2,-1,0))
        return buffer1,buffer2,signal
    
    def _iter_prices(self,data,multiplier):
        bars = data.shape[0]
        buffer1 = np.zeros(bars)
        buffer2 = np.zeros(bars)
        atr = data.atr.to_numpy()
        close = data.close.to_numpy()
        ld_28 = data.ld_28.to_numpy()
        lda_20 = data.lda_20.to_numpy()
        lda_24 = data.lda_24.to_numpy()
        lia_16 = np.zeros(bars)
        lia_16[:] = 1
        gi_84 = None
        for index,row in data.iterrows():
            if row.atr!=row.atr or lda_20[index]!=lda_20[index]:
                continue
            if close[index] > lda_20[index-1]:
                lia_16[index] = 1
                if lia_16[index-1] == -1:
                    gi_84=True
            else:
                if close[index] < lda_24[index-1]:
                    lia_16[index] = -1
                    if lia_16[index-1] == 1:
                        gi_84 = True
                else:
                    if lia_16[index-1] == 1:
                        lia_16[index] = 1
                        gi_84=False
                    else:
                        if lia_16[index - 1] == -1:
                            lia_16[index] = -1
                            gi_84 = False
            
            li_8 = False
            li_12 = False
            if lia_16[index] < 0 and lia_16[index - 1] > 0:
                li_8 = True
            if lia_16[index] > 0 and lia_16[index - 1] < 0:
                li_12 = True
            
            if lia_16[index] > 0 and lda_24[index] < lda_24[index - 1]:
                lda_24[index] = lda_24[index - 1]
            if lia_16[index] < 0 and lda_20[index] > lda_20[index - 1]:
                lda_20[index] = lda_20[index - 1]
            if li_8:
                lda_20[index] = ld_28[index] + multiplier*atr[index]
            if li_12:
                lda_24[index] = ld_28[index] - multiplier*atr[index]
            
            if lia_16[index]==1:
                buffer1[index] = lda_24[index]
                if gi_84:
                    buffer1[index - 1] = buffer2[index - 1]
                    gi_84 = False
            else:
                if lia_16[index] == -1:
                    buffer2[index] = lda_20[index]
                    if gi_84:
                        buffer2[index - 1] = buffer1[index - 1]
                        gi_84=False
        return buffer1,buffer2
    
    def entry_signal(self, *args, **kwargs):
        buffer1,buffer2,signal = self._last_calculate_result
        if self.main_confirmation_indicator:
            return two_cross_signal(buffer1,buffer2)
        return one_over_other(buffer1,buffer2)
        
    
    def exit_signal(self, *args, **kwargs):
        buffer1,buffer2,signal = self._last_calculate_result
        return two_cross_signal(buffer1,buffer2,bos_signal=False)
    
    def baseline_signal(self, *args, **kwargs):
        buffer1,buffer2,signal = self._last_calculate_result
        values = np.where(buffer1>buffer2,buffer1,buffer2)
        price = self._last_calculate_kwargs['data']
        return two_cross_signal(price.CLOSE,values)
        