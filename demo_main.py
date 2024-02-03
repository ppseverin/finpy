class IndicatorMeta(type):
    _registry = {}

    def __new__(metacls, name, bases, class_dict):
        cls = super(IndicatorMeta, metacls).__new__(metacls, name, bases, class_dict)
        if bases != (object,):
            category = class_dict.get('category') or next((getattr(base, 'category', None) for base in bases if hasattr(base, 'category')), None)
            if category:
                metacls._registry.setdefault(category, set()).add(cls)
        return cls

class IndicatorBase(metaclass=IndicatorMeta):
    pass

class EntryIndicator(IndicatorBase):
    category = 'entry'

class ExitIndicator(IndicatorBase):
    category = 'exit'

# ... otras clases de indicadores

class IndicatorTypes:
    entry = IndicatorMeta._registry.get('entry', set())
    exit = IndicatorMeta._registry.get('exit', set())
    baseline = IndicatorMeta._registry.get('baseline', set())

class AroonIndicator(EntryIndicator):
    pass

# print(AroonIndicator.category)
# Ejemplo de uso
if __name__ == "__main__":
    # Definición de un indicador para probar
    

    entry_indicators = IndicatorTypes.entry
    print("Entry Indicators:", [indicator.__name__ for indicator in entry_indicators])
