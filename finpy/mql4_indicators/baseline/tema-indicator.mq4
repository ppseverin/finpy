//+------------------------------------------------------------------+
//|                                                       TEMA_RLH   |
//|                                    Copyright © 2006, Robert Hill |
//|                                       http://www.metaquotes.net/ |
//|                                                                  |
//| Based on the formula developed by Patrick Mulloy                 |
//|                                                                  |
//| It can be used in place of EMA or to smooth other indicators.    |
//|                                                                  |
//| TEMA = 3 * EMA - 3 * (EMA of EMA) + EMA of EMA of EMA            |
//|                                                                  |
//|  Red is EMA, Green is EMA of EMA, Yellow is DEMA                 |
//|                                                                  |
//+------------------------------------------------------------------+
#property  copyright ""
#property  link      ""

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 4
#property  indicator_color1  Red
#property  indicator_color2  Green
#property  indicator_color3  Yellow
#property  indicator_color4  Aqua
#property  indicator_width1  1
#property  indicator_width2  1
#property  indicator_width3  1
#property  indicator_width4  2
      
extern int EMA_Period = 14;

//---- buffers
double Ema[];
double EmaOfEma[];
double EmaOfEmaOfEma[];
double Tema[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexDrawBegin(0,EMA_Period);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

//---- 3 indicator buffers mapping
   if(!SetIndexBuffer(0,Ema) &&
      !SetIndexBuffer(1,EmaOfEma) &&
      !SetIndexBuffer(2,EmaOfEmaOfEma) &&
      !SetIndexBuffer(3,Tema))
      Print("cannot set indicator buffers!");
//   if(!SetIndexBuffer(0,Tema) )
//      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("TEMA("+EMA_Period+")");
//---- initialization done
   return(0);
  }

int start()
{
   int i, limit;
   int    counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
  
 
   for(i = limit; i >= 0; i--)
       Ema[i] = iMA(NULL,0,EMA_Period,0,MODE_EMA,PRICE_CLOSE,i);
   for(i = limit; i >=0; i--)
       EmaOfEma[i] = iMAOnArray(Ema,Bars,EMA_Period,0,MODE_EMA,i);
    
   for(i = limit; i >=0; i--)
       EmaOfEmaOfEma[i] = iMAOnArray(EmaOfEma,Bars,EMA_Period,0,MODE_EMA,i);
         
//========== COLOR CODING ===========================================               
        
   for(i = limit; i >=0; i--)
       Tema[i] = 3 * Ema[i] - 3 * EmaOfEma[i] + EmaOfEmaOfEma[i];
       
      return(0);
  }
//+------------------------------------------------------------------+



