from finpy.indicator_types.categories import BaselineIndicator
from finpy.indicator_types.utils import ma_method,ensure_prices_instance_method

class Sma(BaselineIndicator):
    """
    SMA indicator

    Main use:
        - baseline indicator
    
    Typical use:
        - When sma is under close price and crosses, its buy signal
        - When sma is over close price and crosses, its sell signal
    
    Input:
        - OHLC data: market data with ONLY open, high, low or close information
        - period: period for calculations. Default is 14
    
    Output:
        - sma values
    """
    @ensure_prices_instance_method
    def calculate(self,data,price=0,period=14):
        price_used = data.get_price(price)
        return ma_method('sma')(price_used,period)