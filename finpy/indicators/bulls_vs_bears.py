import talib
import numpy as np

from finpy.indicator_types.utils import ensure_prices_instance_method
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
        - bulls_vs_bears

    Input:
        - OHLC data: market data with open, high, low and close information
        - inp_period: period to make calculations. Default is 13

    Output:
        - bulls line,bears line
    """
    @ensure_prices_instance_method
    def bulls_vs_bears(self,data, inp_period=13):
        # Inicialización de los buffers
        ext_bulls_buffer = np.zeros(len(data))
        ext_bears_buffer = np.zeros(len(data))

        # Calcula la EMA del precio de cierre
        ema_close = talib.EMA(data.CLOSE, timeperiod=inp_period)

        # Calcula Bulls y Bears
        ext_bulls_buffer = data.HIGH - ema_close
        ext_bears_buffer = ema_close - data.LOW

        return ext_bulls_buffer, ext_bears_buffer