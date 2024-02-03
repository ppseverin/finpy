import talib
import numpy as np
import pandas as pd

from finpy.indicator_types.utils import calculate_smma
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class TSIMacd(EntryIndicator,ExitIndicator):

    def tsi_macd(self,data, fast=8, slow=21, signal=5, first_r=8, second_s=5, signal_period=5,mode_smooth=2):
        # Calcular MACD usando TA-Lib
        macd, macdsignal, macdhist = talib.MACD(data['close'], fastperiod=fast, slowperiod=slow, signalperiod=signal)

        # Momento (MTM) y su valor absoluto (ABSMTM)
        mtm = macd.shift(-1).fillna(0) - macd
        absmtm = np.abs(mtm)
        
        # EMA del MTM y ABSMTM
        ema_mtm = talib.EMA(mtm, timeperiod=first_r)
        ema_absmtm = talib.EMA(absmtm, timeperiod=first_r)

        # Segunda EMA
        ema2_mtm = talib.EMA(ema_mtm, timeperiod=second_s)
        ema2_absmtm = talib.EMA(ema_absmtm, timeperiod=second_s)

        # TSI
        tsi = 100.0 * ema2_mtm / ema2_absmtm

        # Señal del TSI
        if mode_smooth == 2:
            signal_line = calculate_smma(tsi,signal_period)
        else:
            signal_line = talib.MA(tsi, timeperiod=signal_period,matype=mode_smooth)
        return tsi, signal_line