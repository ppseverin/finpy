//+------------------------------------------------------------------+
//|                                                     TSI_MACD.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_maximum 110
#property indicator_minimum -110
#property indicator_level1 0
//---- input parameters
extern int Fast = 8;
extern int Slow = 21;
extern int Signal = 5;
extern int First_R = 8;
extern int Second_S = 5;
extern int SignalPeriod = 5;
extern int Mode_Smooth = 2;
//---- buffers
double TSI_Buffer[];
double SignalBuffer[];
double MTM_Buffer[];
double EMA_MTM_Buffer[];
double EMA2_MTM_Buffer[];
double ABSMTM_Buffer[];
double EMA_ABSMTM_Buffer[];
double EMA2_ABSMTM_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexBuffer(2, MTM_Buffer);
   SetIndexBuffer(3, EMA_MTM_Buffer);
   SetIndexBuffer(4, EMA2_MTM_Buffer);
   SetIndexBuffer(5, ABSMTM_Buffer);
   SetIndexBuffer(6, EMA_ABSMTM_Buffer);
   SetIndexBuffer(7, EMA2_ABSMTM_Buffer);
//----
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, TSI_Buffer);
   SetIndexLabel(0, "TSI_MACD");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, SignalBuffer);
   SetIndexLabel(1, "Signal");
   IndicatorShortName("TSI_MACD(" + Fast + ", " + Slow + ", " + Signal + "; " + 
                      First_R + ", " + Second_S + ", " + SignalPeriod + ")");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted(); 
   int limit, i;
   limit = Bars - counted_bars - 1;
//----
   for(i = Bars - 1; i >= 0; i--)
     {
       MTM_Buffer[i] = iMACD(NULL, 0, Fast, Slow, Signal, PRICE_CLOSE, MODE_MAIN, i - 1) - 
                       iMACD(NULL, 0, Fast, Slow, Signal, PRICE_CLOSE, MODE_MAIN, i);
       ABSMTM_Buffer[i] = MathAbs(MTM_Buffer[i]);
       Print(iMACD(NULL, 0, Fast, Slow, Signal, PRICE_CLOSE, MODE_MAIN, i - 1)," - ",iMACD(NULL, 0, Fast, Slow, Signal, PRICE_CLOSE, MODE_MAIN, i));
     }
     Print(MTM_Buffer[0]," ",ABSMTM_Buffer[Bars-1]);
//----
   for(i=Bars-1;i>=0;i--)
     {
       EMA_MTM_Buffer[i] = iMAOnArray(MTM_Buffer, 0, First_R, 0, MODE_EMA, i);
       EMA_ABSMTM_Buffer[i] = iMAOnArray(ABSMTM_Buffer, 0, First_R, 0, MODE_EMA, i);
     }
//----
   for(i = Bars - 1; i >= 0; i--)
     {
       EMA2_MTM_Buffer[i] = iMAOnArray(EMA_MTM_Buffer, 0, Second_S, 0, MODE_EMA, i);
       EMA2_ABSMTM_Buffer[i] = iMAOnArray(EMA_ABSMTM_Buffer, 0, Second_S, 0, MODE_EMA, i);
     }
//----
   for(i = limit; i >= 0; i--)
       TSI_Buffer[i] = 100.0*EMA2_MTM_Buffer[i] / EMA2_ABSMTM_Buffer[i];
//----
   for(i = limit; i >= 0; i--)
     {
       SignalBuffer[i] = iMAOnArray(TSI_Buffer, 0, SignalPeriod, 0, Mode_Smooth, i);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+