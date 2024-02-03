import talib
import numpy as np

from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class NonLagAngle(EntryIndicator,ExitIndicator):
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

    def calculate_non_lag_angle(self,data, nlma_period, angle_level, angle_bars):
        # Calcula los valores del ATR y la Media Móvil No Retrasada
        atr = talib.ATR(data['High'], data['Low'], data['Close'], angle_bars * 20)
        nlma1 = self._iNonLagMa(data['Close'], nlma_period)  # Implementar esta función
        nlma2 = nlma1.shift(angle_bars)

        # Calcula el ángulo
        change = nlma1 - nlma2
        angle = np.arctan(change / (atr * angle_bars)) * 180 / np.pi

        # Inicializa los buffers (series) para los valores del indicador
        buffer1 = np.where(angle > angle_level, angle, np.nan)
        buffer2 = np.where(angle < -angle_level, angle, np.nan)
        buffer3 = angle.copy()
        buffer4 = angle.copy()

        # Aplica la lógica de nivel de ángulo
        buffer3[np.abs(angle) <= angle_level] = np.nan
        buffer4[np.abs(angle) > angle_level] = np.nan

        return buffer1, buffer2, buffer3, buffer4