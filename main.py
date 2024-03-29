from finpy.indicator_types.indicator_types import IndicatorTypes


if __name__ == "__main__":
    
    entry_indicators = IndicatorTypes.entry
    print("Entry Indicators:", [indicator.__name__ for indicator in IndicatorTypes.entry ])
    print("Exit Indicators:", [indicator.__name__ for indicator in IndicatorTypes.exit])
    print("Baseline Indicators:", [indicator.__name__ for indicator in IndicatorTypes.baseline])
    