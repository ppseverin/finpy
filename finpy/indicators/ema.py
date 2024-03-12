from finpy.indicator_types.categories import BaselineIndicator
from finpy.indicator_types.utils import ma_method,ensure_prices_instance_method

class Ema(BaselineIndicator):
    """
    EMA indicator

    Main use:
        - baseline indicator
    
    Typical use:
        - When ema is under close price and crosses, its buy signal
        - When ema is over close price and crosses, its sell signal
    
    Input:
        - OHLC data: market data with ONLY open, high, low or close information
        - period: period for calculations. Default is 14
    
    Output:
        - ema values
    """
    @ensure_prices_instance_method
    def calculate(self,data,price=0,period=14):
        price_used = data.get_price(price)
        return ma_method('ema')(price_used,period)