import numpy as np
import pandas as pd

from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class Vortex(EntryIndicator,ExitIndicator):
    def vortex_indicator(self,data, length=28):
        # Calculando True Range (TR)
        high_low = data['high'] - data['low']
        high_close = np.abs(data['high'] - data['close'].shift())
        low_close = np.abs(data['low'] - data['close'].shift())
        tr = pd.DataFrame({'hl': high_low, 'hc': high_close, 'lc': low_close}).max(axis=1)

        # Calculando Vortex Movements (VM)
        plus_vm = np.abs(data['high'] - data['low'].shift())
        minus_vm = np.abs(data['low'] - data['high'].shift())

        # Suma de Vortex Movements y True Range para 'length' periodos
        sum_plus_vm = plus_vm.rolling(window=length).sum()
        sum_minus_vm = minus_vm.rolling(window=length).sum()
        sum_tr = tr.rolling(window=length).sum()

        # Calculando los indicadores Vortex (VI+ y VI-)
        plus_vi = sum_plus_vm / sum_tr
        minus_vi = sum_minus_vm / sum_tr

        return plus_vi, minus_vi