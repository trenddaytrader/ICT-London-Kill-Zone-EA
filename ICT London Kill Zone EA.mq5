//+------------------------------------------------------------------+
//|                                             ICT Kill Zone EA.mq5 |
//|                                          Copyright 2025, Usiola. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Usiola."
#property link      "https://www.mql5.com"
#property version   "1.00"

int barsTotal;

input int    AsianStartHour     = 0;
input int    AsianStartMinute   = 0;
input int    AsianEndHour       = 7;
input int    AsianEndMinute     = 59;
input color  AsianColor         = clrDodgerBlue;
input int    AsianBoxWidth       = 2;



datetime lastDrawDay = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int bars = iBars(_Symbol, PERIOD_CURRENT);

   if(barsTotal != bars)
     {
      barsTotal = bars;


      AsiaRange();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AsiaRange()
  {

   datetime timeNow = TimeCurrent();
   MqlDateTime tm;
   TimeToStruct(timeNow, tm);

// Construct session end time
   datetime sessionEnd = StringToTime(TimeToString(timeNow, TIME_DATE) + " " +
                                      IntegerToString(AsianEndHour, 2, '0') + ":" + IntegerToString(AsianEndMinute, 2, '0'));

// Only run if it's after the end time and not already drawn today
   if(timeNow >= sessionEnd && lastDrawDay != tm.day)
     {
      lastDrawDay = tm.day;

      datetime sessionStart = StringToTime(TimeToString(timeNow, TIME_DATE) + " " +
                                           IntegerToString(AsianStartHour, 2, '0') + ":" + IntegerToString(AsianStartMinute, 2, '0'));

      if(sessionStart > sessionEnd)
         sessionStart -= 86400; // adjust to previous day

      // Copy rates between sessionStart and sessionEnd
      MqlRates rates[];
      if(CopyRates(_Symbol, PERIOD_CURRENT, sessionStart, sessionEnd, rates) <= 0)
         return;

      double asiaHigh = rates[0].high;
      double asiaLow  = rates[0].low;

      datetime firstTime = rates[0].time;
      datetime lastTime  = rates[ArraySize(rates)-1].time;

      for(int i = 1; i < ArraySize(rates); i++)
        {
         if(rates[i].high > asiaHigh)
            asiaHigh = rates[i].high;
         if(rates[i].low < asiaLow)
            asiaLow = rates[i].low;
        }

      string boxName = "AsiaSessionBox_" + IntegerToString(tm.year) + IntegerToString(tm.mon) + IntegerToString(tm.day);

      if(ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, firstTime, asiaHigh, lastTime, asiaLow))
        {
         ObjectSetInteger(0, boxName, OBJPROP_COLOR, AsianColor);
         ObjectSetInteger(0, boxName, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, boxName, OBJPROP_WIDTH, AsianBoxWidth);
         ObjectSetInteger(0, boxName, OBJPROP_BACK, true);
        }
     }
  }
//+------------------------------------------------------------------+
