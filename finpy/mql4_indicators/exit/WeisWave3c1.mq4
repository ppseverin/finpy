//+------------------------------------------------------------------+
//|                                                    WeisWave3.mq4 |
//|         This code comes as is and carries NO WARRANTY whatsoever |
//|                                            Use at your own risk! |
//+------------------------------------------------------------------+
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 2
#property indicator_plots   2
//--- plot upVolume
#property indicator_label1  "upVolume"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot dnVolume
#property indicator_label2  "dnVolume"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrFireBrick
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- input parameters
input int      Difference = 30;

//--- indicator buffers
double         upVolumeBuffer[];
double         dnVolumeBuffer[];
double         barDirection[];
double         trendDirection[];
double         waveDirection[];
double         upPipBuffer[];
double         dnPipBuffer[];
long           volumeTracker = 0;
long           pipTracker=0;

double         highestHigh = EMPTY_VALUE;
double         lowestLow   = EMPTY_VALUE;
int            hhBar = EMPTY_VALUE;
int            llBar = EMPTY_VALUE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(75);

   SetIndexBuffer(0, upVolumeBuffer);
   SetIndexBuffer(1, dnVolumeBuffer);
   SetIndexBuffer(2, upPipBuffer);
   SetIndexBuffer(3, dnPipBuffer);
   SetIndexBuffer(4, trendDirection);
   SetIndexBuffer(5, waveDirection);
   SetIndexBuffer(6, barDirection);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string Label = ObjectName(i);
       if (StringCompare("ED8847DC", StringSubstr(Label, 0, 8), true) == 0) {
         ObjectDelete(Label);
       }
     }

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   // Only compute bars on new bar
   if (rates_total == prev_calculated) return(rates_total);
   RefreshRates();
   int limit = rates_total - 2;

   int  waveChangeBar = limit - 2;

   // Initialise values
   if (highestHigh == EMPTY_VALUE) highestHigh = close[waveChangeBar];
   if (lowestLow == EMPTY_VALUE) lowestLow = close[waveChangeBar];
   if (hhBar == EMPTY_VALUE) hhBar = waveChangeBar;
   if (llBar == EMPTY_VALUE) llBar = waveChangeBar;


   for(int i=limit-1; i>=0; i--) {
      // Determine this bar's direction
      if (close[i] - close[i+1] >  0) barDirection[i] =  1;    // current close higher
      if (close[i] - close[i+1] == 0) barDirection[i] =  0;    // current close equal
      if (close[i] - close[i+1] <  0) barDirection[i] = -1;    // current close lower

      if (barDirection[limit]   == EMPTY_VALUE) barDirection[limit]   = barDirection[i];
      if (trendDirection[limit] == EMPTY_VALUE) trendDirection[limit] = barDirection[i];
      if (waveDirection[limit]  == EMPTY_VALUE) waveDirection[limit]  = barDirection[i];

      // Determine highset high and lowest low
      if (close[i] > highestHigh) {
         highestHigh = close[i];
         hhBar = i;
      }
      else if (close[i] < lowestLow) {
         lowestLow = close[i];
         llBar = i;
      }
      // Determine if this bar has started a new trend
      if ((barDirection[i] != 0) && (barDirection[i] != barDirection[i+1]))
            trendDirection[i] = barDirection[i];
      else  trendDirection[i] = trendDirection[i+1];

      // Determine if this bar has started a new wave
      double waveTest = 0.0;
      if (waveDirection[i+1] == 1) {
         waveTest = highestHigh;
      }
      if (waveDirection[i+1] == -1) {
         waveTest = lowestLow;
      }
      double waveDifference = (MathAbs(waveTest - close[i])) * MathPow(10, Digits);
      if (trendDirection[i] != waveDirection[i+1]) {
         if (waveDifference >= Difference) waveDirection[i] = trendDirection[i];
         else waveDirection[i] = waveDirection[i+1];
      }
      else waveDirection[i] = waveDirection[i+1];

      // Determine if we have started a new wave
      if (waveDirection[i] != waveDirection[i+1]) {
         if (waveDirection[i] == 1) {
            highestHigh = close[i];
            hhBar = i;
            waveChangeBar = llBar;
         }
         else {
            lowestLow = close[i];
            llBar = i;
            waveChangeBar = hhBar;
         }


         volumeTracker = 0;
         pipTracker=0;
         for (int k=waveChangeBar-1; k>=i; k--) {
            volumeTracker += tick_volume[k];
            pipTracker += (open[k]-close[k])/Point;
            if (waveDirection[i] ==  1) {
               upVolumeBuffer[k] = volumeTracker;
               dnVolumeBuffer[k] = 0;
               upPipBuffer[k]=MathAbs(pipTracker);
               dnPipBuffer[k]=0;
            }
            if (waveDirection[i] == -1) {
               upVolumeBuffer[k] = 0;
               dnVolumeBuffer[k] = volumeTracker;
                upPipBuffer[k]=0;
               dnPipBuffer[k]=MathAbs(pipTracker);
            }
         }

      }
      else {
         volumeTracker += tick_volume[i];
          pipTracker+=(open[i]-close[i]) /Point ;
      }

 

      // Set the indicators
      if (waveDirection[i] ==  1) {
         upVolumeBuffer[i] = volumeTracker;
         dnVolumeBuffer[i] = 0;
         upPipBuffer[i]=MathAbs(pipTracker);
         dnPipBuffer[i]=0;
      }
      if (waveDirection[i] == -1) {
         upVolumeBuffer[i] = 0;
         dnVolumeBuffer[i] = volumeTracker;
         upPipBuffer[i]=0;
         dnPipBuffer[i]=MathAbs(pipTracker);
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
