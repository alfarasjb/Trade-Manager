#include "definition.mqh"
#include "trade.mqh"

class CTradeApp : public CAppDialog {
protected:
private:
            double      dpi_scale_; 
            
            CLogging    *Log_;
            
            CButton     market_buy_bt_, market_sell_bt_, increment_lot_bt_, decrement_lot_bt_, increment_sl_bt_, decrement_sl_bt_, increment_tp_bt_, decrement_tp_bt_; 
            CTradeMgr      *TradeMain;
            
            CLabel      ask_label_, buy_label_, bid_label_, sell_label_; 
            CEdit       lots_field_, sl_field_, tp_field_;
            int         col_1_, col_2_; 

            int         inc_bt_x1_, inc_bt_x2_, dec_bt_x1_, dec_bt_x2_;
            CCheckBox   sl_checkbox_, tp_checkbox_; 
            
            //--- Minor Elements
            CLabel      lots_label_, sl_label_, tp_label_; 

public:
   CTradeApp(CTradeMgr *trade);
   ~CTradeApp();
   
   
            void     Init(); 
   virtual  bool     Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2); 
   virtual  bool     ButtonCreate(CButton &bt, const string name, const int x1, const int y1); 
   virtual  bool     CreateMarketOrderButton(CButton &bt, CLabel &order_label, CLabel &price_label, const string name, const int x1, const int y1, double price, const color button_color); 
   
   //--- LOT SIZE FIELDS
   virtual  bool     CreateLotsRow(); 
   virtual  bool     CreateTextField(CEdit &field, CLabel &field_label, const string field_name, const string field_text, const string label_name, const string label_text, const int offset);
   virtual  bool     CreateAdjustButton(CButton &bt, const string name, const int x1, const int y1, const int x2, const int y2, const string text); 

   //--- OTHER FIELDS
   virtual  bool     CreateSLRow();
   virtual  bool     CreateTPRow(); 
   
   //--- NEWS TAB
   
    
   
   //--- EVENT HANDLERS
            void     OnClickMarketBuy();
            void     OnClickMarketSell(); 
            void     OnClickIncrementLots();
            void     OnClickDecrementLots(); 
            void     OnEndEditLotsField();
            void     OnClickIncrementSLPoints();
            void     OnClickDecrementSLPoints();
            void     OnEndEditSLField();
            void     OnClickIncrementTPPoints(); 
            void     OnClickDecrementTPPoints(); 
            void     OnEndEditTPField(); 
   //--- EVENT MAPPING 
   EVENT_MAP_BEGIN(CTradeApp) 
   ON_EVENT(ON_CLICK, market_buy_bt_, OnClickMarketBuy);
   ON_EVENT(ON_CLICK, market_sell_bt_, OnClickMarketSell); 
   ON_EVENT(ON_CLICK, increment_lot_bt_, OnClickIncrementLots);
   ON_EVENT(ON_CLICK, decrement_lot_bt_, OnClickDecrementLots); 
   ON_EVENT(ON_END_EDIT, lots_field_, OnEndEditLotsField);
   ON_EVENT(ON_CLICK, increment_sl_bt_, OnClickIncrementSLPoints);
   ON_EVENT(ON_CLICK, decrement_sl_bt_, OnClickDecrementSLPoints);
   ON_EVENT(ON_END_EDIT, sl_field_, OnEndEditSLField);
   ON_EVENT(ON_CLICK, increment_tp_bt_, OnClickIncrementTPPoints);
   ON_EVENT(ON_CLICK, decrement_tp_bt_, OnClickDecrementTPPoints);
   ON_EVENT(ON_END_EDIT, tp_field_, OnEndEditTPField); 
   EVENT_MAP_END(CAppDialog)
   
   //--- UTILITY
            int      Scale(double value)  { return (int)MathRound(value * dpi_scale_); }
            void     UpdateValuesOnTick(); 
            
            string   BuyButtonString() const;
            string   SellButtonString() const; 
}; 

