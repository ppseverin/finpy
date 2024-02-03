from .base import IndicatorBase

class EntryIndicator(IndicatorBase):
    category = 'entry'
    base = True

class ExitIndicator(IndicatorBase):
    category = 'exit'
    base = True

class BaselineIndicator(IndicatorBase):
    category = 'baseline'
    base = True
