import talib
import numpy as np

from finpy.indicator_types.signal_functions import one_over_other, two_cross_signal
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator
from finpy.indicator_types.utils import calculate_smma

class BraidFilter(EntryIndicator,ExitIndicator):
    """
    BraidFilter indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - When cross up is over cross down and crosses, its buy signal
        - When cross up is under cross down and crosses, its sell signal

    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - period1: period to make calculations for moving average 1. Default is 5
        - period2: period to make calculations for moving average 2. Default is 8
        - period3: period to make calculations for moving average 3. Default is 20
        - ma_type: type of moving average. Default is 1
                 Admitted values are:
                 - SMA: 0
                 - EMA: 1
                 - SMMA: 2
        - pips_min_sep_percent: min pips percentage separation. Default is 50
        - atr_period: atr period to make calculations. Default is 14

    Output:
        - cross up, cross down, filter atr
    """
    
    def calculate(self,data,period1=5,period2=8,period3=20,ma_type=1,pips_min_sep_percent=50,atr_period=14):
        if ma_type not in [0,1,2]:
            raise ValueError('ma_type value not admitted. Admitted values are 0, 1 or 2')
        data_shape = data.CLOSE.shape[0]
        # Inicialización de los buffers
        cross_up = np.zeros(data_shape)
        cross_down = np.zeros(data_shape)
        filter_atr = talib.ATR(data.HIGH, data.LOW, data.CLOSE, timeperiod=atr_period) * pips_min_sep_percent / 100.0
        
        if ma_type==2:
            ema5 = calculate_smma(data.CLOSE,period1)
            ema8 = calculate_smma(data.OPEN,period2)
            ema20 = calculate_smma(data.CLOSE,period3)
        else:
            ema5 = talib.MA(data.CLOSE, period1, ma_type)
            ema8 = talib.MA(data.OPEN, period2, ma_type)
            ema20 = talib.MA(data.CLOSE, period3, ma_type)

        for i in range(data_shape):
            # Lógica para determinar CrossUp y CrossDown
            if ema5[i] > ema8[i]:
                cross_up[i] = self._get_dif(ema5[i], ema8[i], ema20[i])
            elif ema5[i] < ema8[i]:
                cross_down[i] = self._get_dif(ema5[i], ema8[i], ema20[i])

        return cross_up, cross_down, filter_atr
    
    def _get_dif(self,ma5, ma8, ma20):
        max_val = max(ma5, ma8, ma20)
        min_val = min(ma5, ma8, ma20)
        return max_val - min_val
    
    def entry_signal(self, *args, **kwargs):
        cross_up, cross_down, filter_atr = self._last_calculate_result
        if self.main_confirmation_indicator:
            return two_cross_signal(cross_up,cross_down)
        return one_over_other(cross_up,cross_down)
    
    def exit_signal(self, *args, **kwargs):
        cross_up, cross_down, filter_atr = self._last_calculate_result
        return two_cross_signal(cross_up,cross_down,bos_signal=False)