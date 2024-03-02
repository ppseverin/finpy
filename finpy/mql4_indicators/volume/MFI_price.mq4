//+------------------------------------------------------------------+
//|                                                  MFI_price.mq4   |
//|                                         Author:  Paladin80       |
//|                                         E-mail:  forevex@mail.ru |
//+------------------------------------------------------------------+
/*
The standard indicator "Money Flow Index, MFI" is calculated by formulas:
(http://codebase.mql4.com/303 , http://codebase.mql4.com/ru/302)
   MF = TYPICAL * VOLUME
   MR = Positive Money Flow (PMF)/Negative Money Flow (NMF)
   MFI = 100 - (100 / (1 + MR))
   where TYPICAL - applied price (typical).

In this indicator applied price may be changed, according to formula:
   MF = Applied_price * VOLUME
*/
#property copyright "Paladin80"
#property link      "forevex@mail.ru"
//---- indicator settings
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 20
#property indicator_level2 80
#property indicator_buffers 1
#property indicator_color1 Blue
//---- input parameters
extern int ExtMFIPeriod=14;
extern int Applied_price=5;
bool       error=false;
/*
Applied_price:
   0 - Close price,  1 - Open price,   2 - High price,
   3 - Low price,    4 - Median price, 5 - Typical price,  6 - Weighted close price.
*/
string     Applied_pricetext;
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
//---- Check errors
   if (Applied_price<0 || Applied_price>6)
   {  error=true; Alert("Please select correct Applied_price (0-6) for indicator MFI_price");
      return(0); }
//----
   switch (Applied_price)
   {  case PRICE_CLOSE:    Applied_pricetext="Close";      break;
      case PRICE_OPEN:     Applied_pricetext="Open";       break;
      case PRICE_HIGH:     Applied_pricetext="High";       break;
      case PRICE_LOW:      Applied_pricetext="Low";        break;
      case PRICE_MEDIAN:   Applied_pricetext="Median";     break;
      case PRICE_TYPICAL:  Applied_pricetext="Typical";    break;
      case PRICE_WEIGHTED: Applied_pricetext="Weighted";   break;
   }
//---- name for DataWindow and indicator subwindow label
   sShortName="MFI_price("+Applied_pricetext+","+ExtMFIPeriod+")";
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
//----
   if (error==true) return(0);
//----
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
         switch(Applied_price)
         {
         case PRICE_CLOSE:    dCurrentTP=Close[i];                         break;
         case PRICE_OPEN:     dCurrentTP=Open[i];                          break;
         case PRICE_HIGH:     dCurrentTP=High[i];                          break;
         case PRICE_LOW:      dCurrentTP=Low[i];                           break;
         case PRICE_MEDIAN:   dCurrentTP=(High[i]+Low[i])/2.0;             break;
         case PRICE_TYPICAL:  dCurrentTP=(High[i]+Low[i]+Close[i])/3.0;    break;
         case PRICE_WEIGHTED: dCurrentTP=(High[i]+Low[i]+2*Close[i])/4.0;  break;
         }
      for(j=0; j<ExtMFIPeriod; j++)
        {
         switch(Applied_price)
         {
         case PRICE_CLOSE:    dPreviousTP=Close[i+j+1];                                break;
         case PRICE_OPEN:     dPreviousTP=Open[i+j+1];                                 break;
         case PRICE_HIGH:     dPreviousTP=High[i+j+1];                                 break;
         case PRICE_LOW:      dPreviousTP=Low[i+j+1];                                  break;
         case PRICE_MEDIAN:   dPreviousTP=(High[i+j+1]+Low[i+j+1])/2.0;                break;
         case PRICE_TYPICAL:  dPreviousTP=(High[i+j+1]+Low[i+j+1]+Close[i+j+1])/3.0;   break;
         case PRICE_WEIGHTED: dPreviousTP=(High[i+j+1]+Low[i+j+1]+2*Close[i+j+1])/4.0; break;
         }
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