from .base import IndicatorMeta

class IndicatorTypes:
    
    @classmethod
    def _initialize(cls):
        cls.entry = IndicatorMeta._registry.get('entry', set())
        cls.exit = IndicatorMeta._registry.get('exit', set())
        cls.baseline = IndicatorMeta._registry.get('baseline', set())