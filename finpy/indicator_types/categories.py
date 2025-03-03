from .base import IndicatorBase

class EntryIndicator(IndicatorBase):
    category = 'entry'
    base = True
    main_confirmation_indicator = True
    
    def entry_signal(self,*args,**kwargs):
        """
        Método genérico para obtener una señal del indicador (compra, venta, neutral).
        """
        raise NotImplementedError("entry_signal needs to be implemented as a subclass")
    
    def set_as_secondary_confirmation_indicator(self):
        self.main_confirmation_indicator = False

class ExitIndicator(IndicatorBase):
    category = 'exit'
    base = True

    def exit_signal(self,*args,**kwargs):
        """
        Método genérico para obtener una señal del indicador (compra, venta, neutral).
        """
        raise NotImplementedError("exit_signal needs to be implemented as a subclass")

class BaselineIndicator(IndicatorBase):
    category = 'baseline'
    base = True

    def baseline_signal(self,*args,**kwargs):
        """
        Método genérico para obtener una señal del indicador (compra, venta, neutral).
        """
        raise NotImplementedError("baseline_signal needs to be implemented as a subclass")
    
    def baseline_over_price(self,*args,**kwargs):
        """
        Método genérico para obtener una señal del indicador (compra, venta, neutral).
        """
        raise NotImplementedError("baseline_signal needs to be implemented as a subclass")