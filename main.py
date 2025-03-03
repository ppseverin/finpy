import pandas as pd

from finpy.indicator_types.price_types import Prices
from finpy.indicator_types.indicator_types import IndicatorTypes

from finpy import TradeWithTrend,DSS_Bressert,MegaTrend,AllMovingAverages,AdaptativeSmootherTriggerlines

def test(indicator,prices):
    ind = indicator()
    res = pd.DataFrame()
    calculate = ind.calculate(prices)
    for i,val in enumerate(calculate):
        res[i] = val
    return res

def baseline_signal(indicator,prices):
    ind = indicator()
    baseline = ind.baseline_signal(prices)
    return pd.DataFrame(baseline)

if __name__ == "__main__":
    data = '/mnt/c/Users/ppsev/Downloads/Forex/eurusd/m15/EURUSD_GMT+0_NO-DST-04052003_28122023_M15.csv'

    dataset = pd.read_csv(data)
    dataset.columns = dataset.columns.str.replace(' ','_').str.lower()

    prices = Prices(dataset,387)
    entry_indicators = IndicatorTypes.entry
    # print("Entry Indicators:", [indicator.__name__ for indicator in IndicatorTypes.entry ],end='\n\n')
    # print("Exit Indicators:", [indicator.__name__ for indicator in IndicatorTypes.exit],end='\n\n')
    print("Baseline Indicators:", [indicator.__name__ for indicator in IndicatorTypes.baseline],end='\n\n')
    
    # res = test(TradeWithTrend,prices)
    res = baseline_signal(AdaptativeSmootherTriggerlines,prices)
    # ast = MegaTrend()
    # res = pd.DataFrame()
    # signal = ast.entry_signal(prices)
    # res['main_signal'] = signal
    # ast.set_as_secondary_confirmation_indicator()
    # signal = ast.entry_signal(prices)
    # res['second_signal'] = signal
    # # print(signal)
    # # res['value'] = signal[0]
    # signal = ast.exit_signal()
    # # print(signal)
    # res['exit'] = signal
    # # print(res.iloc[-50:])
    # # signal = ast.baseline_signal()
    print(res)