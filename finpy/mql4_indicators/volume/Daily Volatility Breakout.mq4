//+------------------------------------------------------------------+
//|                                             70/50VolBreakout.mq4 |
//|                                                        Keris2112 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Keris2112"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Red

extern int  EntryPercent = 70;
extern int  StopPercent = 50;
int i=1, shift;

double   PrevRange;
double   LongEntry;
double   LongStop;
double   ShortEntry;
double   ShortStop;
bool result;
//---- buffers

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];


bool isNewDay(int _shift)
  {
//---- 
   result=false;
   if (  (TimeHour(Time[_shift])==0)  && (TimeMinute(Time[_shift])==0)   ) result=true;

//----
   return(result);
  }

void GetRS1ofDay(int _shift)
  {
  int prevDay=TimeDay(Time[_shift+1]);
//---- 
   i=1;
   while (TimeDay(Time[_shift+i])==prevDay) i++;
   i--;
   
   PrevRange=High[Highest(NULL,0,MODE_HIGH,i,_shift+1)] - Low[Lowest(NULL,0,MODE_LOW,i,_shift+1)];
   LongEntry =  Open[_shift] + (PrevRange * (EntryPercent*0.01));
   LongStop = LongEntry - (PrevRange * (StopPercent*0.01));
   ShortEntry = Open[_shift] - (PrevRange * (EntryPercent*0.01));
   ShortStop = ShortEntry + (PrevRange * (StopPercent*0.01));
   
   
   ExtMapBuffer1[_shift] = LongEntry;
   ExtMapBuffer2[_shift] = LongStop;
   ExtMapBuffer3[_shift] = ShortEntry;
   ExtMapBuffer4[_shift] = ShortStop;
   
   Comment(
      "Previous Range:  ",PrevRange*1/Point," pips",
      "\n",(EntryPercent),"% of Previous Range:  ",MathRound((EntryPercent*PrevRange*(0.01/Point)))," pips",
      "\n",(StopPercent),"% of Previous Range:  ",MathRound((StopPercent*PrevRange*(0.01/Point)))," pips",
      "\nOpen:  ",Open[_shift],
      "\nEnter BuyStop at:  ",ExtMapBuffer1[_shift]," with StopLoss at:  ",ExtMapBuffer2[_shift],
      "\nEnter SellStop at:  ",ExtMapBuffer3[_shift]," with StopLoss at:  ",ExtMapBuffer4[_shift]);
   }   

void CopyLevels1Day(int _shift)
  {
   
   ExtMapBuffer1[_shift]=ExtMapBuffer1[_shift+1];
   ExtMapBuffer2[_shift]=ExtMapBuffer2[_shift+1];
   ExtMapBuffer3[_shift]=ExtMapBuffer3[_shift+1];
   ExtMapBuffer4[_shift]=ExtMapBuffer4[_shift+1];
   ExtMapBuffer5[_shift]=ExtMapBuffer5[_shift];
  }



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- indicators
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,160); 
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,0);

   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,160); 
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,0);

   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,160); 
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);
   SetIndexLabel(2,0);

   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,160); 
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
   SetIndexLabel(3,0);
   
   SetIndexBuffer(0,ExtMapBuffer5);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   int limit,firstDay;
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(0);
   if (counted_bars==0) 
      {
      limit=Bars-1;
      i=1;
      firstDay=TimeDay(Time[limit]);
      while (TimeDay(Time[limit-i])==firstDay) i++;
      limit=limit-i-PERIOD_D1/Period();
      }
   if (counted_bars>0) limit=Bars-counted_bars;
//---- 
   if (Period()>PERIOD_D1) return;
   for (shift=limit;shift>=0;shift--)
      {
      if (isNewDay(shift)) GetRS1ofDay(shift); else CopyLevels1Day(shift);
      }
//----
   

   return(0);
  }
//+------------------------------------------------------------------+