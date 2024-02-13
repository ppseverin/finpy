import numpy as np
import pandas as pd

from finpy.indicator_types.utils import ma_method
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class DSS_AverageOfMomentum(EntryIndicator,ExitIndicator):
    """
    DSS Average of Momentum indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - When aroon up is over aroon down and crosses, its buy signal
        - When aroon up is under aroon down and crosses, its sell signal

    Calculation method:
        - dss_averages_of_momentum

    Input:
        - OHLC data: market data with open, high, low and close information
        - stochastic_length: period to make calculations. Default is 32
        - mom_period: period of momentum. Default is 14
        - smooth_ma_period: period of smooth moving average. Default is 9
        - signal_ma_period: moving average signal period. Default is 5
        - smooth_ma_method: moving average smoothing method. Default is 1
        - signal_ma_method: signal moving average method. Default is 1

    Output:
        - dss buffer, signal buffer
    """
    def dss_averages_of_momentum(self,data, stochastic_length=32,mom_period = 14, smooth_ma_period=9, signal_ma_period=5,smooth_ma_method=1,signal_ma_method=1):
        """
        Calcula un indicador personalizado similar al indicador MQL4 proporcionado.
        
        :param data: DataFrame de pandas con columnas 'High', 'Low' y 'Close'.
        :param stochastic_length: Longitud del período estocástico.
        :param smooth_ma_period: Período de suavizado para el promedio móvil de DSS.
        :param signal_ma_period: Período del promedio móvil para la línea de señal.
        :return: dssBuffer,sigBuffer
        """
        dssBuffer = np.empty_like(data.shape[0])
        sigBuffer = np.empty_like(data.shape[0])
        
        momc = data.close - data.close.shift(mom_period)
        momh = data.high - data.high.shift(mom_period)
        moml = data.low - data.low.shift(mom_period)
        # Calculando el oscilador estocástico
        dssBuffer = self._i_dss(momc,momh,moml,data.tick_volume,stochastic_length,smooth_ma_period,smooth_ma_method)
        
        if smooth_ma_method == 9:
            sigBuffer = ma_method(signal_ma_method)(dssBuffer,data.tick_volume,signal_ma_period)
        else:
            sigBuffer = ma_method(signal_ma_method)(dssBuffer,signal_ma_period)
        
        if not isinstance(sigBuffer,pd.Series):
            sigBuffer = pd.Series(sigBuffer)
        
        if not isinstance(dssBuffer,pd.Series):
            dssBuffer = pd.Series(dssBuffer)

        return dssBuffer,sigBuffer

    def _i_dss(self,momc,momh,moml,volume,stochastic_length,smooth_ma_period,smooth_ma_method):
        workDss_high = np.empty_like(momc)
        workDss_low = np.empty_like(momc)

        workDss_low[:] = moml
        workDss_high[:] = momh

        _min = moml.rolling(stochastic_length).min()
        _max = momh.rolling(stochastic_length).max()
        
        workDss_stl = np.where(_max!=_min,100*(momc-_min)/(_max-_min),0)

        if smooth_ma_method == 9:
            ma = ma_method(smooth_ma_method)(workDss_stl,volume,smooth_ma_period)
        else:
            ma = ma_method(smooth_ma_method)(workDss_stl,smooth_ma_period)
        workDss_ssl = pd.Series(ma)

        _min = workDss_ssl.rolling(stochastic_length).min()
        _max = workDss_ssl.rolling(stochastic_length).max()

        stoch = np.where(_max!=_min,100*(workDss_ssl-_min)/(_max-_min),0)

        if smooth_ma_method == 9:
            ma = ma_method(smooth_ma_method)(stoch,volume,smooth_ma_period)
        else:
            ma = ma_method(smooth_ma_method)(stoch,smooth_ma_period)

        workDss_dss = pd.Series(ma)
        workDss_dss = workDss_dss.apply(lambda x: min(max(x,0),100))
        return workDss_dss