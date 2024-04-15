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
   News.Destroy(reason); 
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
   if (app.ActiveName() == News.NAME()) {
      News.ChartEvent(id,lparam,dparam,sparam);
      return; 
   }
   CAppDialog *actv  = (CAppDialog*)app.Actv(); 
   app.ChartEvent(id,lparam,dparam,sparam); 
   
   if (CheckPointer(actv) != POINTER_INVALID) {
      actv.ChartEvent(id, lparam, dparam, sparam);
   }
   //if (CHARTEVENT_OBJECT_CLICK) PrintFormat("Id: %i, Lparam: %i, Dparam: %f, Sparam: %s", id, lparam, dparam, sparam); 
   //CAppDialog  *actv = (CAppDialog*)app.Actv(); 
   
}


