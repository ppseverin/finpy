//+------------------------------------------------------------------+
//|                                        Trend Intensity Index.mq4 |
//|                                                           mladen |
//|                                                                  |
//| Trend Intensity Index originaly developed by M.H. Pee            |
//| TASC : 20:06 (Jun 2002) article                                  |
//| "Strong Trends = Strong Profits. Trend Intensity Index"          |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers    2
#property indicator_color1     DarkOrange
#property indicator_color2     LimeGreen
#property indicator_style2     STYLE_DOT
#property indicator_width1     2
#property indicator_levelcolor DimGray
#property indicator_minimum  -1
#property indicator_maximum 101


//
//
//
//
//

extern string TimeFrame              = "Current time frame";
extern int    Length                 = 30;
extern int    Price                  = PRICE_CLOSE;
extern int    MaMode                 = MODE_SMA;
extern bool   NonOriginalCalculation = false;
extern double LevelHigh              = 80;
extern double LevelLow               = 20;
extern bool   ShowArrows             = true;
extern bool   ShowArrowsOnZoneEnter = true;
extern bool   ShowArrowsOnZoneExit  = true;
extern string ArrowsIdentifier       = "trendIntensityIndex";
extern color  ArrowUpColor           = Green;
extern color  ArrowDnColor           = Red;
extern bool   Interpolate            = true;

//
//
//
//
//

double Tii[];
double TiiPosition[];
double MaDiff[];
double trend[];
double prices[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

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
   IndicatorBuffers(4);
   SetIndexBuffer(0,Tii);         SetIndexLabel(0,"Trend Intensity Index");
   SetIndexBuffer(1,TiiPosition); SetIndexLabel(1,"Trend Intensity Index position");
   SetIndexBuffer(2,trend);
   SetIndexBuffer(3,MaDiff);
   
   //
   //
   //
   //
   //
      
      LevelHigh = MathMin(MathMax(LevelHigh,0),100);
      LevelLow  = MathMin(MathMax(LevelLow,0) ,100);
      if (LevelHigh<LevelLow)
         {
            double temp = LevelHigh;
                   LevelHigh = LevelLow;
                   LevelLow  = temp;
         }
         SetLevelValue(0,LevelHigh);
         SetLevelValue(1,LevelLow);

   //
   //
   //
   //
   //

      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="CalculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
         
   //
   //
   //
   //
   //

   IndicatorShortName(timeFrameToString(timeFrame)+" Trend intensity index ("+Length+")");
   return(0);
}

//
//
//
//
//

int deinit()
{
   if (ShowArrows)
   {
      int compareLength = StringLen(ArrowsIdentifier);
      for (int i=ObjectsTotal(); i>= 0; i--)
      {
         string name = ObjectName(i);
            if (StringSubstr(name,0,compareLength) == ArrowsIdentifier)
                ObjectDelete(name);  
      }
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

int start()
{
   int counted_bars=IndicatorCounted();
   int i,j,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-Length*2);
         if (returnBars)  { Tii[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      if (ArrayRange(prices,0) != Bars) ArrayResize(prices,Bars);
      for(i=limit, r=Bars-limit-1; i>=0; i--,r++)
      {
         double ma = iMA(NULL,0,Length*2,0,MaMode,Price,i);
         prices[r] = iMA(NULL,0,1,0,MODE_SMA,Price,i);

         //
         //
         //
         //
         //

            double sumUpDeviations = 0;
            double sumDnDeviations = 0;

            if (NonOriginalCalculation)
            {
               MaDiff[i] = Close[i] - ma;
               for(j=0; j<Length; j++)
               {
                   if (MaDiff[i+j]>0)
                        sumUpDeviations += MaDiff[i+j];
                  else  sumDnDeviations -= MaDiff[i+j];
               }               
            }
            else
            {            
               for(j=0; j<Length; j++)
               {
                  double diff = prices[r-j]-ma;
                  if (diff>0)
                        sumUpDeviations += diff;
                  else  sumDnDeviations -= diff;
               }               
            }               
            
         //
         //
         //
         //
         //

         if ((sumUpDeviations+sumDnDeviations)!=0)
               Tii[i] = 100*sumUpDeviations/(sumUpDeviations+sumDnDeviations);
         else  Tii[i] = 0; 
      
         TiiPosition[i] = 50;
            if (Tii[i]>LevelHigh) TiiPosition[i] = 101;
            if (Tii[i]<LevelLow)  TiiPosition[i] =  -1;
         manageArrow(i);
      }
      return(0);
   }      

   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         Tii[i]         = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",Length,Price,MaMode,NonOriginalCalculation,0,y);
         TiiPosition[i] = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",Length,Price,MaMode,NonOriginalCalculation,1,y);
         manageArrow(i);

         //
         //
         //
         //
         //
      
            if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
            if (!Interpolate) continue;

         //
         //
         //
         //
         //

            datetime time = iTime(NULL,timeFrame,y);
               for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
               for(int k = 1; k < n; k++)
               {
                  Tii[i+k]         = Tii[i]         + (Tii[i+n]        -Tii[i]        )*k/n;
                  TiiPosition[i+k] = TiiPosition[i] + (TiiPosition[i+n]-TiiPosition[i])*k/n;
               }
   }

   //
   //
   //
   //
   //
      
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


void manageArrow(int i)
{
   if (ShowArrows && !calculateValue)
   {
      double dist = iATR(NULL,0,20,i)/2.0;
      ObjectDelete(ArrowsIdentifier+":"+Time[0]);
            
      //
      //
      //
      //
      //
           
      trend[i] = trend[i+1];
         if (Tii[i] < LevelHigh && Tii[i] > LevelLow) trend[i] =  0;
         if (Tii[i] > LevelHigh)                      trend[i] =  1;
         if (Tii[i] < LevelLow)                       trend[i] = -1;
         if (trend[i]!=trend[i+1])
         {
            if (ShowArrowsOnZoneEnter && trend[i]   == 1)                 drawArrow(i,ArrowUpColor,241,false);
            if (ShowArrowsOnZoneEnter && trend[i]   ==-1)                 drawArrow(i,ArrowDnColor,242,true);
            if (ShowArrowsOnZoneExit  && trend[i+1] == 1 && trend[i]!=-1) drawArrow(i,ArrowDnColor,242,true);
            if (ShowArrowsOnZoneExit  && trend[i+1] ==-1 && trend[i]!= 1) drawArrow(i,ArrowUpColor,241,False);
         }
   }
}

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = ArrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}