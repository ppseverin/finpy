//+------------------------------------------------------------------+
//|                                                     Triggerlines |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

//
//
//
//
//

#property indicator_chart_window
#property indicator_buffers 6            
#property indicator_color1  Aqua      
#property indicator_color2  Magenta
#property indicator_color3  Magenta
#property indicator_color4  Aqua      
#property indicator_color5  Magenta
#property indicator_color6  Magenta
#property indicator_width1  2      
#property indicator_width2  2  
#property indicator_width3  2  
#property indicator_width4  2  
#property indicator_width5  2  
#property indicator_width6  2  

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern int    LsmaPeriod      = 50;
extern int    LsmaPrice       = 0;
extern int    AdaptPeriod     = 21;
extern bool   MultiColor      = true;

extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

//
//
//
//
//

double lsma[];
double lsmaUa[];
double lsmaUb[];
double lwma[];
double lwmaUa[];
double lwmaUb[];
double lstrend[];
double lwtrend[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
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

   IndicatorBuffers(8);   
   SetIndexBuffer(0,lsma);
   SetIndexBuffer(1,lsmaUa);
   SetIndexBuffer(2,lsmaUb);
   SetIndexBuffer(3,lwma);
   SetIndexBuffer(4,lwmaUa);
   SetIndexBuffer(5,lwmaUb);
   SetIndexBuffer(6,lstrend);        
   SetIndexBuffer(7,lwtrend);         
   
   //
   //
   //
   //
   //
   
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
      
   //
   //
   //
   //
   //
       
   IndicatorShortName(timeFrameToString(timeFrame)+" Triggerlines");
 return(0);
}

//
//
//
//
//

