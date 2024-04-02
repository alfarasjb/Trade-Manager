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