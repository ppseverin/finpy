//+------------------------------------------------------------------+
//|                                                        Bulls.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "BullsVsBears Power"
#property strict

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_color2 Red

//--- input parameter
input int InpPeriod=13;
//--- buffers
double ExtBullsBuffer[];
double ExtBearsBuffer[];
double ExtTempBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
   string short_name;
//--- 1 additional buffer used for counting.
   IndicatorBuffers(3);
   IndicatorDigits(Digits);
//--- indicator line
   SetIndexStyle(0,DRAW_LINE, STYLE_SOLID);
   SetIndexStyle(1,DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(0,ExtBullsBuffer);
   SetIndexBuffer(1,ExtBearsBuffer);
   SetIndexBuffer(2,ExtTempBuffer);
//--- name for DataWindow and indicator subwindow label
   short_name="BullsVsBears("+IntegerToString(InpPeriod)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Bulls");
   SetIndexLabel(1,"Bears");
  }
//+------------------------------------------------------------------+
//| Bulls Power                                                      |
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
   int limit=rates_total-prev_calculated;
//---
   if(rates_total<=InpPeriod)
      return(0);
//---
   if(prev_calculated>0)
      limit++;
   for(int i=0; i<limit; i++)
     {
      ExtTempBuffer[i]=iMA(NULL,0,InpPeriod,0,MODE_EMA,PRICE_CLOSE,i);
      ExtBullsBuffer[i]=high[i]-ExtTempBuffer[i];
      ExtBearsBuffer[i]=ExtTempBuffer[i]-low[i];
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