int start() 
{
   int counted_bars=IndicatorCounted();
   int limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { lsma[0] = limit+1; return(0); }
    
   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
     if (MultiColor && !calculateValue && lstrend[limit]==-1) CleanPoint(limit,lsmaUa,lsmaUb);
     if (MultiColor && !calculateValue && lwtrend[limit]==-1) CleanPoint(limit,lwmaUa,lwmaUb);      
     for (int i=limit; i>=0; i--)
     {
        double dev = iStdDev(NULL,0,AdaptPeriod,0,MODE_SMA,PRICE_CLOSE,i);
        double avg = iSma(dev,AdaptPeriod,i,0);
         if (dev!=0) 
                double period = LsmaPeriod*avg/dev;
         else          period = LsmaPeriod; 
         if (period<3) period = 3;
         
         //
         //
         //
         //
         //
         
         lsma[i]    = 3.0 * iSmooth(iMA(NULL,0,1,0,MODE_LWMA,LsmaPrice,i),period,i) - 2.0 * 
                            iSmooth(iMA(NULL,0,1,0,MODE_LWMA,LsmaPrice,i),period,i);
         lsmaUa[i]  = EMPTY_VALUE;
         lsmaUb[i]  = EMPTY_VALUE;
         lwmaUa[i]  = EMPTY_VALUE;
         lwmaUb[i]  = EMPTY_VALUE;
         lwma[i]    = lsma[i+1];
         lstrend[i] = lstrend[i+1]; 
         lwtrend[i] = lwtrend[i+1];
       
         if (lsma[i] > lsma[i+1]) lstrend[i] =  1;
         if (lsma[i] < lsma[i+1]) lstrend[i] = -1;
         if (lwma[i] > lwma[i+1]) lwtrend[i] =  1;
         if (lwma[i] < lwma[i+1]) lwtrend[i] = -1;
       
         if (MultiColor && !calculateValue && lstrend[i]==-1) PlotPoint(i,lsmaUa,lsmaUb,lsma);
         if (MultiColor && !calculateValue && lwtrend[i]==-1) PlotPoint(i,lwmaUa,lwmaUb,lwma); 
       
       }      
       
      manageAlerts();
      return(0);
      }
      
      //
      //
      //
      //
      //
   
      limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
      if (MultiColor && lstrend[limit]==-1) CleanPoint(limit,lsmaUa,lsmaUb);
      if (MultiColor && lwtrend[limit]==-1) CleanPoint(limit,lwmaUa,lwmaUb);  
      for (i=limit;i>=0; i--)
      {
         int y = iBarShift(NULL,timeFrame,Time[i]);
             lsma[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",LsmaPeriod,LsmaPrice,AdaptPeriod,0,y);
             lsmaUa[i] = EMPTY_VALUE;
             lsmaUb[i] = EMPTY_VALUE;
             lwma[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",LsmaPeriod,LsmaPrice,AdaptPeriod,3,y);
             lwmaUa[i] = EMPTY_VALUE;
             lwmaUb[i] = EMPTY_VALUE;
             lstrend[i]= iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",LsmaPeriod,LsmaPrice,AdaptPeriod,6,y);
             lwtrend[i]= iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",LsmaPeriod,LsmaPrice,AdaptPeriod,7,y);      
       }
       if (MultiColor) for (i=limit;i>=0;i--) if (lstrend[i]==-1) PlotPoint(i,lsmaUa,lsmaUb,lsma);
       if (MultiColor) for (i=limit;i>=0;i--) if (lwtrend[i]==-1) PlotPoint(i,lwmaUa,lwmaUb,lwma);
       manageAlerts();
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

double workSmooth[][10];
double iSmooth(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(workSmooth,0)!=Bars) ArrayResize(workSmooth,Bars); instanceNo *= 5; r = Bars-r-1;
 	if(r<=2) { workSmooth[r][instanceNo] = price; workSmooth[r][instanceNo+2] = price; workSmooth[r][instanceNo+4] = price; return(price); }
   
   //
   //
   //
   //
   //
   
	double alpha = 0.45*(length-1.0)/(0.45*(length-1.0)+2.0);
   	  workSmooth[r][instanceNo+0] =  price+alpha*(workSmooth[r-1][instanceNo]-price);
	     workSmooth[r][instanceNo+1] = (price - workSmooth[r][instanceNo])*(1-alpha)+alpha*workSmooth[r-1][instanceNo+1];
	     workSmooth[r][instanceNo+2] =  workSmooth[r][instanceNo+0] + workSmooth[r][instanceNo+1];
	     workSmooth[r][instanceNo+3] = (workSmooth[r][instanceNo+2] - workSmooth[r-1][instanceNo+4])*MathPow(1.0-alpha,2) + MathPow(alpha,2)*workSmooth[r-1][instanceNo+3];
	     workSmooth[r][instanceNo+4] =  workSmooth[r][instanceNo+3] + workSmooth[r-1][instanceNo+4]; 
   return(workSmooth[r][instanceNo+4]);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

double workSma[][2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2; r = Bars-r-1;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo] = price;
   if (r>=period)
          workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   else { workSma[r][instanceNo+1] = 0; for(int k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= k; }
   return(workSma[r][instanceNo+1]);
}

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
   tfs = stringUpperCase(tfs);
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

string stringUpperCase(string str)
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

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}

//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));

      //
      //
      //
      //
      //
            
      static datetime time1 = 0;
      static string   mess1 = "";
      if(lstrend[whichBar] != lstrend[whichBar+1])
      {
        if (lstrend[whichBar] ==  1) doAlert(time1,mess1,whichBar,"changed slope to up");
        if (lstrend[whichBar] == -1) doAlert(time1,mess1,whichBar,"changed slope to down");
      }
      static datetime time2 = 0;
      static string   mess2 = "";
      if(lwtrend[whichBar] != lwtrend[whichBar+1])
      {
         if (lwtrend[whichBar] ==  1) doAlert(time2,mess2,whichBar,"changed slope to up");
         if (lwtrend[whichBar] == -1) doAlert(time2,mess2,whichBar,"changed slope to down");
      }
   }
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Triggerlines ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Triggerlines "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}



