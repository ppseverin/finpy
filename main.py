from finpy.indicator_types.indicator_types import IndicatorTypes


if __name__ == "__main__":
    
    entry_indicators = IndicatorTypes.entry
    entry_indicators = [indicator for indicator in entry_indicators if indicator.__name__ == 'BullsVsBears'][0]
    print("Entry Indicators:", [indicator.__name__ for indicator in IndicatorTypes.entry ])
    print("Exit Indicators:", [indicator.__name__ for indicator in IndicatorTypes.exit])
    print(entry_indicators)