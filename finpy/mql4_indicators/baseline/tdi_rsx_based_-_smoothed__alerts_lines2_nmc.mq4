//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DodgerBlue
#property indicator_color2  Gold
#property indicator_color3  DodgerBlue
#property indicator_color4  LimeGreen
#property indicator_color5  Red
#property indicator_width2  2
#property indicator_width4  2
#property indicator_levelcolor DimGray

extern string TimeFrame                = "Current time frame";
extern int    RsxPeriod                = 14;
extern int    RsxPrice                 = PRICE_CLOSE;
extern double RsxPriceLinePeriod       = 1;
extern double RsxPriceLinePhase        = 0;
extern bool   RsxPriceLineDouble       = false;
extern double RsxSignalLinePeriod      = 7;
extern double RsxSignalLinePhase       = 0;
extern bool   RsxSignalLineDouble      = false;
extern int    VolatilityBandPeriod     = 34;
extern int    VolatilityBandMAMode     = MODE_SMA;
extern double VolatilityBandMultiplier = 1.6185;
extern double LevelDown                = 32;
extern double LevelMiddle              = 50;
extern double LevelUp                  = 68;
extern bool   Interpolate              = true;

extern bool   alertsOn                 = false;
extern bool   alertsOnCurrent          = true;
extern bool   alertsMessage            = true;
extern bool   alertsSound              = false;
extern bool   alertsEmail              = false;
extern bool   ShowArrows               = false;
extern string arrowsIdentifier         = "TDI arrows";
extern color  arrowsUpColor            = DeepSkyBlue;
extern color  arrowsDnColor            = Red;

extern bool   verticalLinesVisible     = true;
extern string verticalLinesID          = "TDI_Line";
extern color  verticalLinesUpColor     = DeepSkyBlue;
extern color  verticalLinesDownColor   = PaleVioletRed;
extern int    verticalLinesStyle       = STYLE_DOT;
extern int    verticalLinesWidth       = 0;

extern bool   StrictRules              = true;

double rsx[];
double rsxPriceLine[];
double rsxSignalLine[];
double bandUp[];
double bandMiddle[];
double bandDown[];
double trend[];

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init() {
   IndicatorBuffers(7);
   SetIndexBuffer(0,bandUp);
   SetIndexBuffer(1,bandMiddle);
   SetIndexBuffer(2,bandDown);
   SetIndexBuffer(3,rsxPriceLine);
   SetIndexBuffer(4,rsxSignalLine);
   SetIndexBuffer(5,rsx);
   SetIndexBuffer(6,trend);

   // HIDE LIVE BUFFER DATA FROM SHOWING
   SetIndexLabel(0, NULL);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   SetIndexLabel(3, "rsxPriceLine");
   SetIndexLabel(4, "rsxSignalLine");
   SetIndexLabel(5, NULL);
   SetIndexLabel(6, NULL);
   
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);

   SetLevelValue(0,LevelUp);
   SetLevelValue(1,LevelMiddle);
   SetLevelValue(2,LevelDown);
   IndicatorShortName(timeFrameToString(timeFrame)+" - TDI RSX ("+RsxPeriod+")");
   deinit();
   return (0);
}

 
int deinit() {
   string lookFor       = verticalLinesID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--) {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   if (!calculateValue && ShowArrows) deleteArrows();
   return(0);
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double wrkBuffer[][13];

int start() {
   int i,k,n,r,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { bandUp[0] = limit+1; return(0); }

   if (calculateValue || timeFrame == Period())
   {
      if (ArrayRange(wrkBuffer,0) != Bars) ArrayResize(wrkBuffer,Bars);
      
      double Kg = (3.0)/(2.0+RsxPeriod); 
      double Hg = 1.0-Kg;
      for(i=limit, r=Bars-i-1; i>=0; i--, r++)
      {
         wrkBuffer[r][12] = iMA(NULL,0,1,0,MODE_SMA,RsxPrice,i);

            if (i==(Bars-1)) { for (int c=0; c<12; c++) wrkBuffer[r][c] = 0; continue; }  
   
         double mom = wrkBuffer[r][12]-wrkBuffer[r-1][12];
         double moa = MathAbs(mom);
         for (k=0; k<3; k++)
         {
            int kk = k*2;
               wrkBuffer[r][kk+0] = Kg*mom                + Hg*wrkBuffer[r-1][kk+0];
               wrkBuffer[r][kk+1] = Kg*wrkBuffer[r][kk+0] + Hg*wrkBuffer[r-1][kk+1]; mom = 1.5*wrkBuffer[r][kk+0] - 0.5 * wrkBuffer[r][kk+1];
               wrkBuffer[r][kk+6] = Kg*moa                + Hg*wrkBuffer[r-1][kk+6];
               wrkBuffer[r][kk+7] = Kg*wrkBuffer[r][kk+6] + Hg*wrkBuffer[r-1][kk+7]; moa = 1.5*wrkBuffer[r][kk+6] - 0.5 * wrkBuffer[r][kk+7];
         }
         if (moa != 0)
              rsx[i] = MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00); 
         else rsx[i] = 50.0;
      }
      for(i=limit; i>=0; i--)
      {
         rsxPriceLine[i]  = iDSmooth(rsx[i],RsxPriceLinePeriod ,RsxPriceLinePhase ,RsxPriceLineDouble ,i, 0);
         rsxSignalLine[i] = iDSmooth(rsx[i],RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,i,20);
             double deviation = iStdDevOnArray(rsx,0,VolatilityBandPeriod,0,VolatilityBandMAMode,i);
             double average   = iMAOnArray(rsx,0,VolatilityBandPeriod,0,VolatilityBandMAMode,i);
                bandUp[i]     = average+VolatilityBandMultiplier*deviation;
                bandDown[i]   = average-VolatilityBandMultiplier*deviation;
                bandMiddle[i] = average;
         trend[i] = trend[i+1];
            
            if (rsxPriceLine[i]>rsxSignalLine[i]) trend[i] =  1;
            if (rsxPriceLine[i]<rsxSignalLine[i]) trend[i] = -1;
            
            //if (rsxPriceLine[i]>bandUp[i])   trend[i] =  1;
            //if (rsxPriceLine[i]<bandDown[i]) trend[i] = -1;
            
            if (!calculateValue) manageLines(i);
            if (!calculateValue) manageArrow(i);
      }
      manageAlerts();
      return (0);
   }      

   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         bandUp[i]        = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,0,y);
         bandMiddle[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,1,y);
         bandDown[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,2,y);
         rsxPriceLine[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,3,y);
         rsxSignalLine[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,4,y);
         trend[i]         = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,6,y);
            
         manageArrow(i);
         manageLines(i);

         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         datetime time = iTime(NULL,timeFrame,y);
            for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(k = 1; k < n; k++)
            {
               bandUp[i+k]        = bandUp[i]        + (bandUp[i+n]        - bandUp[i]       )*k/n;
               bandMiddle[i+k]    = bandMiddle[i]    + (bandMiddle[i+n]    - bandMiddle[i]   )*k/n;
               bandDown[i+k]      = bandDown[i]      + (bandDown[i+n]      - bandDown[i]     )*k/n;
               rsxPriceLine[i+k]  = rsxPriceLine[i]  + (rsxPriceLine[i+n]  - rsxPriceLine[i] )*k/n;
               rsxSignalLine[i+k] = rsxSignalLine[i] + (rsxSignalLine[i+n] - rsxSignalLine[i])*k/n;
            }               
   }
   manageAlerts();
   return(0);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------

