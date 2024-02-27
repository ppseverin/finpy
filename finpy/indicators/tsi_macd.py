import talib
import numpy as np

from finpy.indicator_types.utils import calculate_smma
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class TSIMacd(EntryIndicator,ExitIndicator):
    """
    TSI Macd indicator

    Main use:
        - entry indicator
        
    Secondary use:
        - exit indicator

    Typical use:
        - When tsi is over signal line and crosses, its buy signal
        - When tsi is under signal line and crosses, its sell signal

    Calculation method:
        - tsi_macd

    Input:
        - OHLC data: market data with open, high, low and close information
        - fast: fast period for macd. Default is 8
        - slow: slow period for macd. Default is 21
        - signal: signal period for macd. Default is 5
        - first_r: first period for EMA. Default is 8
        - second_s: second period for EMA. Default is 5
        - signal_period: signal period for smooth moving average. Default is 5
        - mode_smooth: mode used for smooth moving average. Default is 2

    Output:
        - tsi, signal line
    """
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