//+------------------------------------------------------------------+
//|                                                         ARSI.mq4 |
//|                                     Copyright ?2009, Walter Choy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2009, Walter Choy"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue

//---- input parameters
extern int       period = 9;
extern int       histper = 30;

double VIDYA[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,VIDYA);
   SetIndexLabel(0, "VIDYA");
   SetIndexDrawBegin(0, histper);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int    i;
   double sc, k;
//----
   i = Bars - counted_bars;
   
   while (i>0){
      if (i < Bars - histper)
      {
         k =  iStdDev(NULL, 0, period, 0, MODE_SMA, PRICE_CLOSE, i) / iStdDev(NULL, 0, histper, 0, MODE_SMA, PRICE_CLOSE, i);
         sc = (2.0 / (period + 1));
         VIDYA[i] = k * sc * Close[i] + (1 - k * sc) * VIDYA[i+1];
      } else {
         VIDYA[i] = Close[i];
      }
      i--;
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+