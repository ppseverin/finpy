import numpy as np
import pandas as pd


def _convert_to_numpy(func):
    # @wraps(func)
    def wrapper(*args, **kwargs):
        # Convierte todos los argumentos posicionales que sean pandas Series a Numpy arrays
        new_args = [arg.to_numpy() if isinstance(arg, pd.Series) else arg for arg in args]
        
        # Haz lo mismo con los argumentos con palabra clave
        new_kwargs = {k: v.to_numpy() if isinstance(v, pd.Series) else v for k, v in kwargs.items()}
        
        # Llama a la función original con los nuevos argumentos convertidos
        return func(*new_args, **new_kwargs)
    return wrapper

@_convert_to_numpy
def two_cross_signal(buy_buffer_info,sell_buffer_info,bos_signal=True):
    """
    Analyze if two buffers crosses

    Input:
        - buy_buffer_info: numpy array with data
        - sell_buffer_info: numpy array with data
        - bos_signal: True to generate buy or sell signals. False to just point where the crossover happens. Default is True
    
    Returns:
        - if bos_signal is True, then returns signal array with 1 when its a buy signal and -1 if its a sell signal
        - if bos_signal is False, then returns signal array with 1 when both buffers crosses
    """
    neg_signal = 1
    if bos_signal:
        neg_signal = -1

    signal = np.zeros(buy_buffer_info.shape[0])
    
    signal[1:] = np.where((buy_buffer_info[1:]>sell_buffer_info[1:]) & (buy_buffer_info[:-1]<sell_buffer_info[:-1]),1,np.where((buy_buffer_info[1:]<sell_buffer_info[1:]) & (buy_buffer_info[:-1]>sell_buffer_info[:-1]),neg_signal,0))
    return signal

@_convert_to_numpy
def zero_cross_signal(buffer,bos_signal=True):
    neg_signal = 1
    if bos_signal:
        neg_signal = -1
    # buffer = _convert_to_numpy(buffer)
    signal = np.zeros(buffer.shape[0])
    signal[1:] = np.where((buffer[1:]>signal[1:]) & (buffer[:-1]<signal[:-1]),1,np.where((buffer[1:]<signal[1:]) & (buffer[:-1]>signal[:-1]),neg_signal,0))
    return signal

@_convert_to_numpy
def one_over_other(buy_buffer,sell_buffer=0):
    if isinstance(sell_buffer,int) and sell_buffer==0:
        sell_buffer = np.zeros(buy_buffer.shape[0])
    signal = np.where(buy_buffer>sell_buffer,1,np.where(buy_buffer<sell_buffer,-1,0))
    return signal