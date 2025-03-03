import talib
import inspect
import numpy as np
import pandas as pd

from functools import wraps

from finpy.indicator_types.price_types import Prices


def ensure_prices_instance_method(method):
    @wraps(method)
    def wrapper(self,data,*args,**kwargs):
        if not isinstance(data,Prices):
            data = Prices(data)
        return method(self,data,*args,**kwargs)
    return wrapper

# def calculate_before_signal(method):
#     # def decorated_calculate(self,*args,**kwargs):
#     #     self.last_calculate_args = args
#     #     self.last_calculate_kwargs = kwargs
#     #     return method(self,*args,**kwargs)
    
#     # def wrapper(self,*args,**kwargs):
#     #     output = self.calculate(*args,**kwargs)
#     #     return method(self,output,*args,**kwargs)
#     # def wrapper(self,*args,**kwargs):
#     #     self.calculate = decorated_calculate.__get__(self,type(self))
#     #     return self.calculate(*args,**kwargs)
#     def wrapper(self,*args,**kwargs):
#         print('[KWARGS EN calculate_before_signal]',kwargs)
#         if not hasattr(self,'_last_calculate_result'):
#             self._last_calculate_args = args
#             self._last_calculate_kwargs = kwargs
#             self._last_calculate_result = self.calculate(*args,**kwargs)
#         return method(self,*args,**kwargs)
#     return wrapper


def calculate_before_signal(method):
    @wraps(method)
    def wrapper(self, *args, **kwargs):
        # def _compare_calculate_args(new_args, new_kwargs):
        #     """Compara los nuevos argumentos con los últimos utilizados en 'calculate'."""
        #     last_args, last_kwargs = self._last_calculate_args
        #     # Compara los argumentos posicionales y con palabra clave
        #     return last_args == new_args and last_kwargs == new_kwargs
        
        if not hasattr(self, '_last_calculate_result') or not hasattr(self, '_last_calculate_args'):# or not _compare_calculate_args(args, kwargs):
            # Obtener la signatura de la función 'calculate'
            sig = inspect.signature(self.calculate)
            
            # Vincular los argumentos actuales a los parámetros, incluyendo los valores por defecto
            bound_args = sig.bind(*args, **kwargs)
            bound_args.apply_defaults()

            # Separar argumentos posicionales y con palabra clave
            arguments = bound_args.arguments
            # self._last_calculate_args = [arguments[param.name] for param in sig.parameters.values() 
            #                             if param.name != 'self' and param.kind in [inspect.Parameter.POSITIONAL_OR_KEYWORD,
            #                                                                         inspect.Parameter.POSITIONAL_ONLY]]
            self._last_calculate_args = (args, kwargs)
            self._last_calculate_kwargs = {param.name: arguments[param.name] for param in sig.parameters.values()
                                        if param.kind == inspect.Parameter.POSITIONAL_OR_KEYWORD}
            
            # Ejecutar 'calculate' y almacenar el resultado
            calculate_result = self.calculate(**self._last_calculate_kwargs)
            self._last_calculate_result = calculate_result

        # Proceder con la ejecución del método original
        return method(self, *args, **kwargs)
    return wrapper

def inject_prices_instance(func):
    def wrapper(self,*args, **kwargs):
        prices = get_prices_instance(*args, **kwargs)
        if prices is None:
            prices = self._last_calculate_kwargs['data']
            # raise ValueError("Prices instance not found in arguments")
        return func(self,*args, **kwargs, prices=prices)
    return wrapper

def calculate_and_inject_prices(method):
    @calculate_before_signal
    @inject_prices_instance
    def wrapper(self,*args,**kwrags):
        return method(self,*args,**kwrags)
    return wrapper


def get_prices_instance(*args,**kwargs):
    for arg in args:
        if isinstance(arg,Prices):
            return arg
    for value in kwargs.values():
        if isinstance(value,Prices):
            return value

