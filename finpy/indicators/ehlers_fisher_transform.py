import numpy as np
import pandas as pd

from finpy.indicator_types.signal_functions import two_cross_signal,one_over_other
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class EhlersFisherTransform(EntryIndicator,ExitIndicator):
    """
    Ehlers Fisher Transform indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - When fisher value is over signal and crosses, its buy signal
        - When fisher value is under signal and crosses, its sell signal

    Calculation method:
        - ehlers_fisher_transform

    Input:
        - OHLC data: market data with open, high, low and close information
        - period: period to make calculations. Default is 10
        - weight: weight for alpha. Default is 2
        - signal_period: period for ema. Default is 9
        - price_type: price to apply calculations. Default is 'median'
            - admited values:
                - median
                - close
                - high
                - low
                - open
                - typical
                - weighted
    Output:
        - fisher value, signal value
    """
    
    def calculate(self,data, period=10, weight=2, signal_period=9, price_type='median'):
        # Inicialización de buffers
        prices = data.get_price(price_type)
        # print(prices)
        alpha = 2.0 / (1.0 + weight)
        ema_alpha = 2.0 / (1.0 + signal_period)

        # Cálculos preliminares
        max_h = prices.rolling(window=period).max()
        min_l = prices.rolling(window=period).min()
        
        values = pd.Series(0,index=prices.index)
        values = np.zeros_like(data.CLOSE)
        fisher_value = np.zeros_like(values)
        signal_value = np.zeros_like(values)

        for index,(p,h,l) in enumerate(zip(prices,max_h,min_l)):
            if h!=h:
                continue
            if h!=l:
                value = alpha*((p-l)/(h-l)-0.5 + values[index-1])
                value = min(max(value,-0.999),0.999)
                values[index] = value
            fisher_value[index] = 0.5*np.log((1+values[index])/(1-values[index]))+0.5*fisher_value[index-1]
            
            signal_buffer_cond1 = (fisher_value[index]>signal_value[index-1]) and (fisher_value[index] > fisher_value[index-1])
            signal_buffer_cond2 = (fisher_value[index]<signal_value[index-1]) and (fisher_value[index] < fisher_value[index-1])
            if signal_buffer_cond1 or signal_buffer_cond2:
                signal_value[index] = signal_value[index-1]+ema_alpha*(fisher_value[index]-signal_value[index-1])
            else:
                signal_value[index] = signal_value[index-1]
        return fisher_value, signal_value
    
    def entry_signal(self, *args, **kwargs):
        fisher_value, signal_value = self._last_calculate_result
        if self.main_confirmation_indicator:
            return two_cross_signal(fisher_value,signal_value)
        return one_over_other(fisher_value,signal_value)
    
    def exit_signal(self, *args, **kwargs):
        fisher_value, signal_value = self._last_calculate_result
        return two_cross_signal(fisher_value,signal_value,bos_signal=False)