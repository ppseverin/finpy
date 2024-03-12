import numpy as np
import pandas as pd

from finpy.indicator_types.utils import ensure_prices_instance_method
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class Vortex(EntryIndicator,ExitIndicator):
    """
    Vortex indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - When plus vi is over minus vi and crosses, its buy signal
        - When plus vi is under minus vi and crosses, its sell signal

    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - length: period used to make calculations. Default is 28

    Output:
        - plus vi, minus vi
    """
    @ensure_prices_instance_method
    def calculate(self,data, length=28):
        # Calculando True Range (TR)
        high_low = data.HIGH - data.LOW
        high_close = np.abs(data.HIGH - data.CLOSE.shift())
        low_close = np.abs(data.LOW - data.CLOSE.shift())
        tr = pd.DataFrame({'hl': high_low, 'hc': high_close, 'lc': low_close}).max(axis=1)

        # Calculando Vortex Movements (VM)
        plus_vm = np.abs(data.HIGH - data.LOW.shift())
        minus_vm = np.abs(data.LOW - data.HIGH.shift())

        # Suma de Vortex Movements y True Range para 'length' periodos
        sum_plus_vm = plus_vm.rolling(window=length).sum()
        sum_minus_vm = minus_vm.rolling(window=length).sum()
        sum_tr = tr.rolling(window=length).sum()

        # Calculando los indicadores Vortex (VI+ y VI-)
        plus_vi = sum_plus_vm / sum_tr
        minus_vi = sum_minus_vm / sum_tr

        return plus_vi, minus_vi