def mql4_atr(data, period=14):
    if not isinstance(data,Prices):
        data = Prices(data)
    # _data = data.reset_index(drop=True).copy()
    high = data.HIGH.to_numpy()
    low = data.LOW.to_numpy()
    close = data.CLOSE.to_numpy()
    rates_total = len(close)
    
    if rates_total <= period or period <= 0:
        return []
    
    # Inicializando buffers
    tr_buffer = np.zeros(rates_total)
    atr_buffer = np.zeros(rates_total)
    
    # Cálculo preliminar de True Range
    for i in range(1, rates_total):
        tr_buffer[i] = max(high[i], close[i-1]) - min(low[i], close[i-1])
    
    # Calculando el primer valor ATR
    first_value = np.sum(tr_buffer[1:period+1]) / period
    atr_buffer[period] = first_value
    
    # Bucle principal de cálculos para ATR
    for i in range(period + 1, rates_total):
        atr_buffer[i] = atr_buffer[i-1] + (tr_buffer[i] - tr_buffer[i-period]) / period
    
    # Ajustando para que los primeros 'period' valores sean cero, como en MQL4
    atr_buffer[:period] = np.nan
    
    return atr_buffer

def calculate_heikin_ashi(data):
    ha_close = (data['open'] + data['high'] + data['low'] + data['close']) / 4
    ha_open = (data['open'].shift(1) + data['close'].shift(1)) / 2
    ha_high = data[['high', 'close', 'open']].max(axis=1)
    ha_low = data[['low', 'close', 'open']].min(axis=1)

    ha_data = pd.DataFrame({
        'date':data['date'],
        'time':data['time'],
        'open':ha_open,
        'high':ha_high,
        'low':ha_low,
        'close':ha_close,
        'tick_volume':data['tick_volume']
    })
    return ha_data

def calculate_smma(data, period):
    smma = np.zeros_like(data)
    start_from = data[data.isna()].index.max()+1
    smma[:start_from+period-1] = np.nan  # Opcional, dependiendo de cómo quieras manejar el inicio de la serie
    
    # Calcula la primera SMMA (media móvil simple de los primeros `period` valores)
    smma[start_from+period-1] = np.mean(data[start_from:period])
    
    # Calcula las SMMA subsiguientes
    for i in range(period+start_from+1, len(data)):
        smma[i] = (smma[i-1] * (period - 1) + data[i]) / period
    return pd.Series(smma)

def _get_price_translator(price_type):
    if price_type == 0:
        return 'close'
    elif price_type == 1:
        return 'open'
    elif price_type == 2:
        return 'high'
    elif price_type == 3:
        return 'low'
    elif price_type == 4:
        return 'median'
    elif price_type == 5:
        return 'typical'
    elif price_type == 6:
        return 'weighted'
    elif price_type == 7:
        return 'average'
    elif price_type == 8:
        return 'average median body'
    elif price_type == 9:
        return 'trend biased'
    elif price_type == 10:
        return 'trend biased extreme'
    elif price_type in range(11,22):
        return f'heiken ashi {_get_price_translator(price_type-11)}'
    
