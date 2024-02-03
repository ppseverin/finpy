class IndicatorMeta(type):
    _registry = {}

    def __new__(metacls, name, bases, class_dict):
        cls = super(IndicatorMeta, metacls).__new__(metacls, name, bases, class_dict)
        if bases != (object,):
            # category = class_dict.get('category') or next((getattr(base, 'category', None) for base in bases if hasattr(base, 'category')), None)
            for base in bases:
                # print(base,name,issubclass(base, IndicatorBase),hasattr(base, 'category'))
                if issubclass(base, IndicatorBase) and hasattr(base, 'category'):
                    category = getattr(base, 'category', None)
                    # print(base,name,category,cls)
                    metacls._registry.setdefault(category, set()).add(cls)
                    # print(metacls._registry)
            # if category:
            #     # print(type(category))
            #     metacls._registry.setdefault(category, set()).add(cls)
            #     print(metacls._registry)
        return cls

class IndicatorBase(metaclass=IndicatorMeta):
    pass