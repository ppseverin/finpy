import talib
import pandas as pd

from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class DSS_Bressert(EntryIndicator,ExitIndicator):
    def dss_bressert(self,data, smma_period=8, stochastic_period=5):
        # Calcular el estocástico
        stoch_k, stoch_d = talib.STOCH(data['high'], data['low'], data['close'],
                                    fastk_period=stochastic_period, slowk_period=smma_period,
                                    slowk_matype=0, slowd_period=smma_period, slowd_matype=0)

        # Calcular MIT (Modified Indicator Technique)
        mit = stoch_k
        mit_smooth = pd.Series(mit).ewm(span=smma_period, adjust=False).mean()

        # Aplicar el cálculo del DSS
        high_range_mit = mit_smooth.rolling(window=stochastic_period).max()
        low_range_mit = mit_smooth.rolling(window=stochastic_period).min()

        delta_mit = mit_smooth - low_range_mit
        dss = (delta_mit / (high_range_mit - low_range_mit)) * 100
        dss_smooth = dss.ewm(span=smma_period, adjust=False).mean()

        # Señales de compra y venta
        dss_up = (dss_smooth > dss_smooth.shift(1)).astype(float)
        dss_down = (dss_smooth < dss_smooth.shift(1)).astype(float)

        return dss_smooth, dss_up, dss_down
