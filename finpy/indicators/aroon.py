# Ejemplo: finpy/indicators/aroon.py
import talib

from finpy.indicator_types.signal_functions import two_cross_signal,one_over_other
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
    def calculate(self,data,period=14):
        high = data.HIGH.to_numpy()
        low = data.LOW.to_numpy()
        aroondown, aroonup = talib.AROON(high, low, timeperiod=period)
        return aroondown, aroonup
    
    def entry_signal(self,*args,**kwargs):
        """
        Returns 1 for buy and -1 for sell signals
        """
        aroon_down,aroon_up = self._last_calculate_result
        if self.main_confirmation_indicator:
            return two_cross_signal(aroon_up,aroon_down)
        return one_over_other(aroon_up,aroon_down)        
        

    def exit_signal(self,*args,**kwargs):
        """
        Returns 1 to exit trade.
        """
        aroon_down,aroon_up = self._last_calculate_result
        return two_cross_signal(aroon_up,aroon_down,bos_signal=False)