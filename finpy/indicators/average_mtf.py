import numpy as np

from finpy.indicator_types.utils import ma_method,ensure_prices_instance_method
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator,BaselineIndicator

class AveragesMTF(EntryIndicator,ExitIndicator,BaselineIndicator):
    """
    Averages MTF indicator

    Main use:
        - baseline indicator
        
    Secondary use:
        - entry indicator
        - exit indicator

    Typical use:
        - When values is under close price and crosses, its a buy signal
        - When values is over close price and crosses, its sell signal

    Calculation method:
        - dss_averages_of_momentum

    Input:
        - OHLC data: market data with open, high, low and close information
        - stochastic_length: period to make calculations. Default is 32
        - mom_period: period of momentum. Default is 14
        - smooth_ma_period: period of smooth moving average. Default is 9
        - signal_ma_period: moving average signal period. Default is 5
        - smooth_ma_method: moving average smoothing method. Default is 1
        - signal_ma_method: signal moving average method. Default is 1

    Output:
        - values, signal
    """
    @ensure_prices_instance_method
    def calculate(self,data,period=14,price=0,method=19):
        price_used = data.get_price(price).to_numpy()
        n = price_used.shape[0]
        if method == 9:
            values = ma_method(method)(price_used,data.tick_volume,period)
        else:
            values = ma_method(method)(price_used,period)
        signal = np.zeros(n)
        signal[1:] = np.where(values[1:]>values[:-1],1,np.where(values[1:]<values[:-1],-1,0))        
        return values,signal