CTradeApp::CTradeApp(CTradeMgr *trade) : TradeMain(trade) {
   double   screen_dpi  = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI); 
   dpi_scale_           = screen_dpi / 96; 
   
   
   col_1_   = Scale(COLUMN_1);
   col_2_   = Scale(COLUMN_2); 
   
   inc_bt_x1_  = PRICE_FIELD_INDENT_LEFT + Scale(PRICE_FIELD_WIDTH-1); 
   inc_bt_x2_  = inc_bt_x1_ + Scale(ADJ_BUTTON_SIZE); 
   
    
   dec_bt_x1_  = PRICE_FIELD_INDENT_LEFT - Scale(ADJ_BUTTON_SIZE-2);
   dec_bt_x2_  = dec_bt_x1_ + Scale(ADJ_BUTTON_SIZE); 
   Log_  = new CLogging(true, false, false);
}

CTradeApp::~CTradeApp() {
   delete Log_;
   Destroy();
}

void        CTradeApp::Init() {
   bool c = Create(0, "Trade Manager", 0, MAIN_PANEL_X1, MAIN_PANEL_Y1, MAIN_PANEL_X2, MAIN_PANEL_Y2);
   if (!c) Log_.LogInformation("Not all objects were created.", __FUNCTION__);
   Run(); 
}

bool        CTradeApp::Create(
   const long chart,
   const string name,
   const int subwin,
   const int x1,
   const int y1,
   const int x2,
   const int y2) {

   if (!CAppDialog::Create(chart, name, subwin, x1, y1, Scale(x2), Scale(y2))) return false; 
   if (!CreateMarketOrderButton(market_buy_bt_, buy_label_, ask_label_, "Buy", col_1_, 10, UTIL_PRICE_ASK(), BUY_BUTTON_COLOR)) return false; 
   if (!CreateMarketOrderButton(market_sell_bt_, sell_label_, bid_label_, "Sell", col_2_, 10, UTIL_PRICE_BID(), SELL_BUTTON_COLOR)) return false; 
   if (!CreateLotsRow()) return false; 
   if (!CreateSLRow()) return false; 
   if (!CreateTPRow()) return false; 
   return true; 

}

bool        CTradeApp::CreateTextField(
   CEdit &field, 
   CLabel &field_label, 
   const string field_name, 
   const string field_text,
   const string label_name, 
   const string label_text,
   const int offset) {
   
   int x1   = PRICE_FIELD_INDENT_LEFT; 
   int y1   = PRICE_FIELD_INDENT_TOP + Scale(BUTTON_HEIGHT + offset + 5); 
   int x2   = x1 + Scale(PRICE_FIELD_WIDTH); 
   int y2   = y1 + Scale(PRICE_FIELD_HEIGHT); 
   if (!field.Create(0, field_name, 0, x1, y1, x2, y2)) return false; 
   if (!field.TextAlign(ALIGN_CENTER)) return false;
   if (!field.Text(field_text)) return false; 
   if (!Add(field)) return false; 
   if (!field_label.Create(0, label_name+"_label", 0, x2-Scale(5), y1 + Scale(1), x2, y2)) return false; 
   if (!field_label.Text(label_text)) return false; 
   
   if (!ObjectSetInteger(0, field_label.Name(), OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER)) return false; 
   if (!field_label.FontSize(9)) return false;
   if (!Add(field_label)) return false; 
   return true; 
   
}


bool        CTradeApp::CreateAdjustButton(
   CButton &bt, 
   const string name, 
   const int x1, 
   const int y1, 
   const int x2, 
   const int y2,
   const string text) {
   
   
   if (!bt.Create(0, name, 0, x1, y1, x2, y2)) return false; 
   if (!bt.Text(text)) return false;
   if (!Add(bt)) return false; 
   
   return true; 
}

