import numpy as np

from finpy.indicator_types.categories import EntryIndicator,ExitIndicator
from finpy.indicator_types.utils import mql4_atr,ensure_prices_instance_method

class NonLagAngle(EntryIndicator,ExitIndicator):
    """
    Non Lag Angle indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - scenario 1:
            - when buffer 4 is over 0 and crosses, its buy signal
            - when buffer 4 is under 0 and crosses, its sell signal
        
        -scenario 2:
            - when buffer 1 is greater than 0 (not NaN) and previous is NaN, its buy signal
            - when buffer 2 is less than 0 (not NaN) and previous is NaN, its sell signal
        
    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - nlma_period: Non Lag Moving Average period. Default is 14
        - angle_level: Angle level used. Default is 8.0
        - angle_bars: Angle bars to consider. Default is 6
        - nlma_price: Price considered for calculations.
            - 0: close
            - 1: open
            - 2: high
            - 3: low
            - 4: median
            - 5: typical
            - 6: weighted
    Output:
        - buffer1, buffer2, buffer3, buffer4
    """
     
    def _calculate_alphas(self,length, instance_no):
        # Esta función calcula las ponderaciones (alphas) para iNonLagMa
        cycle = 4.0
        coeff = 3.0 * np.pi
        phase = length - 1
        len_total = length * 4 + phase

        alphas = np.zeros(len_total)
        for k in range(len_total):
            if k <= phase - 1:
                t = 1.0 * k / (phase - 1)
            else:
                t = 1.0 + (k - phase + 1) * (2.0 * cycle - 1.0) / (cycle * length - 1.0)

            beta = np.cos(np.pi * t)
            g = 1.0 / (coeff * t + 1) if t > 0.5 else 1

            alphas[k] = g * beta

        return alphas

    def _iNonLagMa(self,price_series, length, instance_no=0):
        alphas = self._calculate_alphas(length, instance_no)
        sum_alpha = alphas.sum()

        # Aplicar ponderaciones a los precios históricos
        nlm = np.convolve(price_series, alphas, 'valid') / sum_alpha

        # Completar los valores faltantes al inicio de la serie
        nlm_full = np.empty_like(price_series)
        nlm_full[:len(nlm)] = np.nan
        nlm_full[-len(nlm):] = nlm

        return nlm_full

    
    @ensure_prices_instance_method
    def calculate(self,data, nlma_period=14, angle_level=8.0, angle_bars=6, nlma_price = 0):
        # Calcula los valores del ATR y la Media Móvil No Retrasada
        atr = mql4_atr(data, angle_bars * 20)
        price1 = data.get_price(nlma_price)
        price2 = price1.shift(angle_bars)
        change = self._iNonLagMa(price1,nlma_period) - self._iNonLagMa(price2,nlma_period)
        
        angle = np.arctan(change / (atr * angle_bars)) * 180 / np.pi

        # # Inicializa los buffers (series) para los valores del indicador
        buffer1 = np.where(angle > angle_level, angle, np.nan)
        buffer2 = np.where(angle < -angle_level, angle, np.nan)
        buffer3 = np.where((-angle_level<angle) & (angle<angle_level),angle,np.nan)

        return buffer1, buffer2, buffer3, angle