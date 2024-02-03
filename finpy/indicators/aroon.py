# Ejemplo: finpy/indicators/aroon.py
import talib

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
        - aroon

    Input:
        - OHLC data: market data with open, high, low and close information
        - period: period to make calculations. Default is 14

    Output:
        - aroon down, aroon up

    """
    # Implementación del indicador Aroon
    def aroon(self,data,period=14):
        high = data.high
        low = data.low
        aroondown, aroonup = talib.AROON(high, low, timeperiod=period)
        return aroondown, aroonup
