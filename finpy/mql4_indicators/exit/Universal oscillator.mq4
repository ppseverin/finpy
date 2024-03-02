//------------------------------------------------------------------
#property copyright   "www.forex-tsd.com"
#property link        "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrSilver
#property indicator_color2  clrSilver
#property indicator_color3  clrSilver
#property indicator_color4  clrGainsboro
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property strict

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
enum enColorOn
{
   cc_onSlope,   // Change color on slope change
   cc_onMiddle,  // Change color on middle line cross
   cc_onLevels   // Change color on outer levels cross
};

extern ENUM_TIMEFRAMES    TimeFrame           = PERIOD_CURRENT;    // Time frame
extern string             ForSymbol           = "";                // For symbol (leave empty for current chart symbol)
extern double             BandEdge            = 20;                // Band edge
extern enPrices           Price               = pr_close;          // Price to use
extern double             LevelUp             =  0.8;              // Upper level
extern double             LevelDown           = -0.8;              // Lower level
extern enColorOn          ColorOn             = cc_onLevels;       // Color change :
extern color              ColorUp             = clrDeepSkyBlue;    // Color for up
extern color              ColorDown           = clrSandyBrown;     // Color for down
extern int                LineWidth           = 3;                 // Main line width
extern bool               Interpolate         = true;              // Interpolate in multi time frame?

//
//
//
//
//

double unio[];
double unioUa[];
double unioUb[];
double unioDa[];
double unioDb[];
double levup[];
double levmi[];
double levdn[];
double trend[],price[],peak[];