bool        CTradeApp::CreateLotsRow() {
   int adj_button_y1 = PRICE_FIELD_INDENT_TOP + Scale(BUTTON_HEIGHT + 5);
   int adj_button_y2 = adj_button_y1 + Scale(ADJ_BUTTON_SIZE);  
   if (!CreateTextField(lots_field_, lots_label_, "Lots Field", (string)TradeMain.Lots(), "Lots","Lots", 0)) return false; 
   if (!CreateAdjustButton(increment_lot_bt_, "Add", inc_bt_x1_, adj_button_y1, inc_bt_x2_, adj_button_y2, "+")) return false;
   if (!CreateAdjustButton(decrement_lot_bt_, "Subtract", dec_bt_x1_, adj_button_y1, dec_bt_x2_, adj_button_y2, "-")) return false; 
   return true;  
   
}

bool        CTradeApp::CreateSLRow() {
   int adj_button_y1 = PRICE_FIELD_INDENT_TOP + Scale((BUTTON_HEIGHT*1.8) + 5); 
   int adj_button_y2 = adj_button_y1 + Scale(ADJ_BUTTON_SIZE); 
   int checkbox_x1   = inc_bt_x2_;
   int checkbox_x2   = checkbox_x1 + Scale(ADJ_BUTTON_SIZE); 
   int checkbox_y1   = adj_button_y1 + Scale(BUTTON_HEIGHT*2); 
   
   if (!CreateTextField(sl_field_, sl_label_, "SL Field", (string)TradeMain.SLPoints(), "Points-SL","Points", BUTTON_HEIGHT*0.8)) return false; 
   if (!CreateAdjustButton(increment_sl_bt_, "AddSL", inc_bt_x1_, adj_button_y1, inc_bt_x2_, adj_button_y2, "+")) return false; 
   if (!CreateAdjustButton(decrement_sl_bt_, "SubSL", dec_bt_x1_, adj_button_y1, dec_bt_x2_, adj_button_y2, "-")) return false;
   //if (!sl_checkbox_.Create(0, "SLCheckbox", 0, checkbox_x1, adj_button_y1, checkbox_x2, adj_button_y2)) return false;   
   //if (!sl_checkbox_.Text("")) return false; 
   return true; 
}

bool        CTradeApp::CreateTPRow() {
   int adj_button_y1 = PRICE_FIELD_INDENT_TOP + Scale((BUTTON_HEIGHT * 2.6) + 5);
   int adj_button_y2 = adj_button_y1 + Scale(ADJ_BUTTON_SIZE); 
   
   if (!CreateTextField(tp_field_, tp_label_, "TP Field", (string)TradeMain.TPPoints(), "Points-TP", "Points", BUTTON_HEIGHT*1.6)) return false; 
   if (!CreateAdjustButton(increment_tp_bt_, "AddTP", inc_bt_x1_, adj_button_y1, inc_bt_x2_, adj_button_y2, "+")) return false; 
   if (!CreateAdjustButton(decrement_tp_bt_, "SubTP", dec_bt_x1_, adj_button_y1, dec_bt_x2_, adj_button_y2, "-")) return false; 
   return true; 
}

bool        CTradeApp::ButtonCreate(CButton &bt,const string name,const int x1,const int y1) {
   int x2   = x1 + Scale(BUTTON_WIDTH);
   int y2   = y1 + Scale(BUTTON_HEIGHT);
   if (!bt.Create(0, name, 0, x1, y1, x2, y2)) return false; 
   if (!bt.Text(name)) return false; 
   if (!Add(bt)) return false; 
   return true; 
}

