//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4

//
//
//
//
//

extern int    FastEMA          = 12;
extern int    SlowEMA          = 26;
extern int    SignalEMA        =  9;
extern int    Price            = PRICE_CLOSE;
extern color  ColorUp          = Green;
extern color  ColorNeutralUp   = Lime;
extern color  ColorDown        = Red;
extern color  ColorNeutralDown = Yellow;
 double Dummy            = -1;

//---- indicator buffers
double UpBuffer[];
double Up2Buffer[];
double DownBuffer[];
double Down2Buffer[];

double macd[];
double signal[];
double colors[];


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int init()
{
//---- 3 additional buffers are used for counting.
   IndicatorBuffers(7);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,Up2Buffer);
   SetIndexBuffer(2,DownBuffer);
   SetIndexBuffer(3,Down2Buffer);
   
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2,ColorUp);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2, ColorNeutralUp);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2, ColorDown);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,2, ColorNeutralDown);
   
   SetIndexBuffer(4,macd);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(5,signal);
   SetIndexBuffer(6,colors);
   IndicatorShortName("DEMA_Macd("+FastEMA+","+SlowEMA+","+SignalEMA+")");
   return(0);
}
int deinit()
{
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

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         
         //
         //
         //
         //
         //

         datetime tDummy = Dummy;
         if (Dummy<=Time[0]) tDummy = Time[0];
         static bool secondTime=false;
         if (secondTime)
         {
            int count=0;
            for (;limit<Bars; limit++) if (colors[limit]!=colors[limit+1]) { count++; if (count>1) break; }
         }
         else secondTime=true;

   //
   //
   //
   //
   //
   
      for(i = limit; i>=0 ; i--)
      {
         double price = iMA(NULL,0,1,0,MODE_SMA,Price,i);
         if (i>Bars-2)
         {
            macd[i]   = 0;
            signal[i] = 0;
            continue;
         }

         //
         //
         //
         //
         //
         
         macd[i]   = iDema(price,FastEMA,i,0)-iDema(price,SlowEMA,i,1);
         signal[i] = iDema(macd[i],SignalEMA,i,2);
         colors[i] = colors[i+1];
            
            //
            //
            //
            //
            //
            
            if (macd[i]>signal[i] && macd[i]> 0) colors[i] =  1;
            if (macd[i]>signal[i] && macd[i]< 0) colors[i] =  2;
            if (macd[i]<signal[i] && macd[i]< 0) colors[i] = -1;
            if (macd[i]<signal[i] && macd[i]> 0) colors[i] = -2;
            for (int index=i; index<Bars; index++)
             if (colors[index]!=colors[index+1]) break;
              UpBuffer[i] = 0;
              Up2Buffer[i] = 0;
              DownBuffer[i] = 0;
              Down2Buffer[i] = 0;
              int col = colors[i];
              
              switch (col)
              {
                 case -1 : DownBuffer[i] = -1;  break;
                 case -2 : Down2Buffer[i] = -1; break;
                 case  1 : UpBuffer[i] = 1;     break;
                 default : Up2Buffer[i] = 1;    break;
              }
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


//      if (colors[whichBar] != colors[whichBar+1])
//      {
//         if (colors[whichBar] ==  1) doAlert(whichBar,"up and MACD > 0");
//         if (colors[whichBar] ==  2) doAlert(whichBar,"up and MACD < 0");
//         if (colors[whichBar] == -1) doAlert(whichBar,"down and MACD < 0");
//         if (colors[whichBar] == -2) doAlert(whichBar,"down and MACD > 0");
//      }

//
//
//
//
//

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workDema[][6];
#define _ema1 0
#define _ema2 1

double iDema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDema,0)!= Bars) ArrayResize(workDema,Bars); instanceNo*=2; r = Bars-r-1;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workDema[r][_ema1+instanceNo] = workDema[r-1][_ema1+instanceNo]+alpha*(price                        -workDema[r-1][_ema1+instanceNo]);
          workDema[r][_ema2+instanceNo] = workDema[r-1][_ema2+instanceNo]+alpha*(workDema[r][_ema1+instanceNo]-workDema[r-1][_ema2+instanceNo]);
   return(workDema[r][_ema1+instanceNo]*2.0-workDema[r][_ema2+instanceNo]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
      int chars = StringGetChar(s, length);
         if((chars > 96 && chars < 123) || (chars > 223 && chars < 256))
                     s = StringSetChar(s, length, chars - 32);
         else if(chars > -33 && chars < 0)
                     s = StringSetChar(s, length, chars + 224);
   }
   return(s);
}