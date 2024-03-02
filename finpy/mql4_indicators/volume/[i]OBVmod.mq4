//+-----------------------------------+
//| On Balance Volume with price bias |
//+-----------------------------------+
#property copyright "Ron Thompson"
#property link      "http://www.lightpatch.com/forex/"

#property indicator_separate_window
#property indicator_buffers 1

#property indicator_color1 White

//---- buffers
double Buffer1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|

int init()
  {

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, Buffer1);

  }


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+


int start()
  {
      
   double p=Point();

   int      pos=Bars-100;
   int      ctr=0;

   double  vol0,    vol1;
   double  vaccum;

   double  close0,  close1;
   double  gainloss;
   
   while(pos>=0)
     {

      vol1=Volume[pos+1];
      vol0=Volume[pos];

      close1=Close[pos+1];
      close0=Close[pos];
      
      if (close0>close1) gainloss=(close0-close1)/p;
      if (close0<close1) gainloss=(close1-close0)/p;

      if (close0>close1) vaccum=vaccum+(vol0*gainloss);
      if (close0<close1) vaccum=vaccum-(vol0*gainloss);
 
      Buffer1[pos]=vaccum;
      
 	   pos--;
     }

   return(0);
  }
//+------------------------------------------------------------------+