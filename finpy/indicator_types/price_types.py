import talib
import numpy as np
import pandas as pd

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

class HeikenAshiPrices():
    def __init__(self,prices):
        self._ha_prices = calculate_heikin_ashi(prices)

    @property
    def HA_CLOSE(self):
        return self._ha_prices.close
    @property
    def HA_OPEN(self):
        return self._ha_prices.open
    @property
    def HA_HIGH(self):
        return self._ha_prices.high
    @property
    def HA_LOW(self):
        return self._ha_prices.low
    @property
    def HA_MEDIAN(self):
        return talib.MEDPRICE(self.HA_HIGH, self.HA_LOW)
    @property
    def HA_TYPICAL(self):
        return talib.TYPPRICE(self.HA_HIGH, self.HA_LOW, self.HA_CLOSE)
    @property
    def HA_WEIGHTED(self):
        return talib.WCLPRICE(self.HA_HIGH,self.HA_LOW,self.HA_CLOSE)
    @property
    def HA_AVERAGE(self):
        return talib.AVGPRICE(self.HA_OPEN,self.HA_HIGH,self.HA_LOW,self.HA_CLOSE)
    @property
    def HA_AVERAGE_MEDIAN_BODY(self):
        return (self.OPEN+self.CLOSE)/2
    @property
    def HA_TREND_BIASED(self):
        return np.where(self.HA_CLOSE>self.HA_OPEN,(self.HA_HIGH+self.HA_CLOSE)/2,(self.HA_LOW+self.HA_CLOSE)/2)
    @property
    def HA_TREND_BIASED_EXTREME(self):
        return np.where(self.HA_CLOSE>self.HA_OPEN,self.HA_HIGH,np.where(self.HA_CLOSE<self.HA_OPEN,self.HA_LOW,self.HA_CLOSE))
    
class Prices(HeikenAshiPrices):
    def __init__(self,data,test_index = None):
        data.columns = data.columns.str.replace(' ','_').str.lower()
        self.data = data
        if test_index:
            test_index = abs(test_index)
            self.data = data.iloc[-test_index:].reset_index(drop=True)
        super().__init__(self.data)
    
    @property
    def shape(self):
        return self.data.shape
    
    @property
    def CLOSE(self):
        return self.data.close
    @property
    def OPEN(self):
        return self.data.open
    @property
    def HIGH(self):
        return self.data.high
    @property
    def LOW(self):
        return self.data.low
    @property
    def MEDIAN(self):
        return talib.MEDPRICE(self.HIGH, self.LOW)
    @property
    def TYPICAL(self):
        return talib.TYPPRICE(self.HIGH, self.LOW, self.CLOSE)
    @property
    def WEIGHTED(self):
        return talib.WCLPRICE(self.HIGH,self.LOW,self.CLOSE)
    @property
    def AVERAGE(self):
        return talib.AVGPRICE(self.OPEN,self.HIGH,self.LOW,self.CLOSE)
    @property
    def AVERAGE_MEDIAN_BODY(self):
        return (self.OPEN+self.CLOSE)/2
    @property
    def TREND_BIASED(self):
        return np.where(self.CLOSE>self.OPEN,(self.HIGH+self.CLOSE)/2,(self.LOW+self.CLOSE)/2)
    @property
    def TREND_BIASED_EXTREME(self):
        return np.where(self.CLOSE>self.OPEN,self.HIGH,np.where(self.CLOSE<self.OPEN,self.LOW,self.CLOSE))
    @property
    def TICK_VOLUME(self):
        return self.data.tick_volume

    def _get_price_translator(self, price_type):
        price_types = {
            0: 'CLOSE',
            1: 'OPEN',
            2: 'HIGH',
            3: 'LOW',
            4: 'MEDIAN',
            5: 'TYPICAL',
            6: 'WEIGHTED',
            7: 'AVERAGE',
            8: 'AVERAGE_MEDIAN_BODY',
            9: 'TREND_BIASED',
            10: 'TREND_BIASED_EXTREME'
        }
        if price_type in range(11, 22):
            base_price_type = price_types[price_type - 11]
            return f'HA_{base_price_type}'
        return price_types.get(price_type, None)
    
    def get_price(self, price_type):
        if isinstance(price_type,str):
            translated_price = price_type.upper().replace(' ','_')
        else:
            translated_price = self._get_price_translator(price_type)
        if translated_price:
            return getattr(self, translated_price, None)
        else:
            raise ValueError(f"Price type {price_type} is not recognized.")