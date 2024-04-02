#include "definition.mqh"


class CTradeMgr : public CTradeOps {
private:
   double         lots_;
   int            sl_points_, tp_points_, step_; 
public:
   CTradeMgr();
   ~CTradeMgr() {};
   
   double   Lots() const   { return lots_; }
   void     Lots(double value)   { lots_ = NormalizeDouble(value, 2); }
   
   int      SLPoints()  const    { return sl_points_; }
   void     SLPoints(int value)  { sl_points_ = value; }
   
   int      TPPoints() const     { return tp_points_; }
   void     TPPoints(int value)  { tp_points_ = value; }
   
   int      Step() const         { return step_; }
   void     Step(int value)      { step_ = value; }
   
   void     OrderSendMarketBuy();
   void     OrderSendMarketSell();
}; 


CTradeMgr::CTradeMgr() 
   : CTradeOps(Symbol(), 111111)
   , lots_(UTIL_SYMBOL_MINLOT())
   , sl_points_(100)
   , tp_points_(100)
   , step_(10) {}



void        CTradeMgr::OrderSendMarketBuy() {
   Log_.LogInformation(StringFormat("Market Buy. Lot Size: %f SL Points: %i, TP Points: %i", Lots(), SLPoints(), TPPoints()), __FUNCTION__);
}

void        CTradeMgr::OrderSendMarketSell() {
   Log_.LogInformation(StringFormat("Market Sell. Lot SIze: %f SL Points: %i, TP Points: %i", Lots(), SLPoints(), TPPoints()), __FUNCTION__);
}