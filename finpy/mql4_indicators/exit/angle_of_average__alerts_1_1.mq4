//+------------------------------------------------------------------+
//|                                             Angle of average.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property  copyright "mladen"

#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  clrDeepSkyBlue
#property  indicator_color2  clrSandyBrown
#property  indicator_color3  clrDimGray
#property  indicator_color4  clrGray
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width4  2
#property  strict


//
//
//
//
//

enum maTypes
{
   ma_sma,  // Simple moving average
   ma_ema,  // Exponential moving average
   ma_smma, // Smoothed moving average
   ma_lwma, // Linear weighted moving average
   ma_lsma  // Linear regression value (lsma)
};
extern int                MAPeriod         =  34;    // Average period
extern maTypes            MAType           = ma_ema; // Average type to use
extern ENUM_APPLIED_PRICE MAAppliedPrice   =   0;    // Price to use
extern double             AngleLevel       =   8;    // Angle treshold level
extern int                AngleBars        =   6;    // Bars used for angle normalization
extern bool               alertsOn         = false;  // Turn alerts on?
extern bool               alertsOnCurrent  = false;  // Alerts on current (still opened) bar?
extern bool               alertsMessage    = true;   // Alerts should display pop-up message?
extern bool               alertsSound      = false;  // Alert should play alerts sound?
extern bool               alertsNotify     = false;  // Alerts should send push notification?
extern bool               alertsEmail      = false;  // Alerts should send email?

//
//
//
//
//

double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double state[];


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
   IndicatorBuffers(5);
   SetIndexBuffer(0,Buffer1);
   SetIndexBuffer(1,Buffer2);
   SetIndexBuffer(2,Buffer3);
   SetIndexBuffer(3,Buffer4);
   SetIndexBuffer(4,state);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
      SetLevelValue(0, AngleLevel);
      SetLevelValue(1,-AngleLevel);
   
   //
   //
   //
   //
   //
      
   string  MAsType;
   switch ((int)MAType)
   {
      case 1:  MAsType="EMA";  break;
      case 2:  MAsType="SMMA"; break;
      case 3:  MAsType="LWMA"; break;
      case 4:  MAsType="LSMA"; break;
      default: MAsType="SMA";  break;
   }
   IndicatorShortName(MAsType+" angle ("+(string)MAPeriod+","+(string)AngleLevel+","+(string)AngleBars+")");
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
      limit = MathMin(Bars-countedBars,Bars-1);

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
         if (MAType == 4)
               change = iLSMA(MAPeriod,MAAppliedPrice,i)-iLSMA(MAPeriod,MAAppliedPrice,i+AngleBars);
         else  change = iMA(NULL,0,MAPeriod,0,(int)MAType,MAAppliedPrice,i)-iMA(NULL,0,MAPeriod,0,(int)MAType,MAAppliedPrice,i+AngleBars);

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
         state[i]   = 0;
            if (angle >  AngleLevel) { Buffer1[i] = angle; Buffer3[i] = EMPTY_VALUE; state[i] =  1;}
            if (angle < -AngleLevel) { Buffer2[i] = angle; Buffer3[i] = EMPTY_VALUE; state[i] = -1;}
   }
   manageAlerts();
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;

      //
      //
      //
      //
      //
      
         if (state[whichBar] != state[whichBar+1])
         {
            if (state[whichBar] == 1)                            doAlert(whichBar," Angle crossed "+DoubleToStr( AngleLevel,2)+" up");
            if (state[whichBar] == 0 && state[whichBar+1] == 1)  doAlert(whichBar," Angle crossed "+DoubleToStr( AngleLevel,2)+" down");
            if (state[whichBar] == -1)                           doAlert(whichBar," Angle crossed "+DoubleToStr(-AngleLevel,2)+" down");
            if (state[whichBar] == 0 && state[whichBar+1] == -1) doAlert(whichBar," Angle crossed "+DoubleToStr(-AngleLevel,2)+" up");
         }         
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS),doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(StringConcatenate(Symbol(), Period() ," Angle of average : " +message));
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," - Angle of average"),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}