def get_price(data, price_type,heiken_ashi=False):
    """
    Calcula el precio especificado utilizando TA-Lib.

    :param data: DataFrame de Pandas con las columnas 'high', 'low', 'close', 'open'.
    :param price_type: Tipo de precio a calcular ('median', 'close', 'high', 'low', etc.).
    :return: Serie de Pandas con el precio calculado.
    """
    if isinstance(price_type,int):
        price_type = _get_price_translator(price_type)
    if isinstance(price_type,type(None)):
        raise ValueError("Price type can not be None")
    
    price_to_use = None
    if price_type.lower() == 'median':
        price_to_use = talib.MEDPRICE(data['high'], data['low'])
    elif price_type.lower() == 'close':
        price_to_use = data['close']
    elif price_type.lower() == 'high':
        price_to_use = data['high']
    elif price_type.lower() == 'low':
        price_to_use = data['low']
    elif price_type.lower() == 'open':
        price_to_use = data['open']
    elif price_type.lower() == 'typical':
        price_to_use = talib.TYPPRICE(data['high'], data['low'], data['close'])
    elif price_type.lower() == 'weighted':
        price_to_use = talib.WCLPRICE(data['high'], data['low'], data['close'])
    elif price_type.lower() == 'average' or price_type.lower() == 'average (high+low+open+close)/4':
        price_type = 'average'
        price_to_use = talib.AVGPRICE(data['open'],data['high'], data['low'], data['close'])
    elif price_type.lower() == 'average median body (open+close)/2' or price_type.lower() == 'average median body':
        price_type = 'average median body'
        price_to_use = (data['open']+data['close'])/2
    elif price_type.lower() == 'trend biased':
        price_to_use = np.where(data['close']>data['open'],(data['high']+data['close'])/2,(data['low']+data['close'])/2)
    elif price_type.lower() == 'trend biased extreme':
        price_to_use = np.where(data['close']>data['open'],data['high'],np.where(data['close']<data['open'],data['low'],data['close']))
    elif 'heiken ashi' in price_type.lower():
        data = calculate_heikin_ashi(data)
        _,_,price_type = price_type.lower().partition('heiken ashi')
        price_type = price_type.strip()
        return get_price(data,price_type,heiken_ashi=True)
    else:
        raise ValueError("Tipo de precio no reconocido.")
    
    
    if isinstance(price_type,pd.Series) and price_to_use.name == None:
        price_to_use.name = price_type.lower().replace(' ','_')+'_price'
    else:
        price_to_use = pd.Series(price_to_use,name=price_type.lower().replace(' ','_')+'_price')
    if heiken_ashi:
        price_to_use.name = 'heiken_ashi_'+price_to_use.name
    return price_to_use
    

def _ma_method_translator(method):
    method_dict = {
        0:"sma",
        1:"ema",
        2:"double smoothed ema",
        3:"double ema (dema)",
        4:"triple ema (tema)",
        5:"smoothed ma",
        6:"linear weighted ma",
        7:"parabolic weighted ma",
        8:"alexander ma",
        9:"volume weghted ma",
        10:"hull ma",
        11:"triangular ma",
        12:"sine weighted ma",
        13:"linear regression",
        14:"ie/2",
        15:"nonlag ma",
        16:"zero lag ema",
        17:"leader ema",
        18:"super smoother",
        19:"smoother",
        20:'stddev',
        21:'wilder',
        22:'smma',
        23:'itrend',
        24:'rema',
        25:'median',
        26:'geomean',
        27:'ilrs',
        28:'itrima'
    }
    return method_dict.get(method,None)