bool        CTradeApp::CreateMarketOrderButton(
   CButton &bt, 
   CLabel &order_label, 
   CLabel &price_label, 
   const string name, 
   const int x1,
   const int y1, 
   double price,
   const color button_color) {
   int x2   = x1 + Scale(BUTTON_WIDTH);
   int y2   = y1 + Scale(BUTTON_HEIGHT); 
   
    
   int label_x1         = x1 + Scale(MAIN_BT_LABEL_INDENT_LEFT); 
   int label_y1         = y1 + Scale(MAIN_BT_LABEL_INDENT_TOP); 
   int label_width      = 100; 
   int label_height     = 25; 
   int label_x2         = label_x1 + Scale(label_width);
   int label_y2         = label_y1 + Scale(label_height); 
   
   string price_string  = UTIL_PRICE_STIRNG(price);
   
   if (!bt.Create(0, name, 0, x1, y1, x2, y2)) return false; 
   if (!bt.ColorBackground(button_color)) return false;
   if (!price_label.Create(0, name+"_price", 0, label_x1, label_y1 + label_height, label_x2, label_y2 + 20)) return false; 
   if (!price_label.Text(price_string)) return false; 
   if (!price_label.FontSize(MAIN_BT_PRICE_FONTSIZE)) return false;
   if (!price_label.Color(ORDER_BUTTON_FONT_COLOR)) return false; 
   if (!Add(price_label)) return false;
   
   if (!order_label.Create(0, name+"_order", 0, label_x1, label_y1, label_x2, label_y2)) return false; 
   if (!order_label.Text(name)) return false; 
   if (!order_label.FontSize(MAIN_BT_ORDER_FONTSIZE)) return false;
   if (!order_label.Color(ORDER_BUTTON_FONT_COLOR)) return false; 
   if (!Add(order_label)) return false; 
   if (!Add(bt)) return false;
   
   return true; 
   
}

void        CTradeApp::OnClickMarketBuy() {
   Log_.LogInformation("OnClickMarketBuy Pressed.", __FUNCTION__);
   TradeMain.OrderSendMarketBuy();
}

void        CTradeApp::OnClickMarketSell() {
   Log_.LogInformation("OnClickMarketSell Pressed.", __FUNCTION__);
   TradeMain.OrderSendMarketSell(); 
}

void        CTradeApp::OnClickIncrementLots() {
   Log_.LogInformation("Pressed", __FUNCTION__); 
   double current_lot   = TradeMain.Lots(); 
   TradeMain.Lots(current_lot+=UTIL_SYMBOL_LOTSTEP()); 
   lots_field_.Text((string)TradeMain.Lots());
}

void        CTradeApp::OnClickDecrementLots() {
   Log_.LogInformation("Pressed", __FUNCTION__); 
   double current_lot   = TradeMain.Lots(); 
   TradeMain.Lots(current_lot-=UTIL_SYMBOL_LOTSTEP()); 
   lots_field_.Text((string)TradeMain.Lots()); 
}

void        CTradeApp::OnClickIncrementSLPoints() {
   int   current_sl_points = TradeMain.SLPoints();
   TradeMain.SLPoints(current_sl_points+=TradeMain.Step()); 
   sl_field_.Text((string)TradeMain.SLPoints()); 
} 

void        CTradeApp::OnClickDecrementSLPoints() {
   int   current_sl_points = TradeMain.SLPoints();
   TradeMain.SLPoints(current_sl_points-=TradeMain.Step());
   sl_field_.Text((string)TradeMain.SLPoints()); 
}

void        CTradeApp::OnEndEditSLField() {}

void        CTradeApp::OnEndEditTPField() {}

void        CTradeApp::OnClickIncrementTPPoints() {
   int   current_tp_points = TradeMain.TPPoints();
   TradeMain.TPPoints(current_tp_points+=TradeMain.Step());
   tp_field_.Text((string)TradeMain.TPPoints()); 
} 

void        CTradeApp::OnClickDecrementTPPoints() {
   int   current_tp_points = TradeMain.TPPoints(); 
   TradeMain.TPPoints(current_tp_points-=TradeMain.Step());
   tp_field_.Text((string)TradeMain.TPPoints());
}


void        CTradeApp::OnEndEditLotsField() {
   //--- Parse Numeric only 
   //--- Throw error if not numeric 
   //--- Must be >= minlots
   Log_.LogInformation("Edited", __FUNCTION__);
}

void        CTradeApp::UpdateValuesOnTick() {
   ask_label_.Text(UTIL_PRICE_STIRNG(UTIL_PRICE_ASK())); 
   bid_label_.Text(UTIL_PRICE_STIRNG(UTIL_PRICE_BID())); 

}

string      CTradeApp::BuyButtonString() const  { return StringFormat("Buy: %.5f", UTIL_PRICE_ASK()); }
string      CTradeApp::SellButtonString() const { return StringFormat("Sell: %.5f", UTIL_PRICE_BID()); }