import numpy as np

from finpy.indicator_types.utils import get_price,mql4_atr,ma_method
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class AngleOfAverage(EntryIndicator,ExitIndicator):
    """
    Angle of Average 1.2 indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - scenario 1:
            - when angle is over 0 and crosses, its buy signal
            - when angle is under 0 and crosses, its sell signal
        
        -scenario 2:
            - when buffer 1 is greater than 0 (not NaN) and previous is NaN, its buy signal
            - when buffer 2 is less than 0 (not NaN) and previous is NaN, its sell signal
        
    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - period: Non Lag Moving Average period. Default is 34
        - angle_level: Angle level used. Default is 8.0
        - angle_bars: Angle bars to consider. Default is 6
        - avg_price: Price considered for calculations.
            - 0: close
            - 1: open
            - 2: high
            - 3: low
            - 4: median
            - 5: typical
            - 6: weighted
    Output:
        - buffer1, buffer2, buffer3, state, angle
    """
    def calculate(self,data,period=34,avg_type=1,price='close',angle_level=8,angle_bars=6):
        price_used = get_price(data,price)
        if avg_type == 9 or avg_type == 'volume weghted ma':
            avg_price = ma_method(avg_type)(price_used,data.tick_volume,period)
        else:
            avg_price = ma_method(avg_type)(price_used,period)
        atr = mql4_atr(data, angle_bars * 20)
        
        change = avg_price - avg_price.shift(angle_bars)
        angle = np.arctan(change / (atr * angle_bars)) * 180 / np.pi
        buffer1 = np.where(angle > angle_level, angle, np.nan)
        buffer2 = np.where(angle < -angle_level, angle, np.nan)
        buffer3 = np.where((-angle_level<angle) & (angle<angle_level),angle,np.nan)
        state = np.where(angle>angle_level,1,np.where(angle<-angle_level,-1,0))
        return buffer1,buffer2,buffer3,state,angle