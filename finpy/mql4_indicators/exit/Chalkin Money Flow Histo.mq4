//+------------------------------------------------------------------
//|                                                      CMF.mq4 
//+------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  LimeGreen
#property indicator_color2  Red
#property indicator_width1  2
#property indicator_width2  2
#property indicator_minimum 0
#property indicator_maximum 1

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern double CmfPeriod       = 20;
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

double cmf[];
double cmfUpa[];
double cmfDna[];
double trend[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
// 
//
//
//
//

int init()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,cmfUpa); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,cmfDna); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,cmf);
   SetIndexBuffer(3,trend);
   
         //
         //
         //
         //
         //
      
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame=="returnBars";        if (returnBars)     return(0);
         calculateValue    = TimeFrame=="calculateValue";    if (calculateValue) return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);

         //
         //
         //
         //
         //
            
   
   IndicatorShortName(timeFrameToString(timeFrame)+" Chalkin Money Flow");
return(0);
}

//
//
//
//
//

int deinit() {   return(0);  }

//
//
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { cmfUpa[0] = limit+1; return(0); }

   
   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame == Period())
   {
      for (i=limit;i>=0;i--)
      {
          if((High[i]-Low[i]) != 0 && Volume[i] !=0)
               cmf[i] = (Volume[i]*(Close[i]-Open[i])/(High[i]-Low[i]))/Volume[i];
          else cmf[i] =  0;
               
               //
               //
               //
               //
               //
               
               cmfUpa[i] = EMPTY_VALUE;
               cmfDna[i] = EMPTY_VALUE;
               trend[i]  = trend[i+1];
                if (cmf[i] > 0)   trend[i]  = 1;
                if (cmf[i] < 0)   trend[i]  =-1;
                if (trend[i]== 1) cmfUpa[i] = 1;
                if (trend[i]==-1) cmfDna[i] = 1;
                 
      }
      manageAlerts();
      return(0);
   }      
  
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         trend[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",CmfPeriod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,3,y);
         cmfUpa[i] = EMPTY_VALUE;
         cmfDna[i] = EMPTY_VALUE;
         if (trend[i]== 1) cmfUpa[i] = 1;
         if (trend[i]==-1) cmfDna[i] = 1;

   }
   return(0);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
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
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Chalkin Money Flow changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Chalkin Money Flow"),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
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
      int chr = StringGetChar(s, length);
         if((chr > 96 && chr < 123) || (chr > 223 && chr < 256))
                     s = StringSetChar(s, length, chr - 32);
         else if(chr > -33 && chr < 0)
                     s = StringSetChar(s, length, chr + 224);
   }
   return(s);
}