def ma_method(method):
    if isinstance(method,int):
        method = _ma_method_translator(method)
    
    method = method.lower()
    if method == 'sma':
        return talib.SMA
    elif method == 'ema':
        return talib.EMA
    elif method == 'double smoothed ema':
        def double_smooth_ema(price,period):
            alpha = 2.0/(1+np.sqrt(period))
            if not isinstance(price,pd.Series):
                price = pd.Series(price)
            ema1 = price.ewm(alpha=alpha,adjust=False).mean()
            ema2 = ema1.ewm(alpha=alpha,adjust=False).mean()
            return ema2.to_numpy()
        return double_smooth_ema
    elif method == 'double ema (dema)' or method == 'dema':
        return talib.DEMA
    elif method == 'triple ema (tema)' or method == 'tema':
        return talib.TEMA
    elif method == 'smoothed ma':
        def calculate_smma(data, period):
            if not isinstance(data,pd.Series):
                data = pd.Series(data)
            smma = np.zeros_like(data)
            start_from = data.first_valid_index() #data[data.isna()].index.max()+1
            smma[:start_from+period-1] = np.nan  # Opcional, dependiendo de cómo quieras manejar el inicio de la serie
            
            # Calcula la primera SMMA (media móvil simple de los primeros `period` valores)
            smma[start_from+period-1] = np.mean(data[start_from:period])
            
            # Calcula las SMMA subsiguientes
            for i in range(period+start_from+1, len(data)):
                smma[i] = (smma[i-1] * (period - 1) + data[i]) / period
            return smma
        return calculate_smma
    elif method == 'linear weighted ma' or method == 'wma':
        return talib.WMA
    elif method == 'parabolic weighted ma' or method == 'pwma':
        def parabolic_lwma(price,period):
            """
            Calcula una Media Móvil Ponderada Parabólicamente (PWMA).
            
            :param data: Serie o lista de precios.
            :param period: Período para calcular la PWMA.
            :return: Serie de pandas con los valores de PWMA.
            """
            if not isinstance(price, pd.Series):
                price = pd.Series(price)

            # Inicializar la serie para almacenar los valores PWMA
            pwma = pd.Series(index=price.index, dtype='float64')

            # Calcular PWMA
            for i in range(len(price)):
                if i + 1 >= period:
                    # Calculando la suma ponderada y la suma de los pesos
                    sumw = 0
                    sum = 0
                    for k in range(period):
                        weight = (period - k) ** 2
                        sumw += weight
                        sum += weight * price.iloc[i - k]
                    pwma.iloc[i] = sum / sumw
            return pwma.to_numpy()
        return parabolic_lwma
    elif method == 'alexander ma' or method == 'alexander':
        def alexander_ma(price, period):
            """
            Calcula la Media Móvil de Alexander.

            :param data: Serie o lista de precios.
            :param period: Período para calcular la Media Móvil de Alexander.
            :return: Serie de pandas con los valores de la Media Móvil de Alexander.
            """
            if not isinstance(price, pd.Series):
                price = pd.Series(price)

            if period < 4:
                return price

            # Inicializar la serie para almacenar los valores de la Media Móvil de Alexander
            alex_ma = pd.Series(index=price.index, dtype='float64')

            # Calcular la Media Móvil de Alexander
            for i in range(len(price)):
                if i + 1 >= period:
                    sumw = 0
                    sum = 0
                    for k in range(period):
                        weight = period - k - 2
                        sumw += weight
                        sum += weight * price.iloc[i - k]
                    alex_ma.iloc[i] = sum / sumw #if sumw != 0 else price.iloc[i]
            return alex_ma.to_numpy()
        return alexander_ma
    elif method == 'volume weghted ma' or method == 'vwma':
        def iWwma(price, volume, period):
            """
            Calcula la Media Móvil Ponderada por Volumen (WVMA).

            :param price: Nombre de la columna en 'data' que contiene los precios.
            :param volume_column: Nombre de la columna en 'data' que contiene los volúmenes.
            :param period: Período para calcular la WVMA.
            :return: Serie de pandas con los valores de WVMA.
            """
            # Inicializar la serie para almacenar los valores WVMA
            if not isinstance(price, pd.Series):
                price = pd.Series(price)
            wwma = pd.Series(index=price.index, dtype='float64')

            # Calcular WVMA
            for i in range(len(price)):
                if i + 1 >= period:
                    sumw = 0
                    sum = 0
                    for k in range(period):
                        weight = volume.iloc[i - k]
                        sumw += weight
                        sum += weight * price.iloc[i - k]
                    wwma.iloc[i] = sum / sumw if sumw != 0 else price.iloc[i]
            return wwma.to_numpy()
        return iWwma
    elif method == 'hull ma' or method == 'hull':
        def hull_moving_average(price, period):
            """
            Calcula la Media Móvil de Hull (HMA).

            :param data: Serie de pandas que contiene los datos de precios.
            :param period: Período para calcular la HMA.
            :return: Serie de pandas con los valores de HMA.
            """
            if not isinstance(price, pd.Series):
                price = pd.Series(price)
            
            half_period = int(np.floor(period / 2))
            sqrt_period = int(np.floor(np.sqrt(period)))

            # Primera WMA para la mitad del período
            wma_half = price.rolling(window=half_period).apply(lambda x: np.dot(x, np.arange(1, half_period + 1)) / np.arange(1, half_period + 1).sum(), raw=True)

            # Segunda WMA para el período completo
            wma_full = price.rolling(window=period).apply(lambda x: np.dot(x, np.arange(1, period + 1)) / np.arange(1, period + 1).sum(), raw=True)

            # Combinar las dos WMAs para calcular la HMA
            hma = 2 * wma_half - wma_full

            # WMA final del resultado para el período de la raíz cuadrada del período original
            hma = hma.rolling(window=sqrt_period).apply(lambda x: np.dot(x, np.arange(1, sqrt_period + 1)) / np.arange(1, sqrt_period + 1).sum(), raw=True)

            return hma.to_numpy()
        return hull_moving_average
    elif method == 'triangular ma' or method == 'trima':
        return talib.TRIMA
    elif method == 'sine weighted ma' or method == 'swma':
        def sine_weighted_moving_average(price, period):
            """
            Calcula la Media Móvil Ponderada por Seno (Sine WMA).

            :param data: Serie de pandas que contiene los datos de precios.
            :param period: Período para calcular la Sine WMA.
            :return: Serie de pandas con los valores de Sine WMA.
            """
            if not isinstance(price, pd.Series):
                price = pd.Series(price)

            # Inicializar la serie para almacenar los valores de Sine WMA
            sine_wma = pd.Series(index=price.index, dtype='float64')

            # Calcular Sine WMA
            for i in range(len(price)):
                if i + 1 >= period:
                    sumw = 0
                    sum = 0
                    for k in range(period):
                        weight = np.sin(np.pi * (k + 1) / (period + 1))
                        sumw += weight
                        sum += weight * price.iloc[i - k]
                    sine_wma.iloc[i] = sum / sumw
            return sine_wma.to_numpy()
        return sine_weighted_moving_average
    elif method == 'linear regression' or method == 'linear reg':
        return talib.LINEARREG
    elif method == 'ie/2' or method == 'ie':
        def ie2_moving_average(price, period):
            """
            Calcula una media móvil personalizada basada en regresión lineal.

            :param data: Serie de pandas que contiene los datos de precios.
            :param period: Período para calcular la media móvil.
            :return: Serie de pandas con los valores de la media móvil.
            """
            if not isinstance(price, pd.Series):
                price = pd.Series(price)

            ie2_ma = pd.Series(index=price.index, dtype='float64')

            for r in range(len(price)):
                if r + 1 >= period:
                    sumx = sumxx = sumxy = sumy = 0

                    for k in range(period):
                        _price = price.iloc[r - k]
                        sumx += k
                        sumxx += k**2
                        sumxy += k * _price
                        sumy += _price

                    tslope = (period * sumxy - sumx * sumy) / (sumx**2 - period * sumxx)
                    average = sumy / period
                    ie2_ma.iloc[r] = ((average + tslope) + (sumy + tslope * sumx) / period) / 2

            return ie2_ma.to_numpy()
        return ie2_moving_average
    elif method == 'nonlag ma' or method == 'nonlag':
        def non_lag_moving_average(data, length):
            """
            Calcula la Media Móvil No Retrasada (Non-Lag Moving Average).

            :param data: Serie de pandas que contiene los datos de precios.
            :param length: Longitud del período para la media móvil.
            :return: Serie de pandas con los valores de la media móvil no retrasada.
            """
            if not isinstance(data, pd.Series):
                data = pd.Series(data)

            if length < 3:
                return data

            nlm_ma = pd.Series(index=data.index, dtype='float64')

            cycle = 4.0
            coeff = 3.0 * np.pi
            phase = length - 1

            for r in range(len(data)):
                if r < 3:
                    nlm_ma.iloc[r] = data.iloc[r]
                    continue

                # Calcular alphas y pesos
                nlmalphas = []
                weight_sum = 0
                for k in range(length * 4 + phase):
                    t = 1.0 * k / (phase - 1) if k <= phase - 1 else 1.0 + (k - phase + 1) * (2.0 * cycle - 1.0) / (cycle * length - 1.0)
                    beta = np.cos(np.pi * t)
                    g = 1.0 / (coeff * t + 1) if t > 0.5 else 1
                    alpha = g * beta
                    nlmalphas.append(alpha)
                    weight_sum += alpha

                # Calcular la media móvil no retrasada
                sum = 0
                for k in range(min(len(nlmalphas), r + 1)):
                    sum += nlmalphas[k] * data.iloc[r - k]

                nlm_ma.iloc[r] = sum / weight_sum if weight_sum > 0 else data.iloc[r]

            return nlm_ma.to_numpy()
        return non_lag_moving_average
    elif method == 'zero lag ema' or method == 'zero lag':
        def zero_lag_ema(data, length):
            """
            Calcula la Media Móvil Exponencial Sin Retraso (Zero-Lag EMA).

            :param data: Serie de pandas que contiene los datos de precios.
            :param length: Longitud del período para la EMA.
            :return: Serie de pandas con los valores de Zero-Lag EMA.
            """
            if not isinstance(data, pd.Series):
                data = pd.Series(data)

            alpha = 2.0 / (1.0 + length)
            per = int((length - 1) / 2)

            zlema = pd.Series(index=data.index, dtype='float64')
            
            # Encontrar el primer índice desde el cual hay suficientes datos no-NaN
            first_valid_index = data.dropna().iloc[per:].first_valid_index()
            
            if first_valid_index is None:
                # Si todos los valores son NaN o no hay suficientes datos, devuelve la serie original
                return data

            # Inicializar el primer valor no-NaN de zlema
            zlema.iloc[first_valid_index] = data.iloc[first_valid_index]

            for r in range(first_valid_index + 1, len(data)):
                price_lagged = data.iloc[r - per] if r - per >= first_valid_index else data.iloc[first_valid_index]
                zlema.iloc[r] = zlema.iloc[r - 1] + alpha * (2 * data.iloc[r] - price_lagged - zlema.iloc[r - 1])

            return zlema.to_numpy()
        return zero_lag_ema
    elif method == 'leader ema' or method == 'leader':
        def leader_moving_average(data, period):
            """
            Calcula una variante de la Media Móvil Exponencial llamada 'Leader Moving Average'.

            :param data: Serie de pandas que contiene los datos de precios.
            :param period: Periodo para calcular la Leader Moving Average.
            :return: Serie de pandas con los valores de Leader Moving Average.
            """
            if not isinstance(data, pd.Series):
                data = pd.Series(data)

            period = max(period, 1)
            alpha = 2.0 / (period + 1.0)

            leader1 = pd.Series(index=data.index, dtype='float64')
            leader2 = pd.Series(index=data.index, dtype='float64')
            
            # Encontrar el primer índice no-NaN
            first_valid_index = data.first_valid_index()

            if first_valid_index is None:
                # Si todos los valores son NaN, devuelve la serie original
                return data

            # Inicializar los primeros valores de leader1 y leader2
            leader1.iloc[first_valid_index] = data.iloc[first_valid_index]
            leader2.iloc[first_valid_index] = 0

            for r in range(first_valid_index + 1, len(data)):
                leader1.iloc[r] = leader1.iloc[r - 1] + alpha * (data.iloc[r] - leader1.iloc[r - 1])
                leader2.iloc[r] = leader2.iloc[r - 1] + alpha * (data.iloc[r] - leader1.iloc[r] - leader2.iloc[r - 1])

            leader_ma = leader1 + leader2
            return leader_ma.to_numpy()
        return leader_moving_average
    elif method == 'super smoother' or method == 'sssm':
        def ssm_moving_average(data, period):
            """
            Calcula una media móvil personalizada (Super Smoother Moving Average - SSM).

            :param data: Serie de pandas que contiene los datos de precios.
            :param period: Periodo para calcular la SSM.
            :return: Serie de pandas con los valores de SSM.
            """
            if not isinstance(data, pd.Series):
                data = pd.Series(data)

            a1 = np.exp(-1.414 * np.pi / period)
            b1 = 2.0 * a1 * np.cos(1.414 * np.pi / period)
            c1 = 1.0 - b1 + a1**2

            ssm = pd.Series(index=data.index, dtype='float64')

            # Encontrar el primer índice no-NaN
            first_valid_index = data.first_valid_index()

            if first_valid_index is None:
                # Si todos los valores son NaN, devuelve la serie original
                return data

            # Inicializar los primeros valores válidos de ssm
            ssm.iloc[first_valid_index] = data.iloc[first_valid_index]
            if first_valid_index + 1 < len(data):
                ssm.iloc[first_valid_index + 1] = c1 * (data.iloc[first_valid_index + 1] + data.iloc[first_valid_index]) / 2.0 + b1 * ssm.iloc[first_valid_index]

            for i in range(first_valid_index + 2, len(data)):
                ssm.iloc[i] = c1 * (data.iloc[i] + data.iloc[i - 1]) / 2.0 + b1 * ssm.iloc[i - 1] - a1**2 * ssm.iloc[i - 2]

            return ssm.to_numpy()
        return ssm_moving_average
    elif method == 'smoother' or method == 'ssm':
        def smooth_moving_average(data, length):
            """
            Calcula una serie de valores suavizados basada en la función iSmooth.

            :param data: Serie de pandas que contiene los datos de precios, que puede incluir NaN al principio.
            :param length: Longitud del período para el suavizado.
            :return: Serie de pandas con los valores suavizados.
            """
            if not isinstance(data, pd.Series):
                data = pd.Series(data)

            alpha = 0.45 * (length - 1.0) / (0.45 * (length - 1.0) + 2.0)

            # Inicializar las series para los cálculos
            smooth0 = pd.Series(0,index=data.index, dtype='float64')
            smooth1 = pd.Series(0,index=data.index, dtype='float64')
            smooth2 = pd.Series(0,index=data.index, dtype='float64')
            smooth3 = pd.Series(0,index=data.index, dtype='float64')
            smooth4 = pd.Series(0,index=data.index, dtype='float64')
            
            # Encontrar el primer índice no-NaN
            first_valid_index = data.first_valid_index()

            if first_valid_index is None:
                return data  # Si todos son NaN, devuelve la serie original
            
            # Inicialización de los primeros valores
            for r in range(first_valid_index, len(data)):
                if r <= first_valid_index + 2:
                    smooth0.iloc[r] = data.iloc[r]
                    smooth2.iloc[r] = data.iloc[r]
                    smooth4.iloc[r] = data.iloc[r]
                else:
                    smooth0.iloc[r] = data.iloc[r] + alpha * (smooth0.iloc[r - 1] - data.iloc[r])
                    smooth1.iloc[r] = (data.iloc[r] - smooth0.iloc[r]) * (1 - alpha) + alpha * smooth1.iloc[r - 1]
                    smooth2.iloc[r] = smooth0.iloc[r] + smooth1.iloc[r]
                    smooth3.iloc[r] = (smooth2.iloc[r] - smooth4.iloc[r - 1]) * (1 - alpha)**2 + (alpha**2) * smooth3.iloc[r - 1]
                    smooth4.iloc[r] = smooth3.iloc[r] + smooth4.iloc[r - 1]
                # print(r,smooth0.iloc[r],smooth1.iloc[r],smooth2.iloc[r],smooth3.iloc[r],smooth4.iloc[r])
            # El valor final suavizado es smooth4
            return smooth4.to_numpy()
        return smooth_moving_average
    elif method == 'std' or method == 'stddev':
        return talib.STDDEV
    elif method == 'wilder':
        def wilders_moving_average(data, period):
            """
            Calcula la Wilder's Moving Average para una Serie de pandas.

            :param data: Serie de pandas con los datos para calcular la media móvil (e.g., precios de cierre).
            :param period: El período de la media móvil.
            :return: Serie de pandas con los valores de Wilder's Moving Average.
            """
            data = data.to_numpy()
            n = data.shape[0]
            wilder_ma = np.zeros(n)
            wilder_ma[:2] = data[:2]
            for i in range(2, n):
                wilder_ma[i] = (data[i] - wilder_ma[i - 1]) / period + wilder_ma[i - 1]
            return wilder_ma
        return wilders_moving_average
    elif method == 'smma':
        def smma(data, period):
            """
            Calcula la SMMA para una Serie de pandas.

            :param data: Serie de pandas con los datos para calcular la media móvil (e.g., precios de cierre).
            :param period: El período de la media móvil.
            :return: Serie de pandas con los valores de Wilder's Moving Average.
            """
            if isinstance(data,pd.Series):
                data = data.to_numpy()
            n = data.shape[0]
            _smma =  np.zeros(n)
            # s_mma[:period] = data
            for i in range(period,n):
                _sum = 0
                for j in range(period):
                    _sum+=data[i-j-1]
                _smma[i] = (_sum - _smma[i-1] + data[i])/period
            return _smma
        return smma
    elif method == 'itrend':
        def itrend(data, period):
            """
            Calcula itrend Moving Average para una Serie de pandas.

            :param data: Serie de pandas con los datos para calcular la media móvil (e.g., precios de cierre).
            :param period: El período de la media móvil.
            :return: Serie de pandas con los valores de Wilder's Moving Average.
            """
            if isinstance(data,pd.Series):
                data = data.to_numpy()
            n = data.shape[0]
            alpha = 2/(period+1)
            _itrend =  np.zeros(n)
            for i in range(2,7):
                _itrend[i] = (data[i] + 2*data[i-1] + data[i-2])/4
            for i in range(7,n):
                _itrend[i] = alpha*(1-0.25*alpha)*data[i] + 0.5*np.power(alpha,2)*data[i-1] - alpha*(1 - 0.75*alpha)*data[i-2] + 2*(1-alpha)*_itrend[i-1] - (1-alpha)*(1-alpha)*_itrend[i-2]
            return _itrend
        return itrend
    elif method == 'rema':
        def rema(data, period):
            """
            Calcula REMA Moving Average para una Serie de pandas.

            :param data: Serie de pandas con los datos para calcular la media móvil (e.g., precios de cierre).
            :param period: El período de la media móvil.
            :return: Serie de pandas con los valores de Wilder's Moving Average.
            """
            data = data.to_numpy()
            n = data.shape[0]
            alpha = 2/(period+1)
            _rema =  np.zeros(n)
            _lambda = 0.5
            _rema[:3] = data[:3]            
            for i in range(3,n):    
                _rema[i] = (_rema[i-1]*(1+2*_lambda) + alpha*(data[i] - _rema[i-1]) - _lambda*_rema[i-2])/(1+_lambda)
            return _rema
        return rema
    elif method == 'median':
        def median(data,period):
            """
            Calcula MEDIAN moving average
            """
            if not isinstance(data,pd.Series):
                data = pd.Series(data)
            return data.rolling(period).median().to_numpy()
        return median
    elif method == 'geomean':
        def geomean(data, period):
            """
            Calcula la media geométrica rodante para una serie de precios.

            :param prices: Serie de pandas que contiene los precios.
            :param period: El período sobre el cual calcular la media geométrica rodante.
            :return: Serie de pandas con los valores de la media geométrica rodante.
            """
            if not isinstance(data,pd.Series):
                data = pd.Series(data)
            # Convierte los precios a logaritmos para facilitar el cálculo
            log_prices = np.log(data)
            # Calcula la suma de logaritmos en una ventana rodante
            rolling_sum = log_prices.rolling(window=period).sum()
            # Convierte la suma de logaritmos de vuelta al exponente y divide por el período para obtener la media geométrica
            rolling_geomean = np.exp(rolling_sum / period)
            return rolling_geomean.to_numpy()
        return geomean
    elif method == 'ilrs':
        def ilrs(data, period):
            if isinstance(data,pd.Series):
                data = data.to_numpy()
            sum0 = period*(period-1)/2
            sum2 = (period-1)*period*(2*period-1)/6.0
            n = data.shape[0]
            output = np.zeros(n)
            sma = ma_method(0)(data,period)
            for bar in range(period,n):
                sum1 = 0
                sumy = 0
                for i in range(period):
                    sum1 += i*data[bar-i]
                    sumy += data[bar-i]
                num1 = period*sum1 - sum0*sumy
                num2 = sum0**2 - period*sum2
                slope = 0
                if num2!=0:
                    slope = num1/num2
                output[bar] = slope + sma[bar]
            return output
        return ilrs
    elif method == 'trima2' or method == 'itrima':
        def itrima(data,period):
            if isinstance(data,pd.Series):
                data = data.to_numpy()
            n = data.shape[0]
            length = np.ceil((period+1)/2).astype(int)
            output = np.zeros(n)
            sma = ma_method(0)(data,length)
            for bar in range(length,n):
                sum0 = 0
                for i in range(length):
                    sum0 += sma[bar-i]
                output[bar] = sum0/length
            return output
        return itrima