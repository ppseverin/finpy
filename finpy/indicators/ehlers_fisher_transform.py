import numpy as np

from finpy.indicator_types.utils import get_price
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class EhlersFisherTransform(EntryIndicator,ExitIndicator):
    def ehlers_fisher_transform(self,data, period=10, weight=2, signal_period=9, price_type='median'):
        # Inicialización de buffers
        fisher = np.zeros(len(data))
        trigger = np.zeros(len(data))
        prices = get_price(data, price_type)

        alpha = 2.0 / (1 + weight)
        ema = 2.0 / (1 + signal_period)

        for i in range(period, len(data)):
            max_high = np.max(prices[i-period:i])
            min_low = np.min(prices[i-period:i])
            value = alpha * ((2 * (prices[i] - min_low) / (max_high - min_low)) - 1) if max_high != min_low else 0
            value = np.clip(value, -0.999, 0.999)
            
            fisher[i] = 0.5 * np.log((1 + value) / (1 - value)) if value < 0.999 and value > -0.999 else 0
            if i > 0:
                fisher[i] += 0.5 * fisher[i-1]
            
            if i > 1:
                trigger[i] = trigger[i-1] + ema * (fisher[i] - trigger[i-1])

        return fisher, trigger