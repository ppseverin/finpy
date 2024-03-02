//+------------------------------------------------------------------+
//|                                             Money Flow Index.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 20
#property indicator_level2 80
#property indicator_buffers 1
#property indicator_color1 Blue
//---- input parameters
extern int ExtMFIPeriod=14;
//---- buffers
double ExtMFIBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string sShortName;
//----
   SetIndexBuffer(0,ExtMFIBuffer);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
//---- name for DataWindow and indicator subwindow label
   sShortName="MFI("+ExtMFIPeriod+")";
   IndicatorShortName(sShortName);
   SetIndexLabel(0,sShortName);
//---- first values aren't drawn
   SetIndexDrawBegin(0,ExtMFIPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Money Flow Index                                                 |
//+------------------------------------------------------------------+
int start()
  {
   int    i,j,nCountedBars;
   double dPositiveMF,dNegativeMF,dCurrentTP,dPreviousTP;
//---- insufficient data
   if(Bars<=ExtMFIPeriod) return(0);
//---- bars count that does not changed after last indicator launch.
   nCountedBars=IndicatorCounted();
//----
   i=Bars-ExtMFIPeriod-1;
   if(nCountedBars>ExtMFIPeriod) 
      i=Bars-nCountedBars-1;
   while(i>=0)
     {
      dPositiveMF=0.0;
      dNegativeMF=0.0;
      dCurrentTP=(High[i]+Low[i]+Close[i])/3;
      for(j=0; j<ExtMFIPeriod; j++)
        {
         dPreviousTP=(High[i+j+1]+Low[i+j+1]+Close[i+j+1])/3;
         if(dCurrentTP>dPreviousTP)
            dPositiveMF+=Volume[i+j]*dCurrentTP;
         else
           {
            if(dCurrentTP<dPreviousTP)
                dNegativeMF+=Volume[i+j]*dCurrentTP;
           }
          dCurrentTP=dPreviousTP;      
        }
      //----
      if(dNegativeMF!=0.0)      
         ExtMFIBuffer[i]=100-100/(1+dPositiveMF/dNegativeMF);
      else
         ExtMFIBuffer[i]=100;
      //----
      i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+