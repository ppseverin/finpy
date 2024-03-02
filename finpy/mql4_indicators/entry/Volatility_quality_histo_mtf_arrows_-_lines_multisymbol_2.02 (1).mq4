//+------------------------------------------------------------------+
//|                                           Volatility quality.mq4 |
//|                                                                  |
//|                                                                  |
//| Volatility quality index originaly developed by                  |
//| Thomas Stridsman (August 2002 Active Trader Magazine)            |
//|                                                                  |
//| Price pre-smoothing and filter added by raff1410                 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers  5
#property indicator_color1   LimeGreen
#property indicator_color2   Orange
#property indicator_color3   DarkSlateGray
#property indicator_color4   Blue
#property indicator_color5   Red
#property indicator_width1   2
#property indicator_width2   2
#property indicator_width3   2

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame              = PERIOD_CURRENT;
extern string          ForSymbol              = "";               // Symbol to use (leave empty for current symbol)
extern int             PriceSmoothing         = 5;
extern ENUM_MA_METHOD  PriceSmoothingMethod   = MODE_LWMA;
extern double          FilterInPips           = 2.0;
extern bool            alertsOn               = false;
extern bool            alertsOnCurrent        = true;
extern bool            alertsMessage          = true;
extern bool            alertsSound            = false;
extern bool            alertsEmail            = false;
extern bool            ShowArrows             = true;
extern bool            arrowsOnFirst          = false;
extern string          arrowsIdentifier       = "vq Arrows1";
extern double          arrowsUpperGap         = 0.5;
extern double          arrowsLowerGap         = 0.5;
extern color           arrowsUpColor          = LimeGreen;
extern color           arrowsDnColor          = Red;
extern int             arrowsUpCode           = 225;
extern int             arrowsDnCode           = 226;
extern int             arrowsUpSize           = 2;
extern int             arrowsDnSize           = 2;
extern bool            verticalLinesVisible   = false;
extern bool            linesOnFirst           = true;
extern string          verticalLinesID        = "vq Lines";
extern color           verticalLinesUpColor   = DeepSkyBlue;
extern color           verticalLinesDnColor   = PaleVioletRed;
extern int             verticalLinesStyle     = STYLE_DOT;
extern int             verticalLinesWidth     = 0;
extern bool            Interpolate            = true;

extern int             DotSize                = 3;
extern bool            DotsOnFirst            = true;

//
//
//
//
//

