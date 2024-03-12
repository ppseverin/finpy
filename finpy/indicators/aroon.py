# Ejemplo: finpy/indicators/aroon.py
import talib

from finpy.indicator_types.utils import ensure_prices_instance_method
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class Aroon(EntryIndicator,ExitIndicator):
    """
    Aroon indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - When aroon up is over aroon down and crosses, its buy signal
        - When aroon up is under aroon down and crosses, its sell signal

    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - period: period to make calculations. Default is 14

    Output:
        - aroon down, aroon up
    """
    # Implementación del indicador Aroon
    @ensure_prices_instance_method
    def calculate(self,data,period=14):
        high = data.HIGH.to_numpy()
        low = data.LOW.to_numpy()
        aroondown, aroonup = talib.AROON(high, low, timeperiod=period)
        return aroondown, aroonup
