#include "definition.mqh"


class CTradeMgr : public CTradeOps {
private:
   double         lots_;
   int            sl_points_, tp_points_, be_points_, trail_points_, step_, min_points_; 
   bool           sl_enabled_, tp_enabled_, be_enabled_, trail_enabled_; 
   
   //-- Risk Parameters
   double         risk_usd_, reward_usd_; 
public:
   CTradeMgr();
   ~CTradeMgr() {};
   
   double   Lots() const   { return lots_; }
   void     Lots(double value)   { lots_ = NormalizeDouble(value, 2); }
   
   int      SLPoints()  const    { return sl_points_; }
   void     SLPoints(int value)  { sl_points_ = value; }
   
   int      TPPoints() const     { return tp_points_; }
   void     TPPoints(int value)  { tp_points_ = NormalizeDouble(value, 2); }
   
   int      BEPoints() const     { return be_points_; }
   void     BEPoints(int value)  { be_points_ = value; }
   
   int      TrailPoints() const  { return trail_points_; }
   void     TrailPoints(int value) { trail_points_ = value; }
   
   int      MinPoints() const    { return min_points_; }
   void     MinPoints(int value) { min_points_ = value; }
      
   int      Step() const         { return step_; }
   void     Step(int value)      { step_ = value; }
   
   bool     SLEnabled() const    { return sl_enabled_; }
   void     SLEnabled(bool value){ sl_enabled_ = value; } 
   
   bool     TPEnabled() const    { return tp_enabled_; } 
   void     TPEnabled(bool value){ tp_enabled_ = value; }    
   
   bool     BEEnabled() const    { return be_enabled_; }
   void     BEEnabled(bool value){ be_enabled_ = value; }
   
   bool     TrailEnabled() const { return trail_enabled_; }
   void     TrailEnabled(bool value) { trail_enabled_ = value; }
   
   int      Increment(int value) { return value += Step(); }
   int      Decrement(int value) { return value -= Step(); }
   
   double   RiskUSD() const      { return risk_usd_; }
   double   RewardUSD() const    { return reward_usd_; }
   double   RiskRewardRatio()    { return RewardUSD() / RiskUSD(); }
   
   
   void     OrderSendMarketBuy();
   void     OrderSendMarketSell();
   
   void     CalculateRiskParameters(); 
   double   PointsToTicks(int points); 
   double   TicksToUSD(double ticks); 
   
   int      BreakevenAllPositions();
   int      BreakevenValidPositions(int points_distance); 
   int      CloseAllPositions(); 
   
   
   int      TrailAllPositions(); 
   int      TrailValidPositions(); 
   bool     TrailValid(int ticket); 
   
}; 


CTradeMgr::CTradeMgr() 
   : CTradeOps(Symbol(), InpMagic)
   , lots_(UTIL_SYMBOL_MINLOT())
   , sl_points_(InpSLPoints)
   , tp_points_(InpTPPoints)
   , be_points_(InpBEPoints)
   , trail_points_(InpTSPoints)
   , min_points_(InpMinPoints)
   , step_(InpStep)
   , sl_enabled_(InpSLEnabled)
   , tp_enabled_(InpTPEnabled)
   , be_enabled_(InpBEEnabled)
   , trail_enabled_(InpTSEnabled) {
   
   CalculateRiskParameters(); 
}



void        CTradeMgr::OrderSendMarketBuy() {
   double sl_price = sl_enabled_ ? UTIL_PRICE_ASK() - PointsToTicks(sl_points_) : 0; 
   double tp_price = tp_enabled_ ? UTIL_PRICE_ASK() + PointsToTicks(tp_points_) : 0; 
   int ticket = OP_OrderOpen(Symbol(), ORDER_TYPE_BUY, Lots(), UTIL_PRICE_ASK(), sl_price, tp_price, "MGR"); 
   if (!ticket) Console_.LogError("ORDER SEND FAILED.", __FUNCTION__); 
   
   
}

void        CTradeMgr::OrderSendMarketSell() {
   double sl_price = sl_enabled_ ? UTIL_PRICE_BID() + PointsToTicks(sl_points_) : 0; 
   double tp_price = tp_enabled_ ? UTIL_PRICE_BID() - PointsToTicks(tp_points_) : 0; 

   int ticket = OP_OrderOpen(Symbol(), ORDER_TYPE_SELL, Lots(), UTIL_PRICE_BID(), sl_price, tp_price, "MGR"); 
   if (!ticket) Console_.LogError("ORDER SEND FAILED.", __FUNCTION__); 
   
}



void        CTradeMgr::CalculateRiskParameters() {
   // convert points to ticks 
   
   risk_usd_         = TicksToUSD(PointsToTicks(sl_points_));
   reward_usd_       = TicksToUSD(PointsToTicks(tp_points_)); 
   Console_.LogInformation(StringFormat("Risk: %.2f, Reward: %.2f", risk_usd_, reward_usd_), __FUNCTION__);
   
}

double      CTradeMgr::PointsToTicks(int points) {
   return points * UTIL_TRADE_PTS(); 
}

double      CTradeMgr::TicksToUSD(double ticks) {
   return ((ticks * lots_ * UTIL_TICK_VAL()) / UTIL_TRADE_PTS()); 
}