double sumVqi[];
double sumVqida[];
double sumVqidb[];
double CrossUp[];
double CrossDn[];
double Vqi[];
double trend[];
string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(7);
      SetIndexBuffer(0,sumVqida); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,sumVqidb); SetIndexStyle(1,DRAW_HISTOGRAM); 
      SetIndexBuffer(2,sumVqi);
      SetIndexBuffer(3,CrossUp); SetIndexStyle(3,DRAW_ARROW,0,DotSize); SetIndexArrow(3,159);
      SetIndexBuffer(4,CrossDn); SetIndexStyle(4,DRAW_ARROW,0,DotSize); SetIndexArrow(4,159);  
      SetIndexBuffer(5,Vqi); 
      SetIndexBuffer(6,trend);
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame==-98;
      PriceSmoothing    = MathMax(PriceSmoothing,1);
      TimeFrame         = MathMax(TimeFrame,_Period);
      ForSymbol         = (ForSymbol=="") ? _Symbol : ForSymbol; 
      IndicatorShortName(timeFrameToString(TimeFrame)+" "+ ForSymbol+" Volatility Quality");
   return(0);
}
int deinit() 
{ 
   deleteArrows();
   deleteLines();
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
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { sumVqida[0] = MathMin(limit+1,Bars-1); return(0); }
         double pipMultiplier = MathPow(10,_Digits%2);
         
   //
   //
   //
   //
   //
            
   if (TimeFrame == _Period)
   {        
     for(int i=limit; i>=0; i--)
     {
       if (i==(Bars-1))
       {
         Vqi[i]    = 0;
         sumVqi[i] = 0;
         continue;
      }
      
      //
      //
      //
      //
      //
      
      double cHigh  = iMA(ForSymbol,0,PriceSmoothing,0,PriceSmoothingMethod,PRICE_HIGH ,i);
      double cLow   = iMA(ForSymbol,0,PriceSmoothing,0,PriceSmoothingMethod,PRICE_LOW  ,i);
      double cOpen  = iMA(ForSymbol,0,PriceSmoothing,0,PriceSmoothingMethod,PRICE_OPEN ,i);
      double cClose = iMA(ForSymbol,0,PriceSmoothing,0,PriceSmoothingMethod,PRICE_CLOSE,i);
      double pClose = iMA(ForSymbol,0,PriceSmoothing,0,PriceSmoothingMethod,PRICE_CLOSE,i+1);
         
      double trueRange = MathMax(cHigh,pClose)-MathMin(cLow,pClose);
      double     range = cHigh-cLow;
      
         if (range != 0 && trueRange!=0)
            double vqi = ((cClose-pClose)/trueRange + (cClose-cOpen)/range)*0.5;
         else      vqi = Vqi[i+1];

      //
      //
      //
      //
      //
         
      Vqi[i]      = MathAbs(vqi)*(cClose-pClose+cClose-cOpen)*0.5;
      sumVqi[i]   = sumVqi[i+1]+Vqi[i];
      sumVqida[i] = EMPTY_VALUE;
      sumVqidb[i] = EMPTY_VALUE;
         if (FilterInPips > 0) if (MathAbs(sumVqi[i]-sumVqi[i+1]) < FilterInPips*pipMultiplier*Point) sumVqi[i] = sumVqi[i+1];
      
      //
      //
      //
      //
      //
      
      trend[i] = trend[i+1];
         if (sumVqi[i] > sumVqi[i+1]) trend[i] =  1;
         if (sumVqi[i] < sumVqi[i+1]) trend[i] = -1;
         if (trend[i] == 1) sumVqida[i] = sumVqi[i]; 
         if (trend[i] ==-1) sumVqidb[i] = sumVqi[i];
         
         //
         //
         //
         //
         //
         
         CrossUp[i] = EMPTY_VALUE;
         CrossDn[i] = EMPTY_VALUE;
         if (trend[i] !=trend[i+1])
         if (trend[i] == 1)
              CrossUp[i] = sumVqi[i];
         else CrossDn[i] = sumVqi[i]; 
         
         //
         //
         //
         //
         //
                  
         if (ShowArrows)
         {
            deleteArrow(Time[i]);
            if (trend[i]!=trend[i+1])
            {
               if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
               if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
            }
         } 
         
         //
         //
         //
         //
         //
         
         if (verticalLinesVisible)
         {
           deleteLine(Time[i]);
           if (trend[i]!=trend[i+1])
           {
              if (trend[i] == 1) drawLine(i,verticalLinesUpColor);
              if (trend[i] ==-1) drawLine(i,verticalLinesDnColor);
           }
         } 
   }
   manageAlerts();
   return(0);
   }
   
   //
   //
   //
   //
   //
   
   int displace = -1; if (DotsOnFirst) displace = 1;
   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(ForSymbol,TimeFrame,indicatorFileName,-98,0,0)*TimeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(ForSymbol,TimeFrame,Time[i]);
      int x = iBarShift(ForSymbol,TimeFrame,Time[i+displace]);
      SetIndexBuffer(0,sumVqida); 
      SetIndexBuffer(1,sumVqidb); 
      SetIndexBuffer(2,sumVqi); 
      SetIndexBuffer(3,CrossUp); 
      SetIndexBuffer(4,CrossDn); 
      SetIndexBuffer(6,trend); 

         sumVqi[i]   = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",PriceSmoothing,PriceSmoothingMethod,FilterInPips,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,arrowsOnFirst,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,verticalLinesVisible,linesOnFirst,verticalLinesID,verticalLinesUpColor,verticalLinesDnColor,verticalLinesStyle,verticalLinesWidth,2,y);
         trend[i]    = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",PriceSmoothing,PriceSmoothingMethod,FilterInPips,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,arrowsOnFirst,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,verticalLinesVisible,linesOnFirst,verticalLinesID,verticalLinesUpColor,verticalLinesDnColor,verticalLinesStyle,verticalLinesWidth,6,y);
         sumVqida[i] = EMPTY_VALUE;
         sumVqidb[i] = EMPTY_VALUE;
         if (trend[i] == 1) sumVqida[i] = sumVqi[i]; 
         if (trend[i] ==-1) sumVqidb[i] = sumVqi[i];   
       if (x!=y)
       {    
         CrossUp[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",PriceSmoothing,PriceSmoothingMethod,FilterInPips,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,arrowsOnFirst,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,verticalLinesVisible,linesOnFirst,verticalLinesID,verticalLinesUpColor,verticalLinesDnColor,verticalLinesStyle,verticalLinesWidth,3,y);
         CrossDn[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",PriceSmoothing,PriceSmoothingMethod,FilterInPips,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,arrowsOnFirst,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,verticalLinesVisible,linesOnFirst,verticalLinesID,verticalLinesUpColor,verticalLinesDnColor,verticalLinesStyle,verticalLinesWidth,4,y);
       }
       else
       {
         CrossUp[i]  = EMPTY_VALUE;
         CrossDn[i]  = EMPTY_VALUE;
       }
       
       //
       //
       //
       //
       //
               
       if (!Interpolate || y==iBarShift(ForSymbol,TimeFrame,Time[i-1])) continue;
       datetime time = iTime(ForSymbol,TimeFrame,y);
          for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
          for(int k = 1; k < n; k++)
          {
             sumVqi [i+k] = sumVqi [i] + (sumVqi [i+n] - sumVqi [i])*k/n;
             if (sumVqida[i]!= EMPTY_VALUE) sumVqida[i+k] = sumVqi[i+k];
             if (sumVqidb[i]!= EMPTY_VALUE) sumVqidb[i+k] = sumVqi[i+k];
          }               
   }
   return(0);         
}


//
//
//
//
//


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
//
//
//
//
//


void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," VQ changed direction to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," VQ"),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

void drawArrow(int i,color theColor,int theCode,int theWidth,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
      //
      //
      //
      //
      //
      
      int add = 0; if (!arrowsOnFirst) add = _Period*60-1;
      ObjectCreate(name,OBJ_ARROW,0,Time[i]+add,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theWidth);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+ arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}
void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

//
//
//
//
//

void drawLine(int i,color theColor)
{
      string name = verticalLinesID+":"+Time[i];
   
      //
      //
      //
      //
      //
      
      int add = 0; if (!linesOnFirst) add = _Period*60-1;
      ObjectCreate(name,OBJ_VLINE,0,Time[i]+add,0);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_STYLE,verticalLinesStyle);
         ObjectSet(name,OBJPROP_WIDTH,verticalLinesWidth);
         ObjectSet(name,OBJPROP_BACK,true);
}

//
//
//
//
//

void deleteLines()
{
   string lookFor       = verticalLinesID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

//
//
//
//
//

void deleteLine(datetime time)
{
   string lookFor = verticalLinesID+":"+time; ObjectDelete(lookFor);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
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






