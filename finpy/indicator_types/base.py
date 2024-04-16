from .utils import ensure_prices_instance_method,calculate_before_signal,calculate_and_inject_prices

class IndicatorMeta(type):
    _registry = {}

    def __new__(metacls, name, bases, class_dict):
        # Aquí es donde aplicamos el decorador si existe el método 'calculate'
        if 'calculate' in class_dict:
            class_dict['calculate'] = ensure_prices_instance_method(class_dict['calculate'])
        
        signal_types = ['entry_signal','exit_signal','baseline_signal']
        for signal_type in signal_types:
            if signal_type in class_dict and callable(class_dict[signal_type]):
                if signal_type == 'baseline_signal':
                    class_dict[signal_type] = calculate_and_inject_prices(class_dict[signal_type])
                else:
                    class_dict[signal_type] = calculate_before_signal(class_dict[signal_type])

        cls = super(IndicatorMeta, metacls).__new__(metacls, name, bases, class_dict)
        if bases != (object,):
            for base in bases:
                if issubclass(base, IndicatorBase) and hasattr(base, 'category'):
                    category = getattr(base, 'category', None)
                    metacls._registry.setdefault(category, set()).add(cls)
        return cls

class IndicatorBase(metaclass=IndicatorMeta):
    
    def calculate(self,*args,**kwargs):
        raise NotImplementedError("calculate needs to be implemented in a subclass or provided by the subclass")