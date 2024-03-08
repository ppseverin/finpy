import numpy as np

from finpy.indicator_types.utils import get_price,ma_method
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator,BaselineIndicator


class AllMovingAverages(EntryIndicator,ExitIndicator,BaselineIndicator):
    """
    All Moving Average indicator

    Main use:
        - baseline indicator
        
    Secondary use:
        - entry indicator
        - exit indicator

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
        price_used = get_price(data,price)
        moving_average_codes = [0,1,21,6,12,28,13,22,10,16,23,25,26,24,27,14,11]
        ma = np.empty_like(moving_average_codes,dtype=object)
        for index,code in enumerate(moving_average_codes):
            ma[index] = ma_method(code)(price_used,period)
        ma = ma.mean(axis=0)
        return ma