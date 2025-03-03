from finpy.indicator_types.categories import EntryIndicator,ExitIndicator
from finpy.indicator_types.signal_functions import two_cross_signal,one_over_other

class DSS_Bressert(EntryIndicator,ExitIndicator):
    """
    DSS Bressert indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - When dss up is 1, its buy signal
        - When dss down is 1, its sell signal

    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - stochastic_period: period to make calculations. Default is 5
        - smma_period: period of smma. Default is 8
        
    Output:
        - dss buffer, dss up, dss down
    """
    
    def calculate(self,data, smma_period=8, stochastic_period=5):
        smooth_coefficient = 2/(1+smma_period)

        high_range = data.HIGH.rolling(stochastic_period).max()
        low_range = data.LOW.rolling(stochastic_period).min()
        delta = data.CLOSE-low_range
        mit = delta/(high_range-low_range)*100
        mit_buffer = mit.ewm(alpha=smooth_coefficient, adjust=False).mean()
        
        high_range = mit_buffer.rolling(stochastic_period).max()
        low_range = mit_buffer.rolling(stochastic_period).min()
        delta = mit_buffer-low_range
        dss = delta/(high_range-low_range)*100
        dss_buffer = dss.ewm(alpha=smooth_coefficient, adjust=False).mean()

        dss_up = (dss_buffer>dss_buffer.shift(1)).astype(float)
        dss_down = (dss_buffer<dss_buffer.shift(1)).astype(float)

        return dss_buffer, dss_up, dss_down

    def entry_signal(self, *args, **kwargs):
        dss_buffer, dss_up, dss_down = self._last_calculate_result
        if self.main_confirmation_indicator:
            return two_cross_signal(dss_up,dss_down)
        return one_over_other(dss_up,dss_down)
    
    def exit_signal(self, *args, **kwargs):
        dss_buffer, dss_up, dss_down = self._last_calculate_result
        return two_cross_signal(dss_up,dss_down,bos_signal=False)