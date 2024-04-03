//+------------------------------------------------------------------+
//|                                                      manager.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "trade_app.mqh"
#include "trade.mqh"
CTradeMgr      trade_main;
CTradeApp      app(GetPointer(trade_main));
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   trade_main.CalculateRiskParameters(); 
   app.Init(); 
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0, -1, -1); 
   app.Destroy(reason); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   app.UpdateValuesOnTick();
   
  }
//+------------------------------------------------------------------+


void OnChartEvent(
   const int id, 
   const long& lparam, 
   const double& dparam, 
   const string& sparam
) {
   app.ChartEvent(id,lparam,dparam,sparam); 
   
   
}



void  ReadCharacters() {
   //valid characters 48-57 and 46
   string charstr = "1234567890."; 
   
   for (int i = 0; i < StringLen(charstr); i++) {
      int ch   = StringGetCharacter(charstr, i);
      string char_string = CharToString(ch);
      PrintFormat("Element: %s, Character: %i", char_string, ch); 
   }
   
}

bool     ValidInputs(string input_string) {

   
   int ch; 
   for (int i = 0; i < StringLen(input_string); i++) {
      ch = StringGetCharacter(input_string, i); 
      if (ch > 57) return false; 
      if (ch < 48 && ch != 46) return false;
   }
   return true; 
}