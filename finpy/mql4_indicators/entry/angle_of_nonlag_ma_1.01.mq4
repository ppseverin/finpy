//+------------------------------------------------------------------+
//|                                             Angle of average.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property  copyright "mladen"

#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  LimeGreen
#property  indicator_color2  Orange
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

extern int    NlmaPeriod       = 14;
extern int    NlmaPrice        = PRICE_CLOSE;
extern double AngleLevel       = 8;
extern int    AngleBars        = 6;

//
//
//
//
//

double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];

int ChartScale,BarWidth;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   ChartScale = ChartScaleGet();
   if(ChartScale == 0)
     {
      BarWidth = 1;
     }
   else
     {
      if(ChartScale == 1)
        {
         BarWidth = 1;
        }
      else
        {
         if(ChartScale == 2)
           {
            BarWidth = 2;
           }
         else
           {
            if(ChartScale == 3)
              {
               BarWidth = 4;
              }
            else
              {
               if(ChartScale == 4)
                 {
                  BarWidth = 6;
                 }
               else
                 {
                  BarWidth = 13;
                 }
              }
           }
        }
     }

   SetIndexBuffer(0,Buffer1);
   SetIndexBuffer(1,Buffer2);
   SetIndexBuffer(2,Buffer3);
   SetIndexBuffer(3,Buffer4);
   SetIndexStyle(0,DRAW_HISTOGRAM,0, BarWidth);
   SetIndexStyle(1,DRAW_HISTOGRAM,0, BarWidth);
   SetIndexStyle(2,DRAW_HISTOGRAM,0, BarWidth);

//
//
//
//
//
   SetLevelValue(0, AngleLevel);
   SetLevelValue(1,-AngleLevel);
   IndicatorShortName("angle of nlma ("+NlmaPeriod+","+DoubleToStr(AngleLevel,2)+","+AngleBars+")");
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int countedBars = IndicatorCounted();
   if(countedBars<0)
      return(-1);
   if(countedBars>0)
      countedBars--;
   int limit = MathMin(Bars-countedBars,Bars-1);

//
//
//
//
//

   for(int i=limit; i>=0; i--)
     {
      double range  = iATR(NULL,0,AngleBars*20,i);
      double angle  = 0.00;
      double price1 = iMA(NULL,0,1,0,MODE_SMA,NlmaPrice,i);
      double price2 = iMA(NULL,0,1,0,MODE_SMA,NlmaPrice,i+AngleBars);
      //Print(TimeToStr(iTime(0,0,i)),"-",TimeToStr(iTime(0,0,i+AngleBars)),"-",Close[i],", price 1: ",price1,", price2: ",price2);
      double change = iNonLagMa(price1,NlmaPeriod,i,0)-iNonLagMa(price2,NlmaPeriod,i,1);
      //Print(TimeToStr(iTime(0,0,i)),"-",change*10000);
      if(range != 0)
         angle = MathArctan(change/(range*AngleBars))*180.0/Pi;
      //Print(TimeToStr(iTime(0,0,i))," - ",range*100);
      //
      //
      //
      //
      //

      Buffer1[i] = 0;
      Buffer2[i] = 0;
      Buffer3[i] = angle;
      Buffer4[i] = angle;
      if(angle >  AngleLevel)
        {
         Buffer1[i] = angle;
         Buffer3[i] = 0;
        }
      if(angle < -AngleLevel)
        {
         Buffer2[i] = angle;
         Buffer3[i] = 0;
        }
      if(i<=20)
         Print(TimeToStr(iTime(0,0,i))," b1: ",Buffer1[i]," b2: ",Buffer2[i]," b3: ",Buffer3[i]," b4: ",Buffer4[i]);
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

#define _length  0
#define _len     1

double  nlmvalues[][2];
double  nlmprices[][2];
double  nlmalphas[][2];

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iNonLagMa(double price, double length, int r, int instanceNo=0)
  {
   r = Bars-r-1;
   if(ArrayRange(nlmprices,0) != Bars)
      ArrayResize(nlmprices,Bars);
   if(ArrayRange(nlmvalues,0) <  instanceNo+1)
      ArrayResize(nlmvalues,instanceNo+1);
   nlmprices[r][instanceNo]=price;
   if(length<3 || r<3)
      return(nlmprices[r][instanceNo]);

//
//
//
//
//

   if(nlmvalues[instanceNo][_length] != length  || ArraySize(nlmalphas)==0)
     {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = length-1;

      nlmvalues[instanceNo][_length] = length;
      nlmvalues[instanceNo][_len   ] = length*4 + Phase;

      if(ArrayRange(nlmalphas,0) < nlmvalues[instanceNo][_len])
         ArrayResize(nlmalphas,nlmvalues[instanceNo][_len]);
      for(int k=0; k<nlmvalues[instanceNo][_len]; k++)
        {
         if(k<=Phase-1)
            double t = 1.0 * k/(Phase-1);
         else
            t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0);
         double beta = MathCos(Pi*t);
         double g = 1.0/(Coeff*t+1);
         if(t <= 0.5)
            g = 1;

         nlmalphas[k][instanceNo] = g * beta;
        }
     }

//
//
//
//
//

   double sum = 0, sumw = 0;
   for(k=0; k < nlmvalues[instanceNo][_len] && (r-k)>=0; k++)
     {
      sum += nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
      sumw += nlmalphas[k][instanceNo];
     }
   if(sumw!=0)
      return(sum/sumw);
   else
      return(price);
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   ChartScale = ChartScaleGet();
   init();
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChartScaleGet()
  {
   long result = -1;
   ChartGetInteger(0,CHART_SCALE,0,result);
   return((int)result);
  }
//+------------------------------------------------------------------+
