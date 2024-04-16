import talib
import numpy as np

from finpy.indicator_types.signal_functions import two_cross_signal,one_over_other
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class BullsVsBears(EntryIndicator,ExitIndicator):
    """
    BullsVsBears Power indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - When bulls are over bears and crosses, its buy signal
        - When bulls are under bears and crosses, its sell signal

    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - inp_period: period to make calculations. Default is 13

    Output:
        - bulls line,bears line
    """
    def calculate(self,data, inp_period=13):
        n = data.CLOSE.shape[0]
        # Inicialización de los buffers
        ext_bulls_buffer = np.zeros(n)
        ext_bears_buffer = np.zeros(n)

        # Calcula la EMA del precio de cierre
        ema_close = talib.EMA(data.CLOSE, timeperiod=inp_period)

        # Calcula Bulls y Bears
        ext_bulls_buffer = data.HIGH - ema_close
        ext_bears_buffer = ema_close - data.LOW

        return ext_bulls_buffer, ext_bears_buffer
    
    def entry_signal(self, *args, **kwargs):
        ext_bulls_buffer, ext_bears_buffer = self._last_calculate_result
        if self.main_confirmation_indicator:
            return two_cross_signal(ext_bulls_buffer,ext_bears_buffer)
        return one_over_other(ext_bulls_buffer,ext_bears_buffer)
    
    def exit_signal(self, *args, **kwargs):
        ext_bulls_buffer, ext_bears_buffer = self._last_calculate_result
        return two_cross_signal(ext_bulls_buffer,ext_bears_buffer,bos_signal=False)