import numpy as np

from finpy.indicator_types.categories import EntryIndicator,ExitIndicator

class TrendContinuation(EntryIndicator,ExitIndicator):
    def trend_continuation(self,data, n=20, t3_period=5, b=0.618, count_bars=5000):
        b2 = b * b
        b3 = b2 * b
        c1 = -b3
        c2 = 3 * (b2 + b3)
        c3 = -3 * (2 * b2 + b + b3)
        c4 = 1 + 3 * b + b3 + 3 * b2
        n1 = t3_period
        n1 = 1+0.5*(n1-1)
        w1 = 2 / (n1 + 1)
        w2 = 1 - w1

        close = data['close']
        buy_buffer = np.zeros_like(close)
        sell_buffer = np.zeros_like(close)

        e1, e2, e3, e4, e5, e6 = 0,0,0,0,0,0
        
        e11, e22, e33, e44, e55, e66 = 0,0,0,0,0,0
        
        Change_p = np.zeros_like(close)
        Change_n = np.zeros_like(close)
        
        CF_p = np.zeros_like(close)
        CF_n = np.zeros_like(close)
        
        Bars = close.shape[0] #cantidad de barras
        
        start_index = max(Bars - count_bars,n)
        
        for i in range(start_index, Bars):
            ch_p = ch_n = cff_p = cff_n = 0
            if close[i] > close[i-1]:
                Change_p[i] = close[i] - close[i-1]
                CF_p[i] = Change_p[i] + CF_p[i-1]
            
            else:
                Change_n[i]  = close[i-1] - close[i]
                CF_n[i] = Change_n[i] + CF_n[i-1]
            
            for j in range(i-n,i+1):
                ch_p = Change_p[j] + ch_p
                ch_n = Change_n[j]+ ch_n 
                cff_p =  CF_p[j] + cff_p
                cff_n =  CF_n[j] + cff_n
            
            k_p = ch_p - cff_n
            k_n = ch_n - cff_p

            if i > 0:
                buy_buffer[i], e1, e2, e3, e4, e5, e6 = self._calculate_t3(k_p, w1, w2, c1, c2, c3, c4, e1, e2, e3, e4, e5, e6)
                sell_buffer[i], e11, e22, e33, e44, e55, e66 = self._calculate_t3(k_n, w1, w2, c1, c2, c3, c4, e11, e22, e33, e44, e55, e66)        
        return buy_buffer, sell_buffer

    def _calculate_t3(self,value, w1, w2, c1, c2, c3, c4, e1_prev, e2_prev, e3_prev, e4_prev, e5_prev, e6_prev):
        e1 = w1 * value + w2 * e1_prev
        e2 = w1 * e1 + w2 * e2_prev
        e3 = w1 * e2 + w2 * e3_prev
        e4 = w1 * e3 + w2 * e4_prev
        e5 = w1 * e4 + w2 * e5_prev
        e6 = w1 * e5 + w2 * e6_prev
        t3 = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3
        return t3, e1, e2, e3, e4, e5, e6