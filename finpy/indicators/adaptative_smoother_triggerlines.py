import numpy as np


from finpy.indicator_types.utils import ma_method
from finpy.indicator_types.signal_functions import two_cross_signal,one_over_other
from finpy.indicator_types.categories import EntryIndicator,ExitIndicator,BaselineIndicator

class AdaptativeSmootherTriggerlines(EntryIndicator,ExitIndicator,BaselineIndicator):
    """
    Adaptative Smoother Triggerlines indicator

    Main use:
        - baseline indicator
        
    Secondary use:
        - entry indicator
        - exit indicator

    Typical use:
        - scenario 1:
            - when lsma is greater than lwma and crosses, its buy signal
            - when lsma is smaller than lwma and crosses, its sell signal       
        
    Calculation method:
        - calculate

    Input:
        - OHLC data: market data with open, high, low and close information
        - period: period to make calculations. Default is 50
        - adapt_period: Period to calculate averages. Default is 21
        - price: Price considered for calculations.
            - 0: close
            - 1: open
            - 2: high
            - 3: low
            - 4: median
            - 5: typical
            - 6: weighted
    Output:
        - lsma, lwma
    """
    
    def calculate(self,data,period=50,price=0,adapt_period=21):
        price_used = data.get_price(price)
        stddev = ma_method('std')(data.CLOSE,adapt_period)
        stddev = np.where(stddev!=stddev,0,stddev)
        avg = ma_method(0)(stddev,adapt_period)
        avg = np.where(avg!=avg,0,avg)

        # _period = np.where(stddev!=0.0,(period*avg)/stddev,period)
        _period = np.zeros(avg.shape[0])
        for i,a in enumerate(stddev):
            if a!=0:
                _period[i] = period*avg[i]/a
            else:
                _period[i] = period
        _period = np.where(_period <3,3,_period)
        
        np_price = price_used.to_numpy()
        n = np_price.shape[0]
        lsma = np.zeros(n)
        lwma = np.zeros(n)
        self._work_smooth0 = np.zeros(n)
        self._work_smooth1 = np.zeros(n)
        self._work_smooth2 = np.zeros(n)
        self._work_smooth3 = np.zeros(n)
        self._work_smooth4 = np.zeros(n)
        
        for i in range(1,n):
            lsma[i] = 3*self._ismooth(np_price[i],_period[i],i) - 2*self._ismooth(np_price[i],_period[i],i)
            lwma[i] = lsma[i-1]
        return lsma,lwma
    
    def _ismooth(self,price,length,r):
        if r<=2:
            return price
        alpha = 0.45*(length-1.0)/(0.45*(length-1)+2)
        self._work_smooth0[r] = price+alpha*(self._work_smooth0[r-1]-price)
        self._work_smooth1[r] = (price - self._work_smooth0[r])*(1-alpha)+alpha*self._work_smooth1[r-1]
        self._work_smooth2[r] =  self._work_smooth0[r] + self._work_smooth1[r]
        self._work_smooth3[r] = (self._work_smooth2[r] - self._work_smooth4[r-1])*np.power(1.0-alpha,2) + np.power(alpha,2)*self._work_smooth3[r-1]
        self._work_smooth4[r] =  self._work_smooth3[r] + self._work_smooth4[r-1]
        return self._work_smooth4[r]
    
    def baseline_signal(self,*args,**kwargs):
        lsma,lwma = self._last_calculate_result
        print(self._last_calculate_args)
        price = self._last_calculate_kwargs['data']
        return two_cross_signal(price.CLOSE,lsma)
    
    def baseline_over_price(self, *args, **kwargs):
        lsma,lwma = self._last_calculate_result
        price = self._last_calculate_kwargs['data']
        return two_cross_signal(price.CLOSE,lsma)
    
    def entry_signal(self, *args, **kwargs):
        lsma,lwma = self._last_calculate_result
        if self.main_confirmation_indicator:
            return two_cross_signal(lsma,lwma)
        return one_over_other(lsma,lwma)
    
    def exit_signal(self, *args, **kwargs):
        lsma,lwma = self._last_calculate_result
        return two_cross_signal(lsma,lwma,bos_signal=False)
        