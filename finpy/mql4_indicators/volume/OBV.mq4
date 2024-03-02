//+------------------------------------------------------------------+
//|                                            On Balance Volume.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters
extern int ExtOBVAppliedPrice=0;
//---- buffers
double ExtOBVBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string sShortName;
//---- indicator buffer mapping
   SetIndexBuffer(0,ExtOBVBuffer);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
//---- sets default precision format for indicators visualization
   IndicatorDigits(0);     
//---- name for DataWindow and indicator subwindow label
   sShortName="OBV";
   IndicatorShortName(sShortName);
   SetIndexLabel(0,sShortName);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| On Balance Volume                                                |
//+------------------------------------------------------------------+
int start()
  {
   int    i,nLimit,nCountedBars;
//---- bars count that does not changed after last indicator launch.
   nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted
   if(nCountedBars>0) nCountedBars--;
   nLimit=Bars-nCountedBars-1;
//---- 
   for(i=nLimit; i>=0; i--)
     {
      if(i==Bars-1)
         ExtOBVBuffer[i]=Volume[i];
      else
        {
         double dCurrentPrice=GetAppliedPrice(ExtOBVAppliedPrice, i);
         double dPreviousPrice=GetAppliedPrice(ExtOBVAppliedPrice, i+1);
         if(dCurrentPrice==dPreviousPrice)
            ExtOBVBuffer[i]=ExtOBVBuffer[i+1];
         else
           {
            if(dCurrentPrice<dPreviousPrice)
               ExtOBVBuffer[i]=ExtOBVBuffer[i+1]-Volume[i];  
            else
               ExtOBVBuffer[i]=ExtOBVBuffer[i+1]+Volume[i]; 
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAppliedPrice(int nAppliedPrice, int nIndex)
  {
   double dPrice;
//----
   switch(nAppliedPrice)
     {
      case 0:  dPrice=Close[nIndex];                                  break;
      case 1:  dPrice=Open[nIndex];                                   break;
      case 2:  dPrice=High[nIndex];                                   break;
      case 3:  dPrice=Low[nIndex];                                    break;
      case 4:  dPrice=(High[nIndex]+Low[nIndex])/2.0;                 break;
      case 5:  dPrice=(High[nIndex]+Low[nIndex]+Close[nIndex])/3.0;   break;
      case 6:  dPrice=(High[nIndex]+Low[nIndex]+2*Close[nIndex])/4.0; break;
      default: dPrice=0.0;
     }
//----
   return(dPrice);
  }
//+------------------------------------------------------------------+