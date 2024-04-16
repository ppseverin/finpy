from finpy.indicator_types.categories import BaselineIndicator
from finpy.indicator_types.utils import ma_method
from finpy.indicator_types.signal_functions import two_cross_signal

class Dema(BaselineIndicator):
    """
    DEMA indicator

    Main use:
        - baseline indicator
    
    Typical use:
        - When dema is under close price and crosses, its buy signal
        - When dema is over close price and crosses, its sell signal
    
    Input:
        - OHLC data: market data with open, high, low and close information
        - period: period for calculations. Default is 14
    
    Output:
        - dema values
    """
    def calculate(self,data,price=0,period=14):
        price_used = data.get_price(price).to_numpy()
        return ma_method('dema')(price_used,period)
    
    def baseline_signal(self, *args, **kwargs):
        dema = self._last_calculate_result
        price = self._last_calculate_kwargs['data']
        return two_cross_signal(price.CLOSE,dema)