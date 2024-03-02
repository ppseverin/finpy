//+------------------------------------------------------------------+
//|                                               RAVI FX Fisher.mq4 |
//|                         Copyright © 2005, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Lime
//#property indicator_color2 Red
//#property indicator_color3 Yellow

//---- input parameters
extern double       alpha=0.5;

extern int       maxbars=2000;


//---- buffers
double soHPF[];
//double SignalBuffer[];
//double AuxBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,soHPF);
 //  SetIndexStyle(1,DRAW_LINE);
 //  SetIndexBuffer(1,SignalBuffer);
 //  SetIndexStyle(2,DRAW_LINE);
//   SetIndexBuffer(2,AuxBuffer);
//   SetLevelValue(0,0.8);
//   SetLevelValue(1,-0.8);
   ArrayInitialize(soHPF,0);
//   ArrayInitialize(SignalBuffer,0);
//   ArrayInitialize(AuxBuffer,0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
  {
      int    counted_bars=IndicatorCounted();
  //    Comment(Bars,"  ", counted_bars);
      //double Normalized=0;
      //double Fish=0;
      //---- check for possible errors
      if(counted_bars<0) return(-1);
      int limit=Bars-counted_bars;
      if(limit>maxbars)limit=maxbars;      
      //if (limit>Bars-1)limit=Bars-1;   
      //---- 
      for (int shift = limit; shift>=0;shift--)
      {
	      soHPF[shift]=MathPow(1-alpha/2,2)*(Close[shift] -2*Close[shift+1]+Close[shift+2])+2*(1-alpha)
	      *soHPF[shift+1]-MathPow(1-alpha,2)*soHPF[shift+2];
         
       }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+