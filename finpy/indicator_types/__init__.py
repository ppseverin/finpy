from .base import IndicatorBase, IndicatorMeta
from .categories import EntryIndicator, ExitIndicator
from .indicator_types import IndicatorTypes


# ...otros imports según sea necesario


# from enum import Enum

# class IndicatorType():
#     ENTRY = 0
#     BASELINE = 1
#     VOLUME = 2
#     EXIT = 3

# class IndicatorTypes:
#     _entry_indicators = ["IndicadorEntrada1", "IndicadorEntrada2", "IndicadorEntrada3","IndicadorBase1"]
#     _exit_indicators = ["IndicadorSalida1", "IndicadorSalida2","IndicadorEntrada1"]
#     _baseline_indicators = ["IndicadorBase1", "IndicadorBase2"]
#     _volume_indicators = ["IndicadorVolumen1", "IndicadorVolumen2"]
#     _all_types = _entry_indicators + _exit_indicators + _baseline_indicators + _volume_indicators

#     @property
#     def entry(self):
#         return self._entry_indicators
    
#     @property
#     def only_entry(self):
#         return [indicator for indicator in self._entry_indicators if self._all_types.count(indicator)==1]

#     @property
#     def exit(self):
#         return self._exit_indicators
    
#     @property
#     def only_exit(self):
#         return [indicator for indicator in self._exit_indicators if self._all_types.count(indicator)==1]

#     @property
#     def baseline(self):
#         return self._baseline_indicators
    
#     @property
#     def only_baseline(self):
#         return [indicator for indicator in self._baseline_indicators if self._all_types.count(indicator)==1]

#     @property
#     def volume(self):
#         return self._volume_indicators
    
#     @property
#     def only_volume(self):
#         return [indicator for indicator in self._volume_indicators if self._all_types.count(indicator)==1]


# class AvailableIndicators:
#     all_indicators = {
#         IndicatorType.ENTRY: ["IndicadorA", "IndicadorB", "IndicadorC"],
#         IndicatorType.EXIT: ["IndicadorD", "IndicadorE"],
#         IndicatorType.VOLUME: ["IndicadorF"],
#         IndicatorType.BASELINE: ["IndicadorG"]
#     }

#     @classmethod
#     def get_indicators_by_type(cls, indicator_type):
#         return cls.all_indicators.get(indicator_type, [])
    
#     @classmethod
#     def get_exclusive_indicators_by_type(cls, indicator_type):
#         exclusive_indicators = []
#         for type, indicators in cls.all_indicators.items():
#             if type == indicator_type:
#                 exclusive_indicators.extend(indicators)
#             else:
#                 for indicator in indicators:
#                     if indicator in exclusive_indicators:
#                         exclusive_indicators.remove(indicator)
#         return exclusive_indicators

# class Indicator():
#     def __init__(self,name):
#         self.name = name
    
#     def calculate(self):
#         raise NotImplemented('Esta funcionalidad debe ser implementada en el indicador')

