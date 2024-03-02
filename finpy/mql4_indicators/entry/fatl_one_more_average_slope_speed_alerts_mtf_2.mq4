//+------------------------------------------------------------------+
//| fatl adaptive smoother
//|
//+------------------------------------------------------------------+
//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers    5
#property indicator_color1     clrLimeGreen
#property indicator_color2     clrOrange
#property indicator_color3     clrGray
#property indicator_color4     clrLimeGreen
#property indicator_color5     clrRed
#property indicator_width1     4
#property indicator_width2     4
#property indicator_width3     2

//
//
//
//
//

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};

extern ENUM_TIMEFRAMES TimeFrame         = PERIOD_CURRENT;
extern enPrices        Price             = pr_close;
extern double          OmaLength         = 25;
extern double          Speed             = -1;
extern bool            Adaptive          = false;
extern bool            alertsOn          = true;
extern bool            alertsOnSlope     = true;
extern bool            alertsOnZeroCross = true;
extern bool            alertsOnCurrent   = false;
extern bool            alertsMessage     = true;
extern bool            alertsSound       = false;
extern bool            alertsEmail       = false;
extern bool            alertsNotify      = false;
extern bool            Interpolate       = true;

extern bool            ArrowsOnFirstBar  = false;

//
//
//
//
//

double ofatl[];
double diff[];
double diffhuu[];
double diffhdd[];
double slope[];
double trend[];
double upArr[];
double dnArr[];
double prices[];
string indicatorFileName;
bool   returnBars;

//
//
//
//

int init()
{
   IndicatorBuffers(9);
   SetIndexBuffer(0,diffhuu); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,diffhdd); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,diff);
   SetIndexBuffer(3,upArr);   SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,233);
   SetIndexBuffer(4,dnArr);   SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,234);
   SetIndexBuffer(5,ofatl);
   SetIndexBuffer(6,slope);
   SetIndexBuffer(7,trend);
   SetIndexBuffer(8,prices);
      
      Speed             = MathMax(MathMin(1.5,Speed),0.1);
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame==-99;
      TimeFrame         = MathMax(TimeFrame,_Period);
      
   IndicatorShortName(timeFrameToString(TimeFrame)+" Fatl One More Average Slope Speed"); 
return(0);
}

