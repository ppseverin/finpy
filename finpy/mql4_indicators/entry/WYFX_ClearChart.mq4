
#property copyright "Copyright © 2010 www.wyfxco.com"
#property link      "www.wyfxco.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 C'0x23,0x5F,0xEB'
#property indicator_color3 Red
#property indicator_color4 C'0x23,0x5F,0xEB'

extern string MovAverageMethod = "Enter the Type of Moving Average:";
extern string _ = "0 = Simple          1 = Exponential";
extern string __ = "2 = Smoothed    3 = Linear Weighted";
extern int MovAvgMethod = 2;
extern int MovAvgPeriod = 6;
extern int MovAvgMethod2 = 3;
extern int MovAvgPeriod2 = 2;
extern string MovAverageLookBack = "Enter the LookBack Periods Above.";
double g_ibuf_124[];
double g_ibuf_128[];
double g_ibuf_132[];
double g_ibuf_136[];
double g_ibuf_140[];
double g_ibuf_144[];
double g_ibuf_148[];
double g_ibuf_152[];
int gi_156 = 0;

int init() {
   IndicatorBuffers(8);
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(0, g_ibuf_124);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(1, g_ibuf_128);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(2, g_ibuf_132);
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(3, g_ibuf_136);
   SetIndexDrawBegin(0, 5);
   SetIndexBuffer(0, g_ibuf_124);
   SetIndexBuffer(1, g_ibuf_128);
   SetIndexBuffer(2, g_ibuf_132);
   SetIndexBuffer(3, g_ibuf_136);
   SetIndexBuffer(4, g_ibuf_140);
   SetIndexBuffer(5, g_ibuf_144);
   SetIndexBuffer(6, g_ibuf_148);
   SetIndexBuffer(7, g_ibuf_152);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   Comment("Download more: Www.ForexWinners.Ru");
   double l_ima_0;
   double l_ima_8;
   double l_ima_16;
   double l_ima_24;
   double ld_32;
   double ld_40;
   double ld_48;
   double ld_56;
   if (Bars <= 10) return (0);
   gi_156 = IndicatorCounted();
   if (gi_156 < 0) return (-1);
   if (gi_156 > 0) gi_156--;
   int li_64 = Bars - gi_156 - 1;
   int li_68 = li_64;
   while (li_64 >= 0) {
      l_ima_0 = iMA(NULL, 0, MovAvgPeriod, 0, MovAvgMethod, PRICE_OPEN, li_64);
      l_ima_8 = iMA(NULL, 0, MovAvgPeriod, 0, MovAvgMethod, PRICE_CLOSE, li_64);
      l_ima_16 = iMA(NULL, 0, MovAvgPeriod, 0, MovAvgMethod, PRICE_LOW, li_64);
      l_ima_24 = iMA(NULL, 0, MovAvgPeriod, 0, MovAvgMethod, PRICE_HIGH, li_64);
      ld_32 = (g_ibuf_140[li_64 + 1] + (g_ibuf_144[li_64 + 1])) / 2.0;
      ld_56 = (l_ima_0 + l_ima_24 + l_ima_16 + l_ima_8) / 4.0;
      ld_40 = MathMax(l_ima_24, MathMax(ld_32, ld_56));
      ld_48 = MathMin(l_ima_16, MathMin(ld_32, ld_56));
      if (ld_32 < ld_56) {
         g_ibuf_148[li_64] = ld_48;
         g_ibuf_152[li_64] = ld_40;
      } else {
         g_ibuf_148[li_64] = ld_40;
         g_ibuf_152[li_64] = ld_48;
      }
      g_ibuf_140[li_64] = ld_32;
      g_ibuf_144[li_64] = ld_56;
      li_64--;
   }
   for (int li_72 = 0; li_72 < li_68; li_72++) g_ibuf_124[li_72] = iMAOnArray(g_ibuf_148, Bars, MovAvgPeriod2, 0, MovAvgMethod2, li_72);
   for (li_72 = 0; li_72 < li_68; li_72++) g_ibuf_128[li_72] = iMAOnArray(g_ibuf_152, Bars, MovAvgPeriod2, 0, MovAvgMethod2, li_72);
   for (li_72 = 0; li_72 < li_68; li_72++) g_ibuf_132[li_72] = iMAOnArray(g_ibuf_140, Bars, MovAvgPeriod2, 0, MovAvgMethod2, li_72);
   for (li_72 = 0; li_72 < li_68; li_72++) g_ibuf_136[li_72] = iMAOnArray(g_ibuf_144, Bars, MovAvgPeriod2, 0, MovAvgMethod2, li_72);
   return (0);
}
