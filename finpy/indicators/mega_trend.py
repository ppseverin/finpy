import numpy as np
import pandas as pd

from finpy.indicator_types.utils import get_price,ma_method
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator,BaselineIndicator

class MegaTrend(EntryIndicator,ExitIndicator,BaselineIndicator):
    """
    Mega Trend indicator

    Main use:
        - baseline indicator
        
    Secondary use:
        - entry indicator
        - exit indicator

    Typical use:
        - scenario 1:
            - when upTrend is over 0 and crosses, its buy signal
            - when dnTrend is under 0 and crosses, its sell signal
       
        
    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - period: period for calculations. Default is 15
        - method: Moving average method. Default is 3
        - price: Price considered for calculations.
            - 0: close
            - 1: open
            - 2: high
            - 3: low
            - 4: median
            - 5: typical
            - 6: weighted
    Output:
        - upTrend, dnTrend, vect2
    """
    def calculate(self,data,period=15,method=3,price=0):
        p = int(np.sqrt(period))
        e = data.shape[0] + 1 + period + 1
        if e>data.shape[0]+1:
            e=data.shape[0]+1
        price_used = get_price(data,price)
        vect = 2*ma_method(method)(price_used,int(period/2))-ma_method(method)(price_used,period)
        vect2 = pd.Series(vect).rolling(p).mean()
        n = vect2.shape[0]
        upTrend = np.zeros(n)
        dnTrend = np.zeros(n)
        for i in range(1,n):
            if vect2[i]>vect2[i-1]:
                upTrend[i] = 1
                # if vect2[i-2]<0:
            elif vect2[i]<vect2[i-1]:
                dnTrend[i] = 1
        return upTrend,dnTrend,vect2