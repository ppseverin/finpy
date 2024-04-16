import numpy as np

from finpy.indicator_types.utils import ma_method
from finpy.indicator_types.signal_functions import two_cross_signal
from finpy.indicator_types.categories import BaselineIndicator


class AllMovingAverages(BaselineIndicator):
    """
    All Moving Average indicator

    Main use:
        - baseline indicator

    Typical use:
        - scenario 1:
            - when moving average is under close price and crosses, its buy signal
            - when moving average is over close price and crosses, its sell signal       
        
    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - period: period to perform calculations. Default is 50
        - mode: Price considered for calculations.
            - 0: close
            - 1: open
            - 2: high
            - 3: low
            - 4: median
            - 5: typical
            - 6: weighted
    Output:
        - moving average buffer
    """
    def calculate(self,data,period=50,price=0):
        price_used = data.get_price(price)
        moving_average_codes = [0,1,21,6,12,28,13,22,10,16,23,25,26,24,27,14,11]
        ma = np.empty_like(moving_average_codes,dtype=object)
        for index,code in enumerate(moving_average_codes):
            ma[index] = ma_method(code)(price_used,period)
        ma = ma.mean(axis=0)
        return ma
    
    def baseline_signal(self, *args, **kwargs):
        ma = self._last_calculate_result
        price = self._last_calculate_kwargs['data']
        return two_cross_signal(price.CLOSE,ma)