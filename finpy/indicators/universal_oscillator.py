import numpy as np

from finpy.indicator_types.categories import EntryIndicator,ExitIndicator
from finpy.indicator_types.utils import ma_method,ensure_prices_instance_method

class UniversalOscillator(EntryIndicator,ExitIndicator):
    """
    Universal Oscillator indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - When price calculated over 0 and crosses, its buy signal
        - When price calculated under 0 and crosses, its sell signal

    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information.
        - band_edge: period to make calculations. Default is 20.
        - price: price to consider to make calculations. Default is 'close'.
        - level_up: upper band. Default is 0.8.
        - level_down: lower band. Default is -0.8.

    Output:
        - price calculated, price calculated slope, price calculated zero cross, price calculated level cross

    """
    @ensure_prices_instance_method
    def calculate(self,data,band_edge=20,price='close',level_up=0.8,level_down=-0.8):
        price_used = data.get_price(price)
        white_noise = (price_used-price_used.shift(2))/2
        noise_filter = ma_method(18)(white_noise,band_edge)
        n = data.shape[0]
        peak = np.zeros(n)
        unio = np.zeros(n)
        for i in range(3,n):
            peak[i] = 0.991*peak[i-1]
            if abs(noise_filter[i])>peak[i]:
                peak[i] = abs(noise_filter[i])
        unio[3:] = noise_filter[3:]/peak[3:]
        unio_slope = np.sign(unio[1:]-unio[:-1])
        unio_zero_cross = np.where(unio>0,1,np.where(unio<0,-1,0))
        unio_level_cross = np.where(unio>level_up,1,np.where(unio<level_down,-1,0))
        return unio,unio_slope,unio_zero_cross,unio_level_cross