//+------------------------------------------------------------------+
//| DPO.mq4 
//| Ramdass - Conversion only
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue



extern int x_prd=14;
extern int CountBars=300;
//---- buffers
double dpo[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,dpo);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| DPO                                                              |
//+------------------------------------------------------------------+
int start()
  {
   if (CountBars>=Bars) CountBars=Bars;
   SetIndexDrawBegin(0,Bars-CountBars+x_prd+1);
   int i,counted_bars=IndicatorCounted();
   double t_prd;
//----
   if(Bars<=x_prd) return(0);
//---- initial zero
   if(counted_bars<x_prd)
   {
      for(i=1;i<=x_prd;i++) dpo[CountBars-i]=0.0;
   }
//----
   i=CountBars-x_prd-1;
   t_prd=x_prd/2+1;

   while(i>=0)
     {
     dpo[i]=Close[i]-iMA(NULL,0,x_prd,t_prd,MODE_SMA,PRICE_CLOSE,i);


      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+