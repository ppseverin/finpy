//+------------------------------------------------------------------+
//|                                             Angle of average.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property  copyright "mladen"

#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_color3  DimGray
#property  indicator_color4  Gray
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width4  2


//
//
//
//
//

extern int    MA_Period        =  34;
extern int    MA_Type          =   1; // 4 -> LSMA
extern int    MA_AppliedPrice  =   0;
extern double AngleLevel       =   8;
extern int    AngleBars        =   6;

//
//
//
//
//

double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,Buffer1);
   SetIndexBuffer(1,Buffer2);
   SetIndexBuffer(2,Buffer3);
   SetIndexBuffer(3,Buffer4);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   
   //
   //
   //
   //
   //
      
   string  MAType;
   switch (MA_Type)
   {
      case 1:  MAType="EMA";  break;
      case 2:  MAType="SMMA"; break;
      case 3:  MAType="LWMA"; break;
      case 4:  MAType="LSMA"; break;
      default: MAType="SMA";  break;
   }
   IndicatorShortName(MAType+" angle ("+MA_Period+","+DoubleToStr(AngleLevel,2)+","+AngleBars+")");
   IndicatorDigits(2);
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define Pi 3.141592653589793238462643

//
//
//
//
//

int start()
{
   int countedBars = IndicatorCounted();
   int limit, i;
 
   if(countedBars<0) return(-1);
   if(countedBars>0) countedBars--;
      limit = Bars-countedBars;

   //
   //
   //
   //
   //
   
   for(i=limit; i>=0; i--)
   {
      double range = iATR(NULL,0,AngleBars*20,i);
      double angle = 0.00;
      double change;
         if (MA_Type == 4)
               change = iLSMA(MA_Period,MA_AppliedPrice,i)-iLSMA(MA_Period,MA_AppliedPrice,i+AngleBars);
         else  change = iMA(NULL,0,MA_Period,0,MA_Type,MA_AppliedPrice,i)-iMA(NULL,0,MA_Period,0,MA_Type,MA_AppliedPrice,i+AngleBars);

         if (range != 0) angle = MathArctan(change/(range*AngleBars))*180.0/Pi;

      //
      //
      //
      //
      //
      
         Buffer1[i] = EMPTY_VALUE;
         Buffer2[i] = EMPTY_VALUE;
         Buffer3[i] = angle;
         Buffer4[i] = angle;
            if (angle >  AngleLevel) { Buffer1[i] = angle; Buffer3[i] = EMPTY_VALUE;}
            if (angle < -AngleLevel) { Buffer2[i] = angle; Buffer3[i] = EMPTY_VALUE;}
   }
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double iLSMA(int period,int appliedPrice,int shift)
{
   double lengthvar = (period + 1.0)/3.0;
   double sum       = 0.0;

   for(int i = period; i >= 1 ; i--)
      sum += (i-lengthvar)*iMA(NULL,0,1,0,MODE_SMA,appliedPrice,shift+period-i);
   return(sum*6.0/(period*(period+1.0)));
}