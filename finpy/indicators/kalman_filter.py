import numpy as np

from finpy.indicator_types.utils import get_price
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator,BaselineIndicator


class KalmanFilter(EntryIndicator,ExitIndicator,BaselineIndicator):
    """
    Kalman Filter indicator

    Main use:
        - baseline indicator
        
    Secondary use:
        - entry indicator
        - exit indicator

    Typical use:
        - scenario 1:
            - when values is under close price and crosses, its buy signal
            - when values is over close price and crosses, its sell signal
       
        
    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - k: constant to perform calculations. Default is 1
        - sharpness: constant to perform calculations. Default is 1
        - mode: Price considered for calculations.
            - 0: close
            - 1: open
            - 2: high
            - 3: low
            - 4: median
            - 5: typical
            - 6: weighted
    Output:
        - upBuffer, dnBuffer, values
    """
    def calculate(self,data,mode=6,k=1,sharpness=1):
        velocity = 0
        distance = 0
        error = 0
        price_used = get_price(data,mode).to_numpy()
        n= price_used.shape[0]
        values = np.zeros(n)
        upBuffer = np.zeros(n)
        dnBuffer = np.zeros(n)
        values[0] = price_used[0]
        for i in range(1,n):
            distance = price_used[i]-values[i-1]
            error = values[i-1] + distance * np.sqrt(sharpness*k/100)
            velocity = velocity + distance*k/100
            values[i] = error + velocity
            if velocity>0:
                upBuffer[i] = values[i]
                dnBuffer[i] = np.nan
                if upBuffer[i-1] == np.nan:
                    upBuffer[i-1] = dnBuffer[i-1]
            else:
                upBuffer[i] = np.nan
                dnBuffer[i] = values[i]
                if dnBuffer[i-1] == np.nan:
                    dnBuffer[i-1] = upBuffer[i-1]
        return upBuffer,dnBuffer,values