int         CTradeMgr::BreakevenAllPositions() {
   if (PosTotal() == 0) {
      Console_.LogInformation("No trades to modify. Order pool is empty.", __FUNCTION__); 
      return 0; 
   }
   
   Console_.LogInformation(StringFormat("%i trades found. Attempting to set breakeven.", 
      PosTotal()), __FUNCTION__);
   int s, ticket, num_modified=0; 
   
   for (int i = 0; i < PosTotal(); i++) {
      s  = OP_OrderSelectByIndex(i);
      ticket = PosTicket(); 
      
      if (!OP_ModifySL(ticket, PosOpenPrice())) continue; 
      num_modified++;
   }
   return num_modified;
}

int         CTradeMgr::CloseAllPositions() {
   if (PosTotal() == 0) {
      Console_.LogInformation("No trades to close. Order Pool is empty.", __FUNCTION__);
      return 0; 
   }
   Console_.LogInformation(StringFormat("%i trades found. Attempting to close.", 
      PosTotal()), __FUNCTION__); 
      
   CPoolGeneric<int> *tickets = new CPoolGeneric<int>(); 
   
   for (int i = 0; i < PosTotal(); i++) {
      int s = OP_OrderSelectByIndex(i);
      int ticket = PosTicket();
      tickets.Append(ticket); 
   }
   
   int extracted[];
   int num_extracted = tickets.Extract(extracted); 
   
   OP_OrdersCloseBatch(extracted); 
   
   if (PosTotal() != 0) Console_.LogInformation(StringFormat("Not all orders were closed. Num Extracted: %i, Remaining: %i", 
      num_extracted, 
      PosTotal()), __FUNCTION__); 
   delete tickets; 
   return num_extracted; 
}


int         CTradeMgr::BreakevenValidPositions(int points_distance) {
   if (!BEEnabled()) {
      return 0; 
   }
   if (TrailEnabled()) {
      //--- Prioritize trail stop over BE 
      return 0; 
   }
   if (PosTotal() == 0) {
      Console_.LogInformation("No trades to modify. Order pool is empty.", __FUNCTION__); 
      return 0; 
   }
   Console_.LogInformation(StringFormat("%i trades found. Attempting to set breakeven.", 
      PosTotal()), __FUNCTION__); 
   double tick_distance = PointsToTicks(points_distance); 
   int num_modified = 0; 
   for (int i = 0; i < PosTotal(); i++) {
      int s = OP_OrderSelectByIndex(i);
      //--- Skip trades in floating loss
      if (PosProfit() < 0) continue; 
      //--- Skip trades already set to BE 
      if (PosOpenPrice() == PosSL()) continue; 
      double tick_diff=0; 
      switch(PosOrderType()) {
         case ORDER_TYPE_BUY:
            tick_diff = MathAbs(PosOpenPrice() - UTIL_PRICE_BID()); 
            break;
         case ORDER_TYPE_SELL: 
            tick_diff = MathAbs(PosOpenPrice() - UTIL_PRICE_ASK()); 
            break;
         default:
            continue; 
      }
      //--- Skip trades with trade diff below required threshold
      if (tick_diff < tick_distance) continue; 
      if (!OP_ModifySL(PosTicket(), PosOpenPrice())) continue; 
      num_modified++; 
   }
   if (num_modified > 0) Console_.LogInformation(StringFormat("%i trades set to breakeven.", num_modified), __FUNCTION__);
   return num_modified; 

}


int         CTradeMgr::TrailAllPositions() {
   /**
      Trails all positions that are beyond trail threshold
   **/
   
   if (PosTotal() == 0) {
      //Console_.LogInformation("No trades to modify. Order pool is empty.", __FUNCTION__); 
      return 0; 
   } 
   
   Console_.LogInformation(StringFormat("%i trades found. Attempting to set trail stop.", 
      PosTotal()), __FUNCTION__); 
   
   double tick_distance = PointsToTicks(trail_points_); 
   int num_modified = 0; 
   
   for (int i = 0; i < PosTotal(); i++) {
      int s = OP_OrderSelectByIndex(i);
      //--- Skip trades in floating loss
      if (PosProfit() < 0) continue; 
      //--- Skip trades that are below trail threshold
      if (!TrailValid(PosTicket())) continue; 
      
      double sl_price;
      switch(PosOrderType()) {
         case ORDER_TYPE_BUY:
            sl_price = UTIL_PRICE_BID() - tick_distance; 
            if (sl_price < PosOpenPrice()) continue;
            break;
         case ORDER_TYPE_SELL:
            sl_price = UTIL_PRICE_ASK() + tick_distance;
            if (sl_price  > PosOpenPrice()) continue;  
            break; 
         default:
            continue; 
      }
      if (!OP_ModifySL(PosTicket(), sl_price)) continue; 
      num_modified++; 
   }
   if (num_modified > 0) Console_.LogInformation(StringFormat("%i trades set to breakeven.", num_modified), __FUNCTION__);
   return num_modified;
   
}

int         CTradeMgr::TrailValidPositions() {
   /**
      Called On Tick
   **/
   if (!TrailEnabled()) return 0; 
   return TrailAllPositions(); 
}


bool        CTradeMgr::TrailValid(int ticket) {
   if (ticket != PosTicket()) OP_OrderSelectByTicket(ticket); 
   if (PosProfit() < 0) return true; 
   double tick_distance = PointsToTicks(trail_points_); 
   
   
   switch(PosOrderType()) {
      case ORDER_TYPE_BUY:
         if (MathAbs(PosOpenPrice() - UTIL_PRICE_BID()) < tick_distance) return false; 
         return true;       
      case ORDER_TYPE_SELL: 
         if (MathAbs(PosOpenPrice() - UTIL_PRICE_ASK()) < tick_distance) return false;
         return true; 
   }
   return false;
}