//+------------------------------------------------------------------+
//| FATL |
//+------------------------------------------------------------------+
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars)  { diffhuu[0] = limit; return(0); }
       
   //
   //
   //
   //
   //
   
   if (TimeFrame==Period())
   {

      for (int i=limit; i>=0; i--)
      {
         prices[i] = getPrice(Price,Open,Close,High,Low,i);
         double fatl = +0.4360409450*prices[i+0]  +0.3658689069*prices[i+1]  +0.2460452079*prices[i+2]  +0.1104506886*prices[i+3]  -0.0054034585*prices[i+4]
                       -0.0760367731*prices[i+5]  -0.0933058722*prices[i+6]  -0.0670110374*prices[i+7]  -0.0190795053*prices[i+8]  +0.0259609206*prices[i+9]
                       +0.0502044896*prices[i+10] +0.0477818607*prices[i+11] +0.0249252327*prices[i+12] -0.0047706151*prices[i+13] -0.0272432537*prices[i+14]
                       -0.0338917071*prices[i+15] -0.0244141482*prices[i+16] -0.0055774838*prices[i+17] +0.0128149838*prices[i+18] +0.0226522218*prices[i+19] 
                       +0.0208778257*prices[i+20] +0.0100299086*prices[i+21] -0.0036771622*prices[i+22] -0.0136744850*prices[i+23] -0.0160483392*prices[i+24]
                       -0.0108597376*prices[i+25] -0.0016060704*prices[i+26] +0.0069480557*prices[i+27] +0.0110573605*prices[i+28] +0.0095711419*prices[i+29]
                       +0.0040444064*prices[i+30] -0.0023824623*prices[i+31] -0.0067093714*prices[i+32] -0.0072003400*prices[i+33] -0.0047717710*prices[i+34]
                       +0.0005541115*prices[i+35] +0.0007860160*prices[i+36] +0.0130129076*prices[i+37] +0.0040364019*prices[i+38];
                       ofatl[i] = iOma(fatl,OmaLength,Speed,Adaptive,i);
                       diff[i]  = ofatl[i]-ofatl[i+1];
                    
                       //
                       //
                       //
                       //
                       //
                    
                       diffhuu[i] = EMPTY_VALUE;
                       diffhdd[i] = EMPTY_VALUE;     
                       slope[i]   = slope[i+1];
                       trend[i]   = trend[i+1]; 
                         if (diff[i] > diff[i+1]) slope[i] =  1;
                         if (diff[i] < diff[i+1]) slope[i] = -1;
                         if (diff[i] > 0)         trend[i] =  1;
                         if (diff[i] < 0)         trend[i] = -1;
                         if (slope[i]== 1) diffhuu[i] = diff[i];
                         if (slope[i]==-1) diffhdd[i] = diff[i];
                      
                         //
                         //
                         //
                         //
                         //
                      
   }
   for (i=limit; i>=0; i--)
   {
      upArr[i] = EMPTY_VALUE;
      dnArr[i] = EMPTY_VALUE;
         if (trend[i] !=trend[i+1])
         if (trend[i] == 1)
               upArr[i] = diff[i]-iStdDevOnArray(diff,0,10,0,MODE_SMA,i);
        else   dnArr[i] = diff[i]+iStdDevOnArray(diff,0,10,0,MODE_SMA,i); 
   }
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      
      //
      //
      //
      //
      //
            
      static datetime time1 = 0;
      static string   mess1 = "";
      if (alertsOnSlope && slope[whichBar] != slope[whichBar+1])
      {
         if (slope[whichBar] ==  1) doAlert(time1,mess1,whichBar,"sloping up");
         if (slope[whichBar] == -1) doAlert(time1,mess1,whichBar,"sloping down");
      }
      static datetime time2 = 0;
      static string   mess2 = "";
      if (alertsOnZeroCross && trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(time2,mess2,whichBar,"crossed zero up");
         if (trend[whichBar] == -1) doAlert(time2,mess2,whichBar,"crossed zero down");
      }
   }
   return(0);
   }
   
   //
   //
   //
   //
   //
   
   int shift = -1; if (ArrowsOnFirstBar) shift=1;
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for (i=limit;i>=0; i--)
   {
       int y = iBarShift(NULL,TimeFrame,Time[i]);
       int z = iBarShift(NULL,TimeFrame,Time[i+shift]);
          diffhuu[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,OmaLength,Speed,Adaptive,alertsOn,alertsOnSlope,alertsOnZeroCross,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,0,y);
          diffhdd[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,OmaLength,Speed,Adaptive,alertsOn,alertsOnSlope,alertsOnZeroCross,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,1,y);
          diff[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,OmaLength,Speed,Adaptive,alertsOn,alertsOnSlope,alertsOnZeroCross,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,2,y); 
       if(z!=y)
       {
          upArr[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,OmaLength,Speed,Adaptive,alertsOn,alertsOnSlope,alertsOnZeroCross,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,3,y); 
          dnArr[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,OmaLength,Speed,Adaptive,alertsOn,alertsOnSlope,alertsOnZeroCross,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,4,y); 
       }
       else
       {
          upArr[i]   = EMPTY_VALUE;
          dnArr[i]   = EMPTY_VALUE;
       }
         
          //
          //
          //
          //
          //
            
          if (!Interpolate || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;

          //
          //
          //
          //
          //

          datetime time = iTime(NULL,TimeFrame,y);
             for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;
             for(int s = 1; s < n; s++) 
             {
  	             diff[i+s] = diff[i] + (diff[i+n] - diff[i]) * s/n;
                if (diffhuu[i]!= EMPTY_VALUE) diffhuu[i+s] = diff[i+s];
                if (diffhdd[i]!= EMPTY_VALUE) diffhdd[i+s] = diff[i+s];
             }
   }
return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workOma[][7];
#define F01 0
#define F02 1
#define F03 2
#define F04 3
#define F05 4
#define F06 5
#define prc 6

//
//
//
//
//

double iOma(double price, double averagePeriod, double constant, bool adaptive, int r, int s=0)
{
   if (averagePeriod <=1) return(price);
   if (ArrayRange(workOma,0) != Bars) ArrayResize(workOma,Bars); r=Bars-r-1; s *=7;
   if (r<=1) 
   {
      for (int i=0; i<6; i++) workOma[r][i  +s] = 0;
                              workOma[r][prc+s] = price;
                              return(price);
   }      
   double f01=workOma[r-1][F01+s];  double f02=workOma[r-1][F02+s];
   double f03=workOma[r-1][F03+s];  double f04=workOma[r-1][F04+s];
   double f05=workOma[r-1][F05+s];  double f06=workOma[r-1][F06+s];

   //
   //
   //
   //
   //

      if (adaptive && (averagePeriod > 1))
      {
         double minPeriod = MathMin(averagePeriod,r)/2.0;
         double maxPeriod = MathMin(minPeriod*5.0,r);
         int    endPeriod = (int)MathCeil(maxPeriod);
         double tsignal   = MathAbs((price-workOma[r-endPeriod][prc+s]));
         double noise     = 0.00000000001;

            for(i=1; i<endPeriod; i++) noise=noise+MathAbs(price-workOma[r-i][prc+s]);

         averagePeriod = ((tsignal/noise)*(maxPeriod-minPeriod))+minPeriod;
      }
      
      //
      //
      //
      //
      //
      
      double Kg = (2.0+constant)/(1.0+constant+averagePeriod);
      double Hg = 1.0-Kg;

      f01 = Kg * price + Hg * f01; f02 = Kg * f01 + Hg * f02; double v01 = 1.5 * f01 - 0.5 * f02;
      f03 = Kg * v01   + Hg * f03; f04 = Kg * f03 + Hg * f04; double v02 = 1.5 * f03 - 0.5 * f04;
      f05 = Kg * v02   + Hg * f05; f06 = Kg * f05 + Hg * f06; double v03 = 1.5 * f05 - 0.5 * f06;

   //
   //
   //
   //
   //

   workOma[r][F01+s] = f01;  workOma[r][F02+s] = f02;
   workOma[r][F03+s] = f03;  workOma[r][F04+s] = f04;
   workOma[r][F05+s] = f05;  workOma[r][F06+s] = f06;
   workOma[r][prc+s] = price;
return(v03);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

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

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," fatl oma slope speed  ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," fatl oma slope speed "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
         int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
} 