string indicatorFileName,shortName;
bool   returnBars;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(11);
   SetIndexBuffer(0,levup);
   SetIndexBuffer(1,levmi);
   SetIndexBuffer(2,levdn);
   SetIndexBuffer(3,unio);   SetIndexStyle(3,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(4,unioUa); SetIndexStyle(4,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(5,unioUb); SetIndexStyle(5,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(6,unioDa); SetIndexStyle(6,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(7,unioDb); SetIndexStyle(7,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(8,trend); 
   SetIndexBuffer(9,price); 
   SetIndexBuffer(10,peak); 
   
       //
       //
       //
       //
       //
      
       indicatorFileName = WindowExpertName();
       returnBars        = (TimeFrame==-99);
       TimeFrame         = MathMax(TimeFrame,_Period);
       if (ForSymbol=="") ForSymbol = _Symbol;
         shortName = ForSymbol+" "+timeFrameToString(TimeFrame)+" Universal oscillator ("+(string)BandEdge+")";
   IndicatorShortName(shortName);
   return(0);
}
int deinit() { return (0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
            int window = WindowFind(shortName);
            int limit  = MathMin(Bars-counted_bars,Bars-1);
            if (returnBars) { levup[0] = limit+1; return(0); }
            if (TimeFrame != Period() || ForSymbol!=_Symbol)
            {
               limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(ForSymbol,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period())); 
               if (trend[limit]== 1) CleanPoint(limit,unioUa,unioUb);
               if (trend[limit]==-1) CleanPoint(limit,unioDa,unioDb);
               for(int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     levup[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",BandEdge,Price,LevelUp,LevelDown,ColorOn,0,y);
                     levmi[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",BandEdge,Price,LevelUp,LevelDown,ColorOn,1,y); 
                     levdn[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",BandEdge,Price,LevelUp,LevelDown,ColorOn,2,y);
                     unio[i]   = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",BandEdge,Price,LevelUp,LevelDown,ColorOn,3,y);
                     trend[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",BandEdge,Price,LevelUp,LevelDown,ColorOn,8,y); 
                     unioDa[i] = EMPTY_VALUE;
                     unioDb[i] = EMPTY_VALUE;
                     unioUa[i] = EMPTY_VALUE;
                     unioUb[i] = EMPTY_VALUE;
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                        int n,j; datetime time = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                           for(j = 1; j<n && (i+n)<Bars && (i+j)<Bars; j++)
                           {
                              levup[i+j] = levup[i] + (levup[i+n] - levup[i])*j/n;
                              levmi[i+j] = levmi[i] + (levmi[i+n] - levmi[i])*j/n;
                              levdn[i+j] = levdn[i] + (levdn[i+n] - levdn[i])*j/n;
                              unio[i+j]  = unio[i]  + (unio[i+n]  - unio[i] )*j/n;
                           }
               }
               for(int i=limit; i>=0; i--)
               {
                  if (i <Bars-1 && trend[i] ==  1) PlotPoint(i,unioUa,unioUb,unio); 
                  if (i <Bars-1 && trend[i] == -1) PlotPoint(i,unioDa,unioDb,unio); 
               }
               return(0);
            }

   //
   //
   //
   //
   //

     if (trend[limit]== 1) CleanPoint(limit,unioUa,unioUb);
     if (trend[limit]==-1) CleanPoint(limit,unioDa,unioDb);
     for (int i=limit; i>=0; i--)
     {  
         price[i] = getPrice(Price,Open,Close,High,Low,i);
            if (i>=Bars-3) { peak[i] = 0; continue; }
            double whiteNoise = (price[i]-price[i+2])/2.0;
            double filter     = iSsm(whiteNoise,BandEdge,i);
                   peak[i]    = 0.991*peak[i+1];
                   if (MathAbs(filter)>peak[i]) peak[i] = MathAbs(filter);
                   unio[i] = filter/peak[i];
            
            levup[i]  = LevelUp;
            levmi[i]  = 0;
            levdn[i]  = LevelDown;
            unioDa[i] = EMPTY_VALUE;
            unioDb[i] = EMPTY_VALUE;
            unioUa[i] = EMPTY_VALUE;
            unioUb[i] = EMPTY_VALUE;
            trend[i]   = 0;
            switch(ColorOn)
            {
               case cc_onLevels:
                  if (unio[i]>levup[i]) trend[i] =  1;
                  if (unio[i]<levdn[i]) trend[i] = -1;
                  break;
               case cc_onMiddle:                  
                  if (unio[i]>levmi[i]) trend[i] =  1;
                  if (unio[i]<levmi[i]) trend[i] = -1;
                  break;
               default :
                  if (i<Bars-1)
                  {
                     if (unio[i]>unio[i+1]) trend[i] =  1;
                     if (unio[i]<unio[i+1]) trend[i] = -1;
                  }                  
            }                  
         
         //
         //
         //
         //
         //
         
         if (trend[i] ==  1) PlotPoint(i,unioUa,unioUb,unio);
         if (trend[i] == -1) PlotPoint(i,unioDa,unioDb,unio);
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


#define Pi 3.14159265358979323846264338327950288
double workSsm[][2];
#define _tprice  0
#define _ssm     1

double workSsmCoeffs[][4];
#define _speriod 0
#define _sc1    1
#define _sc2    2
#define _sc3    3

double iSsm(double tprice, double period, int i, int instanceNo=0)
{
   if (period<=1) return(tprice);
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_speriod] != period)
   {
      workSsmCoeffs[instanceNo][_speriod] = period;
      double a1 = MathExp(-1.414*Pi/period);
      double b1 = 2.0*a1*MathCos(1.414*Pi/period);
         workSsmCoeffs[instanceNo][_sc2] = b1;
         workSsmCoeffs[instanceNo][_sc3] = -a1*a1;
         workSsmCoeffs[instanceNo][_sc1] = 1.0 - workSsmCoeffs[instanceNo][_sc2] - workSsmCoeffs[instanceNo][_sc3]; 
   }

   //
   //
   //
   //
   //

      int s = instanceNo*2; i=Bars-i-1;
      workSsm[i][s+_ssm]    = tprice;
      workSsm[i][s+_tprice] = tprice;
      if (i>1)
      {  
          workSsm[i][s+_ssm] = workSsmCoeffs[instanceNo][_sc1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_tprice])/2.0 + 
                               workSsmCoeffs[instanceNo][_sc2]*workSsm[i-1][s+_ssm]                                + 
                               workSsmCoeffs[instanceNo][_sc3]*workSsm[i-2][s+_ssm]; }
   return(workSsm[i][s+_ssm]);
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

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
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

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
