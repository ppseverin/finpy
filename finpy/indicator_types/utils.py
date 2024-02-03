import talib
import numpy as np
import pandas as pd

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

def get_price(data, price_type):
    """
    Calcula el precio especificado utilizando TA-Lib.

    :param data: DataFrame de Pandas con las columnas 'high', 'low', 'close', 'open'.
    :param price_type: Tipo de precio a calcular ('median', 'close', 'high', 'low', etc.).
    :return: Serie de Pandas con el precio calculado.
    """
    if price_type.lower() == 'median':
        return talib.MEDPRICE(data['high'], data['low'])
    elif price_type.lower() == 'close':
        return data['close']
    elif price_type.lower() == 'high':
        return data['high']
    elif price_type.lower() == 'low':
        return data['low']
    elif price_type.lower() == 'open':
        return data['open']
    elif price_type.lower() == 'typical':
        return talib.TYPPRICE(data['high'], data['low'], data['close'])
    elif price_type.lower() == 'weighted':
        return talib.WCLPRICE(data['high'], data['low'], data['close'])
    else:
        raise ValueError("Tipo de precio no reconocido.")