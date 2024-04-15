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
   News.InitializeEvents(); 
   if (app.NewsWindowOpen()) app.OnClickNews(); 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   bool news_open = app.PageIsOpen(News.NAME()); 
   app.NewsWindowOpen(news_open);
   if (news_open) app.CloseActiveWindow(); 
   ObjectsDeleteAll(0, -1, -1); 
   
   app.Destroy(reason);
   News.ClearObjects();  
   


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
   //if (app.ActiveName() == News.NAME()) {
   //   News.ChartEvent(id,lparam,dparam,sparam);
   //   return; 
   //}
   CAppDialog *actv  = (CAppDialog*)app.Actv(); 
   app.ChartEvent(id,lparam,dparam,sparam); // Generic Events on main window 
   
   if (News.PageButtonPressed(sparam)) return; 
   
   if (CheckPointer(actv) != POINTER_INVALID) {
      // Events on news window
      actv.ChartEvent(id, lparam, dparam, sparam);
   } 
   //if (CHARTEVENT_OBJECT_CLICK) PrintFormat("Id: %i, Lparam: %i, Dparam: %f, Sparam: %s", id, lparam, dparam, sparam); 
   //CAppDialog  *actv = (CAppDialog*)app.Actv(); 
   
}


