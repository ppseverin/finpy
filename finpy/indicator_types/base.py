class IndicatorMeta(type):
    _registry = {}

    def __new__(metacls, name, bases, class_dict):
        cls = super(IndicatorMeta, metacls).__new__(metacls, name, bases, class_dict)
        if bases != (object,):
            for base in bases:
                if issubclass(base, IndicatorBase) and hasattr(base, 'category'):
                    category = getattr(base, 'category', None)
                    metacls._registry.setdefault(category, set()).add(cls)
        return cls

class IndicatorBase(metaclass=IndicatorMeta):
    pass