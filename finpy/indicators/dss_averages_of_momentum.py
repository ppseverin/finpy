import talib


from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class DSS_AverageOfMomentum(EntryIndicator,ExitIndicator):
    def dss_averages_of_momentum(self,data, stochastic_length=32, smooth_ma=9, signal_ma=5, mom_period=14):
        # Calcular la EMA o SMA según la configuración
        # Aquí, tomaremos EMA como ejemplo para la simplificación
        ema_close = talib.EMA(data['close'], timeperiod=smooth_ma)

        # Calcular el momentum
        mom_close = talib.MOM(data['close'], timeperiod=mom_period)
        mom_high = talib.MOM(data['high'], timeperiod=mom_period)
        mom_low = talib.MOM(data['low'], timeperiod=mom_period)

        # Calcular el DSS (Double Smoothed Stochastic)
        # Esta es una simplificación y puede requerir ajustes según la lógica exacta del DSS
        dss = self._calculate_dss(mom_close, mom_high, mom_low, stochastic_length,smooth_ma,signal_ma)

        # Calcular la señal de suavizado
        signal = talib.SMA(dss, timeperiod=signal_ma)

        return dss, signal

    def _calculate_dss(self,mom_close, mom_high, mom_low, stochastic_length, smooth_ma, signal_ma):
        """
        Calcula el indicador Double Smoothed Stochastic (DSS).
        
        :param mom_close: Serie de momentum de precios de cierre.
        :param mom_high: Serie de momentum de precios altos.
        :param mom_low: Serie de momentum de precios bajos.
        :param stochastic_length: Longitud del oscilador estocástico.
        :param smooth_ma: Longitud de la primera suavización (usualmente SMA o EMA).
        :param signal_ma: Longitud de la segunda suavización.
        :return: Una tupla de arrays (dss_line, signal_line).
        """

        # Paso 1: Calcular el Oscilador Estocástico
        stoch_k = (mom_close - mom_low) / (mom_high - mom_low) * 100

        # Paso 2: Primera Suavización
        smooth_k = talib.SMA(stoch_k, timeperiod=smooth_ma)

        # Paso 3: Segunda Suavización
        smooth_d = talib.SMA(smooth_k, timeperiod=signal_ma)

        return smooth_k, smooth_d