void manageAlerts() {
   if (!calculateValue && alertsOn) {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1]) {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
      }
   }
}

void doAlert(int forBar, string doWhat) {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," TDI trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"TDI"),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void manageArrow(int i) {
   if (ShowArrows) {
      deleteArrow(Time[i]);
      if (trend[i]!=trend[i+1]) {
         if (trend[i] == 1) drawArrow(i,arrowsUpColor,241,false);
         if (trend[i] ==-1) drawArrow(i,arrowsDnColor,242,true);
      }
   }
}               

void drawArrow(int i,color theColor,int theCode,bool up) {
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
}

void deleteArrows() {
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--) {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

void deleteArrow(datetime time) {
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs) {
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf) {
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

string stringUpperCase(string str) {
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--) {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double wrk[][40];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s=0) {
   if (isDouble)
         return (iSmooth(iSmooth(price,MathSqrt(length),phase,i,s),MathSqrt(length),phase,i,s+10));
   else  return (iSmooth(price,length,phase,i,s));
}

double iSmooth(double price, double length, double phase, int i, int s=0) {
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            if (wrk[r][avolty+s] > 0)
               double dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   return(wrk[r][4+s]);
}

void manageLines(int i) {
   if (!calculateValue && verticalLinesVisible) {
         deleteLine(Time[i]);
         if (trend[i]!=trend[i+1]) {
            if (StrictRules) {
               if (trend[i] == 1 && rsxPriceLine[i] < 50) drawLine(i,verticalLinesUpColor);
               if (trend[i] ==-1 && rsxPriceLine[i] > 50) drawLine(i,verticalLinesDownColor);
            } else {
               if (trend[i] == 1 ) drawLine(i,verticalLinesUpColor);
               if (trend[i] ==-1 ) drawLine(i,verticalLinesDownColor);
            }
         }
   }
}               

void drawLine(int i,color theColor) {
   string name = verticalLinesID+":"+Time[i];
   
      ObjectCreate(name,OBJ_VLINE,0,Time[i],0);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_STYLE,verticalLinesStyle);
         ObjectSet(name,OBJPROP_WIDTH,verticalLinesWidth);
         ObjectSet(name,OBJPROP_BACK,true);
}

void deleteLine(datetime time) {
   string lookFor = verticalLinesID+":"+time; ObjectDelete(lookFor);
}

