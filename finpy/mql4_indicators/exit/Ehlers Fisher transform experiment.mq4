//+----------------------------------------------------------+
//|                              Ehlers fisher transform.mq4 |
//|                                                   mladen |
//+----------------------------------------------------------+
#property  copyright "mladen"
#property  link      "mladenfx@gmail.com"

#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  clrDeepSkyBlue
#property  indicator_color2  clrSandyBrown
#property  indicator_color3  clrSandyBrown
#property  indicator_color4  clrSilver
#property  indicator_width1  3
#property  indicator_width2  3
#property  indicator_width3  3
#property  indicator_style4  STYLE_DOT
#property  strict

//
//
//
//
//
 
extern int                period    = 10;           // Transform period
extern ENUM_APPLIED_PRICE PriceType = PRICE_MEDIAN; // Price to use
extern double             Weight    = 2;            // Smoothing weight
extern double             SignalPeriod = 9;         // Signal period

//
//
//
//
//

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double Prices[];
double Values[];
double Cross[];

   
//+----------------------------------------------------------+
//|                                                          |
//+----------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(7);
      SetIndexBuffer(0,buffer1);
      SetIndexBuffer(1,buffer2);
      SetIndexBuffer(2,buffer3);
      SetIndexBuffer(3,buffer4);
      SetIndexBuffer(4,Prices);
      SetIndexBuffer(5,Values);
      SetIndexBuffer(6,Cross);
   IndicatorShortName("Ehlers\' Fisher transform ("+(string)period+")");
   return(0);
}


//+----------------------------------------------------------+
//|                                                          |
//+----------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
           int limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   double alpha = 2.0/(1.0+Weight);         
   double ema   = 2.0/(1.0+SignalPeriod);
   if (Cross[limit]==-1) CleanPoint(limit,buffer2,buffer3);
   for(int i=limit; i>=0; i--)
   {  
      Prices[i]  = iMA(NULL,0,1,0,MODE_SMA,PriceType,i);
      
      //
      //
      //
      //
      //
                  
         double MaxH = Prices[ArrayMaximum(Prices,period,i)];
         double MinL = Prices[ArrayMinimum(Prices,period,i)];
         if (MaxH!=MinL && i<Bars-1)
               Values[i] = alpha*((Prices[i]-MinL)/(MaxH-MinL)-0.5+Values[i+1]);
         else  Values[i] = 0.00;
               Values[i] = MathMin(MathMax(Values[i],-0.999),0.999); 

      // 
      //
      //
      //
      //

      if (i<Bars-1)
      {
         buffer1[i] = 0.5*MathLog((1+Values[i])/(1-Values[i]))+0.5*buffer1[i+1];
         buffer2[i] = EMPTY_VALUE;
         buffer3[i] = EMPTY_VALUE;
         buffer4[i] = buffer4[i+1];
         if (buffer1[i]>buffer4[i+1])
            if (buffer1[i]>buffer1[i+1])
                  buffer4[i] = buffer4[i+1]+ema*(buffer1[i]-buffer4[i+1]);
         if (buffer1[i]<buffer4[i+1])
            if (buffer1[i]<buffer1[i+1])
                  buffer4[i] = buffer4[i+1]+ema*(buffer1[i]-buffer4[i+1]);

         //
         //
         //
         //
         //
         
         Cross[i]   = Cross[i+1];
            if (buffer1[i]>buffer4[i]) Cross[i]=  1;
            if (buffer1[i]<buffer4[i]) Cross[i]= -1;
            if (Cross[i]==-1) PlotPoint(i,buffer2,buffer3,buffer1);
      }
      else { buffer1[i] = 0; buffer4[i] = 0; }
   }
   return(0);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}