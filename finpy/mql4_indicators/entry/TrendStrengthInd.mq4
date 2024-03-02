//+------------------------------------------------------------------+
//|                                                      Awesome.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Trend Strength"
#property strict

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Black
#property  indicator_color2  Lime
#property  indicator_color3  Red
#property  indicator_color4  Yellow
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
//--- indicator parameters
input double         rate=0.0001;           // Tolerance
input int            MA_PERIOD=5;           // Period
input ENUM_MA_METHOD InpMAMethod=MODE_SMA;  // Method
//--- buffers
double     ExtAOBuffer[];
double     ExtUpBuffer[];
double     ExtDnBuffer[];
double     ExtFlBuffer[];
//---
#define PERIOD_FAST  5
#define PERIOD_SLOW 34
//--- bars minimum for calculation
#define DATA_LIMIT  34
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
//--- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   IndicatorDigits(Digits+1);
   SetIndexDrawBegin(0,DATA_LIMIT);
   SetIndexDrawBegin(1,DATA_LIMIT);
   SetIndexDrawBegin(2,DATA_LIMIT);
   SetIndexDrawBegin(3,DATA_LIMIT);
//--- 3 indicator buffers mapping
   SetIndexBuffer(0,ExtAOBuffer);
   SetIndexBuffer(1,ExtUpBuffer);
   SetIndexBuffer(2,ExtDnBuffer);
   SetIndexBuffer(3,ExtFlBuffer);
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("TrendStrength");
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
  }
//+------------------------------------------------------------------+
//| Awesome Oscillator                                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int    i,limit=rates_total-prev_calculated,trend=0;
   double prev=0.0,current,ratio;
//--- check for rates total
   if(rates_total<=DATA_LIMIT)
      return(0);
//--- last counted bar will be recounted
   if(prev_calculated>0)
     {
      limit++;
      prev=ExtAOBuffer[limit];
     }
//--- macd
   for(i=0; i<limit; i++)
      ExtAOBuffer[i]=iMA(NULL,0,MA_PERIOD,0,MODE_SMA,PRICE_MEDIAN,i);
//--- dispatch values between 2 buffers
   for(i=limit-1; i>=0; i--)
     {
      current=ExtAOBuffer[i];
      if (prev>0) ratio=current/prev;
      if (ratio>1+rate) trend=1;
      if (ratio<1-rate) trend=0;
      if (ratio>=1-rate && ratio<=1+rate) trend=2;
      if (trend==0)
        {
         ExtDnBuffer[i]=current;
         ExtUpBuffer[i]=0.0;
         ExtFlBuffer[i]=0.0;
        }
      if (trend==1)
        {
         ExtUpBuffer[i]=current;
         ExtDnBuffer[i]=0.0;
         ExtFlBuffer[i]=0.0;
        }
      if (trend==2)
        {
         ExtFlBuffer[i]=current;
         ExtUpBuffer[i]=0.0;
         ExtDnBuffer[i]=0.0;
        }
      prev=current;
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
