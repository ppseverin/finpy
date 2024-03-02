//+------------------------------------------------------------------+
//|                                                      TEMA_CUSTOM |
//|                                      Copyright 2015, SergeyVrady |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Sergey Vrady"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow
#property indicator_width1  2
//---
input int                MAPeriod=8;
input ENUM_MA_METHOD     MAMethod=MODE_EMA;
input ENUM_APPLIED_PRICE MAPrice=PRICE_MEDIAN;
//---
double TemaBuffer[];
double Ema[];
double EmaOfEma[];
double EmaOfEmaOfEma[];
//+------------------------------------------------------------------+
//|            Initialization and input parameters                   |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TemaBuffer);
   SetIndexBuffer(1,Ema);
   SetIndexBuffer(2,EmaOfEma);
   SetIndexBuffer(3,EmaOfEmaOfEma);
//---
   IndicatorShortName("TEMA("+MAPeriod+")");
//---
   string short_name;
   int    draw_begin=MAPeriod-1;
//---
   switch(MAPrice)
     {
      case PRICE_CLOSE  : short_name="CLOSE(";                break;
      case PRICE_OPEN  : short_name="OPEN(";  draw_begin=0;   break;
      case PRICE_HIGH : short_name="HIGH(";                   break;
      case PRICE_LOW : short_name="LOW(";                     break;
      case PRICE_MEDIAN : short_name="MEDIAN(";               break;
      case PRICE_TYPICAL : short_name="TYPICAL(";             break;
      case PRICE_WEIGHTED : short_name="WEIGHTED(";           break;
      default :        return(INIT_FAILED);
     }
//---
   switch(MAMethod)
     {
      case MODE_SMA  : short_name="SMA(";                break;
      case MODE_EMA  : short_name="EMA(";  draw_begin=0; break;
      case MODE_SMMA : short_name="SMMA(";               break;
      case MODE_LWMA : short_name="LWMA(";               break;
      default :        return(INIT_FAILED);
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
//---
   return(0);
  }
//+------------------------------------------------------------------+
//|                    Calculation section                           |
//+------------------------------------------------------------------+
int start()
  {
   int i,limit,limit2,limit3,counted_bars=IndicatorCounted();
//---
   if(counted_bars==0)
     {
      limit=Bars-1;
      limit2=limit-MAPeriod;
      limit3=limit2-MAPeriod;
     }
   if(counted_bars>0)
     {
      limit=Bars-counted_bars-1;
      limit2=limit;
      limit3=limit2;
     }
//---
   for(i=limit;i>=0;i--) Ema[i]=iMA(NULL,0,MAPeriod,0,MAMethod,MAPrice,i);
   for(i=limit2;i>=0;i--) EmaOfEma[i]=iMAOnArray(Ema,0,MAPeriod,0,MAMethod,i);
   for(i=limit3;i>=0;i--) EmaOfEmaOfEma[i]=iMAOnArray(EmaOfEma,0,MAPeriod,0,MODE_EMA,i);
   for(i=limit3;i>=0;i--) TemaBuffer[i]=3*Ema[i]-3*EmaOfEma[i]+EmaOfEmaOfEma[i];
//---
   return(0);
  }
//+------------------------------------------------------------------+
