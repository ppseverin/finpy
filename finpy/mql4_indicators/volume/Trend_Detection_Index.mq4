//+------------------------------------------------------------------+
//|                                        Trend Detection Index.mq4 |
//|                                                           mladen |
//|                                                                  |
//| Trend Detection Index originaly developed by M.H. Pee            |
//| TASC : 19:10 (October 2001) article                              |
//| "Are You In A Trend? Trend Detection Index"                      |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 DarkOrange
#property indicator_level1 0
#property indicator_levelcolor DimGray

//
//
//
//
//

extern int Length = 20;
extern int Price  = PRICE_CLOSE;

//
//
//
//
//

double Td[];
double Tdi[];
double values[][4];

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
   SetIndexBuffer(0,Td);  SetIndexLabel(0,"TD");
   SetIndexBuffer(1,Tdi); SetIndexLabel(1,"TDI");
   return(0);
}
int deinit()
{
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

#define mom      0
#define abs      1
#define sum_abs  2
#define sum_abs2 3

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
         if (ArrayRange(values,0) != Bars) ArrayResize(values,Bars);

   //
   //
   //
   //
   //

   for(i=limit, r=Bars-limit-1; i>=0; i--,r++)
   {
      values[r][mom]      = iMA(NULL,0,1,0,MODE_SMA,Price,i)-iMA(NULL,0,1,0,MODE_SMA,Price,i+Length);
      values[r][abs]      = MathAbs(values[r][mom]);
      values[r][sum_abs]  = 0;
      values[r][sum_abs2] = 0;
      Td[i]               = 0;

      //
      //
      //
      //
      //

         for (j=0;j<Length;j++)
         {
            Td[i]               += values[r-j][mom];
            values[r][sum_abs]  += values[r-j][abs];
            values[r][sum_abs2] += values[r-j][abs];
         }                  
         for (;j<Length*2;j++) values[r][sum_abs2] += values[r-j][abs];

      //
      //
      //
      //
      //
      
      Tdi[i] = MathAbs(Td[i])+values[r][sum_abs]-values[r][sum_abs2];
   }

   //
   //
   //
   //
   //

   return(0);
}