import numpy as np

from finpy.indicator_types.signal_functions import two_cross_signal
from finpy.indicator_types.categories import BaselineIndicator

class EhlersTwoPoleSuperSmootherFilter(BaselineIndicator):
    """
    Ehlers Two Pole Super Smoother Filter indicator

    Main use:
        - baseline indicator
    
    Typical use:
        - When values is under close price and crosses, its buy signal
        - When values is over close price and crosses, its sell signal
    
    Input:
        - OHLC data: market data with open, high, low and close information
        - period: period for calculations. Default is 15
    
    Output:
        - values
    """
    
    def calculate(self,data,cutoff_period=15):
        temp_real = np.arctan(1)
        rad2deg = 45/temp_real
        deg2rad = 1/rad2deg
        a1 = np.exp(-1.414*np.pi/cutoff_period)
        b1 = 2*a1*np.cos(deg2rad * 1.414*180/cutoff_period)
        coef3 = -a1*a1
        coef1 = 1 - b1 - coef3
        prices = data.OPEN.to_numpy()
        n = prices.shape[0]
        values = np.zeros(n)
        values[:4] = prices[:4]
        for i in range(4,n):
            values[i] = coef1 * prices[i] + b1 * values[i-1] + coef3 * values[i-2]
        return values
    
    def baseline_signal(self, *args, **kwargs):
        values = self._last_calculate_result
        price = self._last_calculate_kwargs['data']
        return two_cross_signal(price.CLOSE,values)