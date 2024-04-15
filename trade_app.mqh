#include "definition.mqh"
#include "trade.mqh"
#include "news_panel.mqh"

/**
TODO:
1. Input validation (min/max lots)
2. Negative Values 
3. Calculation of risk/reward
**/
//--- News 
CNewsPanel  News; 
class CTradeApp : public CAppDialog {
protected:
private:
            
            double      dpi_scale_; 
            CTradeMgr   *TradeMain;
            CConsole    *Console_;
            
            //--- Adjustment Buttons
            CButton     market_buy_bt_, market_sell_bt_, increment_lot_bt_, decrement_lot_bt_, increment_sl_bt_, decrement_sl_bt_, increment_tp_bt_, decrement_tp_bt_;
            CButton     increment_be_bt_, decrement_be_bt_, increment_trail_bt_, decrement_trail_bt_;  
            
            //--- Batch Buttons 
            CButton     be_all_bt_, close_all_bt_, news_bt_, trail_all_bt_;
            
            
            //-- Labels
            CLabel      ask_label_, buy_label_, bid_label_, sell_label_; 
            CLabel      risk_label_, risk_value_label_, reward_label_, reward_value_label_, risk_reward_label_, risk_reward_value_label_; 
            
            //--- Fields
            CEdit       lots_field_, sl_field_, tp_field_, be_field_, trail_field_;
            int         col_1_, col_2_; 

            int         inc_bt_x1_, inc_bt_x2_, dec_bt_x1_, dec_bt_x2_;
            CCheckBox   sl_checkbox_, tp_checkbox_, be_checkbox_, trail_checkbox_; 
            
            //--- Minor Elements
            CLabel      lots_label_, sl_label_, tp_label_, be_label_, trail_label_; 
            
            
            //--- Subwindow
            CAppDialog  *ActiveDialog; 
            
            //--- Start Edit Last Stored Values 
            double      stored_lot_; 
            int         stored_sl_, stored_tp_, stored_be_, stored_trail_; 

public:
   CTradeApp(CTradeMgr *trade);
   ~CTradeApp();
            
   CAppDialog        *Actv() const { return ActiveDialog; }
   
            void     Init(); 
   virtual  bool     Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2); 
   virtual  void     Minimize(); 
   virtual  bool     ButtonCreate(CButton &bt, const string name, const int x1, const int y1); 
   virtual  bool     CreateMarketOrderButton(CButton &bt, CLabel &order_label, CLabel &price_label, const string name, const int x1, const int y1, double price, const color button_color); 
   virtual  bool     CreateLabel(CLabel &lbl, const string name, const int x1, const int y1, const int x2, const int y2, const string text, const int font_size); 
   virtual  bool     CreateWideButton(CButton &bt, const string name, const int x1, const int y1, const int x2, const int y2, const string text);  

   //--- LOT SIZE FIELDS
   virtual  bool     CreateLotsRow(); 
   virtual  bool     CreateTextField(CEdit &field, CLabel &field_label, const string field_name, const string field_text, const string label_name, const string label_text, const int x1, const int y1);
   virtual  bool     CreateAdjustButton(CButton &bt, const string name, const int x1, const int y1, const int x2, const int y2, const string text); 
   virtual  bool     CreateCheckbox(CCheckBox &box, const string name, const int x1, const int y1, const int x2, const int y2, const string text);
   //--- OTHER FIELDS
   virtual  bool     CreateSLRow();
   virtual  bool     CreateTPRow(); 
   virtual  bool     CreateBERow(); 
   virtual  bool     CreateTrailRow();
   
   //--- OTHER BUTTONS
   virtual  bool     CreateCloseAllButton();
   virtual  bool     CreateBEAllButton(); 
   virtual  bool     CreateTrailAllButton();
   virtual  bool     CreateNewsButton(); 
   //--- NEWS TAB
   
    
   
   //--- EVENT HANDLERS
            void     OnClickMarketBuy();
            void     OnClickMarketSell(); 
            void     OnClickIncrementLots();
            void     OnClickDecrementLots(); 
            void     OnStartEditLotsField(); 
            void     OnEndEditLotsField();
            void     OnClickIncrementSLPoints();
            void     OnClickDecrementSLPoints();
            void     OnStartEditSLField(); 
            void     OnEndEditSLField();
            void     OnClickIncrementTPPoints(); 
            void     OnClickDecrementTPPoints(); 
            void     OnStartEditTPField(); 
            void     OnEndEditTPField(); 
            void     OnChangeSLCheckbox();
            void     OnChangeTPCheckbox();
            void     OnClickIncrementBEPoints();
            void     OnClickDecrementBEPoints(); 
            void     OnStartEditBEField(); 
            void     OnEndEditBEField();
            void     OnChangeBECheckbox(); 
            
            void     OnClickBEAllPositions();
            void     OnClickCloseAllPositions();
            void     OnClickNews(); 
            
            void     OnClickIncrementTrailPoints();
            void     OnClickDecrementTrailPoints(); 
            void     OnStartEditTrailField();
            void     OnEndEditTrailField();
            void     OnChangeTrailCheckbox(); 
            void     OnClickTrailAllPositions(); 
   //--- EVENT MAPPING 
         EVENT_MAP_BEGIN(CTradeApp) 
         ON_NAMED_EVENT(ON_CLICK, market_buy_bt_, OnClickMarketBuy);
         ON_NAMED_EVENT(ON_CLICK, buy_label_, OnClickMarketBuy);
         ON_NAMED_EVENT(ON_CLICK, ask_label_, OnClickMarketBuy);
         ON_NAMED_EVENT(ON_CLICK, market_sell_bt_, OnClickMarketSell);
         ON_NAMED_EVENT(ON_CLICK, sell_label_, OnClickMarketSell);
         ON_NAMED_EVENT(ON_CLICK, bid_label_, OnClickMarketSell);  
         ON_EVENT(ON_CLICK, increment_lot_bt_, OnClickIncrementLots);
         ON_EVENT(ON_CLICK, decrement_lot_bt_, OnClickDecrementLots); 
         ON_EVENT(ON_CLICK, increment_sl_bt_, OnClickIncrementSLPoints);
         ON_EVENT(ON_CLICK, decrement_sl_bt_, OnClickDecrementSLPoints);
         ON_EVENT(ON_CLICK, increment_tp_bt_, OnClickIncrementTPPoints);
         ON_EVENT(ON_CLICK, decrement_tp_bt_, OnClickDecrementTPPoints);
         ON_EVENT(ON_CHANGE, sl_checkbox_, OnChangeSLCheckbox);
         ON_EVENT(ON_CHANGE, tp_checkbox_, OnChangeTPCheckbox);
         ON_EVENT(ON_CLICK, increment_be_bt_, OnClickIncrementBEPoints);
         ON_EVENT(ON_CLICK, decrement_be_bt_, OnClickDecrementBEPoints); 
         ON_EVENT(ON_CHANGE, be_checkbox_, OnChangeBECheckbox);  
         ON_EVENT(ON_CLICK, be_all_bt_, OnClickBEAllPositions); 
         ON_EVENT(ON_CLICK, close_all_bt_, OnClickCloseAllPositions); 
         ON_EVENT(ON_CLICK, news_bt_, OnClickNews);  
         ON_EVENT(ON_START_EDIT, lots_field_, OnStartEditLotsField); 
         ON_EVENT(ON_END_EDIT, lots_field_, OnEndEditLotsField);
         ON_EVENT(ON_START_EDIT, sl_field_, OnStartEditSLField); 
         ON_EVENT(ON_END_EDIT, sl_field_, OnEndEditSLField);
         ON_EVENT(ON_START_EDIT, tp_field_, OnStartEditTPField); 
         ON_EVENT(ON_END_EDIT, tp_field_, OnEndEditTPField); 
         ON_EVENT(ON_START_EDIT, be_field_, OnStartEditBEField); 
         ON_EVENT(ON_END_EDIT, be_field_, OnEndEditBEField); 
         ON_EVENT(ON_CLICK, increment_trail_bt_, OnClickIncrementTrailPoints);
         ON_EVENT(ON_CLICK, decrement_trail_bt_, OnClickDecrementTrailPoints);
         ON_EVENT(ON_CLICK, trail_all_bt_, OnClickTrailAllPositions); 
         ON_EVENT(ON_START_EDIT, trail_field_, OnStartEditTrailField);
         ON_EVENT(ON_END_EDIT, trail_field_, OnEndEditTrailField);          
         ON_EVENT(ON_CHANGE, trail_checkbox_, OnChangeTrailCheckbox);
         EVENT_MAP_END(CAppDialog)
   
   //--- UTILITY
            int      Scale(double value)  { return (int)MathRound(value * dpi_scale_); }
            int      WideButtonYOffset(int row); 
            string   DollarValue(double value)  { return StringFormat("$%.2f", value); }
            void     UpdateValuesOnTick(); 
            void     UpdateRiskReward(); 
            void     UpdateLots(double value); 
            
            string   BuyButtonString() const;
            string   SellButtonString() const;
           
            bool     ValidPoints(int value);
            bool     ValidValue(double value); 
            bool     ValidLots(double value); 
            bool     ValidFieldInput(string input_string); 
            bool     ValidPointsField(CEdit &field, int default_value); 
            void     ValidationError(ENUM_VALIDATION_ERROR error, string target_value, string func); 
            bool     TradingAllowed(); 
            
            bool     PageIsOpen(string panel_name);
            string   ActiveName();
            void     CloseActiveWindow(); 
            
            template <typename T>   bool  OpenPage(T &page); 
}; 

CTradeApp::CTradeApp(CTradeMgr *trade) : TradeMain(trade) {
   
   double   screen_dpi  = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI); 
   dpi_scale_           = screen_dpi / 96; 
   
   
   col_1_   = Scale(COLUMN_1);
   col_2_   = Scale(COLUMN_2); 
   
   //inc_bt_x1_  = PRICE_FIELD_INDENT_LEFT + Scale(PRICE_FIELD_WIDTH); 
   //inc_bt_x2_  = inc_bt_x1_ + Scale(ADJ_BUTTON_SIZE); 
   inc_bt_x1_  = PRICE_FIELD_INDENT_LEFT + PRICE_FIELD_WIDTH;
   inc_bt_x2_  = inc_bt_x1_ + ADJ_BUTTON_SIZE; 
    
   dec_bt_x1_  = col_1_; //Scale(ADJ_BUTTON_SIZE-2);
   //dec_bt_x2_  = dec_bt_x1_ + Scale(ADJ_BUTTON_SIZE); 
   dec_bt_x2_  = dec_bt_x1_ + ADJ_BUTTON_SIZE; 
   Console_  = new CConsole(true, false, false);
   
   
}

CTradeApp::~CTradeApp() {
   delete ActiveDialog;
   delete Console_;
}

void        CTradeApp::Init() {
   bool c = Create(0, "Trade Manager", 0, MAIN_PANEL_X1, MAIN_PANEL_Y1, MAIN_PANEL_X2, MAIN_PANEL_Y2);
   if (!c) Console_.LogInformation("Not all objects were created.", __FUNCTION__);
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
   // true val = input / scale
   int scaled_x2  = x1 + Scale(MAIN_PANEL_WIDTH);
   int scaled_y2  = y1 + Scale(MAIN_PANEL_HEIGHT);
   if (!CAppDialog::Create(chart, name, subwin, x1, y1, scaled_x2, scaled_y2)) return false; 
   if (!CreateMarketOrderButton(market_buy_bt_, buy_label_, ask_label_, "Buy", COLUMN_1, MAIN_BT_INDENT_TOP, UTIL_PRICE_ASK(), BUY_BUTTON_COLOR)) return false; 
   if (!CreateMarketOrderButton(market_sell_bt_, sell_label_, bid_label_, "Sell", COLUMN_2, MAIN_BT_INDENT_TOP, UTIL_PRICE_BID(), SELL_BUTTON_COLOR)) return false; 
   if (!CreateLotsRow()) return false; 
   if (!CreateSLRow()) return false;
   if (!CreateTPRow()) return false;
   if (!CreateBERow()) return false; 
   if (!CreateTrailRow()) return false;
   if (!CreateBEAllButton()) return false; 
   if (!CreateTrailAllButton()) return false; 
   
   if (!CreateCloseAllButton()) return false; 
   
   if (!CreateNewsButton()) return false;  
   return true; 

}

//+------------------------------------------------------------------+
//| TEMPLATES                                                        |
//+------------------------------------------------------------------+


bool        CTradeApp::CreateTextField(
   CEdit &field, 
   CLabel &field_label, 
   const string field_name, 
   const string field_text,
   const string label_name, 
   const string label_text,
   const int x1,
   const int y1) {
   
   //int x1   = PRICE_FIELD_INDENT_LEFT; 
   //int y1   = PRICE_FIELD_INDENT_TOP + Scale(BUTTON_HEIGHT + offset + 5); 
   int x2   = x1 + Scale(PRICE_FIELD_WIDTH); 
   int y2   = y1 + Scale(PRICE_FIELD_HEIGHT);
   
   int scaled_x1  = Scale(x1); 
   int scaled_y1  = Scale(y1); 
   int scaled_x2  = scaled_x1 + Scale(PRICE_FIELD_WIDTH); 
   int scaled_y2  = scaled_y1 + Scale(PRICE_FIELD_HEIGHT);
    
   if (!field.Create(0, field_name, 0, scaled_x1, scaled_y1, scaled_x2, scaled_y2)) return false; 
   if (!field.TextAlign(ALIGN_CENTER)) return false;
   if (!field.Text(field_text)) return false; 
   if (!field.Font(CONTROLS_FONT_NAME)) return false; 
   if (!Add(field)) return false; 
   //if (!field_label.Create(0, label_name+"_label", 0, x2-Scale(5), y1 + Scale(1), x2, y2)) return false; 
   if (!field_label.Create(0, label_name+"_label", 0, scaled_x2-Scale(5), scaled_y1 + Scale(3), scaled_x2, scaled_y2)) return false; 
   if (!field_label.Text(label_text)) return false; 
   
   if (!ObjectSetInteger(0, field_label.Name(), OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER)) return false; 
   if (!field_label.FontSize(FIELD_LABEL_FONT_SIZE)) return false;
   if (!field_label.Font(CONTROLS_FONT_NAME)) return false; 
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
   
   int scaled_x1  = Scale(x1);
   int scaled_x2  = Scale(x2);
   int scaled_y1  = Scale(y1);
   int scaled_y2  = Scale(y2); 
   if (!bt.Create(0, name, 0, scaled_x1, scaled_y1, scaled_x2, scaled_y2)) return false; 
   if (!bt.Text(text)) return false;
   if (!bt.Font(CONTROLS_FONT_NAME)) return false; 
   if (!Add(bt)) return false; 
   
   return true; 
}


bool        CTradeApp::CreateCheckbox(
   CCheckBox &box, 
   const string name, 
   const int x1, 
   const int y1, 
   const int x2, 
   const int y2, 
   const string text) {
   int scaled_x1  = Scale(x1);
   int scaled_y1  = Scale(y1);
   int scaled_x2  = Scale(x2);
   int scaled_y2  = Scale(y2); 
   if (!box.Create(0, name, 0, scaled_x1, scaled_y1, scaled_x2, scaled_y2)) return false; 
   //if (!box.Create(0, name, 0, x1-20, y1, x2, y2)) return false;
   if (!box.Visible(true)) return false; 
   if (!box.Text(text)) return false; 
   if (!ObjectSetInteger(0, name+"Label", OBJPROP_FONTSIZE, SUBTITLE_FONT_SIZE)) return false; 
   //if (!box.Color(clrGreen)) return false;
   if (!Add(box)) return false; 
   return true;    
}

bool        CTradeApp::CreateLabel(
   CLabel &lbl, 
   const string name, 
   const int x1, 
   const int y1, 
   const int x2, 
   const int y2, 
   const string text, 
   const int font_size) {
   int scaled_x1  = Scale(x1);
   int scaled_x2  = Scale(x2);
   int scaled_y1  = Scale(y1);
   int scaled_y2  = Scale(y2); 
   if (!lbl.Create(0, name, 0, scaled_x1, scaled_y1, scaled_x2, scaled_y2)) return false; 
   if (!lbl.Text(text)) return false; 
   if (!lbl.FontSize(SUBTITLE_FONT_SIZE)) return false; 
   if (!lbl.Font(CONTROLS_FONT_NAME)) return false; 
   if (!Add(lbl)) return false;  
   
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
   int x2   = x1 + BUTTON_WIDTH;
   int y2   = y1 + BUTTON_HEIGHT; 
   
   int bt_x1   = Scale(x1);
   int bt_y1   = Scale(y1);
   int bt_x2   = Scale(x2);
   int bt_y2   = Scale(y2); 
   
   int label_x1         = Scale(x1 + MAIN_BT_LABEL_INDENT_LEFT); 
   int label_y1         = Scale(y1 + MAIN_BT_LABEL_INDENT_TOP); 
  
   int label_x2         = label_x1 + Scale(MAIN_BT_LABEL_WIDTH);
   int label_y2         = label_y1 + Scale(MAIN_BT_LABEL_HEIGHT); 
   
   string price_string  = UTIL_PRICE_STRING(price);
   if (!bt.Create(0, name, 0, bt_x1, bt_y1, bt_x2, bt_y2)) return false; 
   if (!bt.ColorBackground(button_color)) return false;
   if (!Add(bt)) return false; 
   
   if (!price_label.Create(0, name+"_price", 0, label_x1, label_y1, label_x2, label_y2)) return false; 
   if (!price_label.Text(price_string)) return false; 
   if (!price_label.Font(CONTROLS_FONT_NAME)) return false; 
   if (!price_label.FontSize(MAIN_BT_PRICE_FONTSIZE)) return false;
   if (!price_label.Color(ORDER_BUTTON_FONT_COLOR)) return false; 
   if (!Add(price_label)) return false;
   
   if (!order_label.Create(0, name+"_order", 0, label_x1, label_y1-Scale(20), label_x2, label_y2)) return false; 
   if (!order_label.Text(name)) return false; 
   if (!order_label.Font(CONTROLS_FONT_NAME)) return false; 
   if (!order_label.FontSize(MAIN_BT_ORDER_FONTSIZE)) return false;
   if (!order_label.Color(ORDER_BUTTON_FONT_COLOR)) return false; 
   if (!Add(order_label)) return false; 
   
   
   
   
   return true; 
   
}

bool        CTradeApp::CreateWideButton(
   CButton &bt, 
   const string name, 
   const int x1, 
   const int y1, 
   const int x2, 
   const int y2, 
   const string text) {
   
   int scaled_x1  = Scale(x1);
   int scaled_y1  = Scale(y1);
   int scaled_x2  = Scale(x2); 
   int scaled_y2  = Scale(y2); 
   if (!bt.Create(0, name, 0, x1, y1, x2, y2)) return false; 
   if (!bt.Text(text)) return false;
   if (!bt.Font(CONTROLS_FONT_NAME)) return false; 
   if (!Add(bt)) return false; 
   
   return true; 
}  

//+------------------------------------------------------------------+
//| MAIN ELEMENTS                                                    |
//+------------------------------------------------------------------+

bool        CTradeApp::CreateLotsRow() {
   int adj_button_y1 = PRICE_FIELD_INDENT_TOP + BUTTON_HEIGHT + 5; 
   int adj_button_y2 = adj_button_y1 + ADJ_BUTTON_SIZE;  
   
   int y1   = PRICE_FIELD_INDENT_TOP + BUTTON_HEIGHT + 5;
   
   if (!CreateTextField(lots_field_, lots_label_, "Lots Field", StringFormat("%.2f", TradeMain.Lots()), "Lots","Lots", dec_bt_x2_, y1)) return false; 
   if (!CreateAdjustButton(increment_lot_bt_, "Add", inc_bt_x1_, y1, inc_bt_x2_, adj_button_y2, "+")) return false;
   if (!CreateAdjustButton(decrement_lot_bt_, "Subtract", dec_bt_x1_, y1, dec_bt_x2_, adj_button_y2, "-")) return false; 
   return true;  
   
}

bool        CTradeApp::CreateSLRow() {

   int y1   = PRICE_FIELD_INDENT_TOP + ((1.5*BUTTON_HEIGHT)) + 5; 
   int adj_button_y2 = y1 + ADJ_BUTTON_SIZE; 
    
   int checkbox_x1   = inc_bt_x2_ + CHECKBOX_X_GAP;  
   int checkbox_y1   = y1 + CHECKBOX_Y_GAP; 
   int checkbox_x2   = checkbox_x1 + CHECKBOX_WIDTH;
   int checkbox_y2   = checkbox_y1 + CHECKBOX_HEIGHT;
   
   if (!CreateTextField(sl_field_, sl_label_, "SL Field", (string)TradeMain.SLPoints(), "Points-SL","Points", dec_bt_x2_, y1)) return false; 
   
   if (!CreateAdjustButton(increment_sl_bt_, "AddSL", inc_bt_x1_, y1, inc_bt_x2_, adj_button_y2, "+")) return false; 
   if (!CreateAdjustButton(decrement_sl_bt_, "SubSL", dec_bt_x1_, y1, dec_bt_x2_, adj_button_y2, "-")) return false;
   if (!CreateCheckbox(sl_checkbox_, "SLCheckbox", checkbox_x1, checkbox_y1, checkbox_x2, checkbox_y2, "SL")) return false; 
   if (!sl_checkbox_.Checked(TradeMain.SLEnabled())) return false; 
   
   int   risk_y   = adj_button_y2 + 5; 
   if (!CreateLabel(risk_label_, "Risk", dec_bt_x1_, risk_y, inc_bt_x2_, risk_y, "Risk", 7)) return false; 
   if (!CreateLabel(risk_value_label_, "Risk Value", dec_bt_x1_ + Scale(50), risk_y, inc_bt_x2_, risk_y, DollarValue(TradeMain.RiskUSD()), 7)) return false; 
   
   
   return true; 
}


bool        CTradeApp::CreateTPRow() {
   
   int x1   = PRICE_FIELD_INDENT_LEFT;
   int y1   = PRICE_FIELD_INDENT_TOP + ((2.5*BUTTON_HEIGHT)) + 5; 
   int adj_button_y2 = y1 + ADJ_BUTTON_SIZE; 
    
   int checkbox_x1   = inc_bt_x2_ + CHECKBOX_X_GAP;  
   int checkbox_y1   = y1 + CHECKBOX_Y_GAP; 
   int checkbox_x2   = checkbox_x1 + CHECKBOX_WIDTH;
   int checkbox_y2   = checkbox_y1 + CHECKBOX_HEIGHT;
   
   if (!CreateTextField(tp_field_, tp_label_, "TP Field", (string)TradeMain.TPPoints(), "Points-TP", "Points", dec_bt_x2_, y1)) return false; 
   if (!CreateAdjustButton(increment_tp_bt_, "AddTP", inc_bt_x1_, y1, inc_bt_x2_, adj_button_y2, "+")) return false; 
   if (!CreateAdjustButton(decrement_tp_bt_, "SubTP", dec_bt_x1_, y1, dec_bt_x2_, adj_button_y2, "-")) return false; 

   if (!CreateCheckbox(tp_checkbox_, "TPCheckbox", checkbox_x1, checkbox_y1, checkbox_x2, checkbox_y2, "TP")) return false;
   if (!tp_checkbox_.Checked(TradeMain.TPEnabled())) return false; 
   
   int   reward_y   = adj_button_y2 + 5; 
   
   if (!CreateLabel(reward_label_, "Reward", dec_bt_x1_, reward_y, inc_bt_x2_, reward_y, "Reward", 7)) return false; 
   if (!CreateLabel(reward_value_label_, "Reward Value", dec_bt_x1_ + Scale(50), reward_y, inc_bt_x2_, reward_y, DollarValue(TradeMain.RewardUSD()), 7)) return false; 
   
   
   
   return true; 
}

bool        CTradeApp::CreateBERow() {
   
   int y1   = PRICE_FIELD_INDENT_TOP + ((3.5*BUTTON_HEIGHT)) + 5; 
   int adj_button_y2 = y1 + ADJ_BUTTON_SIZE; 
    
   int checkbox_x1   = inc_bt_x2_ + CHECKBOX_X_GAP;  
   int checkbox_y1   = y1 + CHECKBOX_Y_GAP; 
   int checkbox_x2   = checkbox_x1 + CHECKBOX_WIDTH;
   int checkbox_y2   = checkbox_y1 + CHECKBOX_HEIGHT;
   
   
   if (!CreateTextField(be_field_, be_label_, "BE Field", (string)TradeMain.BEPoints(), "Points-BE", "Points", dec_bt_x2_, y1)) return false; 
   if (!CreateAdjustButton(increment_be_bt_, "AddBE", inc_bt_x1_, y1, inc_bt_x2_, adj_button_y2, "+")) return false; 
   if (!CreateAdjustButton(decrement_be_bt_, "SubBE", dec_bt_x1_, y1, dec_bt_x2_, adj_button_y2, "-")) return false; 
   if (!CreateCheckbox(be_checkbox_, "BECheckbox", checkbox_x1, checkbox_y1, checkbox_x2, checkbox_y2, "BE")) return false; 
   if (!be_checkbox_.Checked(TradeMain.BEEnabled())) return false;  
   return true;
}

bool        CTradeApp::CreateTrailRow() {
   int y1   = PRICE_FIELD_INDENT_TOP + ((4*BUTTON_HEIGHT)) + 5; 
   int adj_button_y2 = y1 + ADJ_BUTTON_SIZE; 
   
   int checkbox_x1   = inc_bt_x2_ + CHECKBOX_X_GAP;
   int checkbox_y1   = y1 + CHECKBOX_Y_GAP;
   int checkbox_x2   = checkbox_x1 + CHECKBOX_WIDTH;
   int checkbox_y2   = checkbox_y1 + CHECKBOX_HEIGHT;
   
   if (!CreateTextField(trail_field_, trail_label_, "Trail Field", (string)TradeMain.TrailPoints(), "Points-Trail", "Points", dec_bt_x2_, y1)) return false; 
   if (!CreateAdjustButton(increment_trail_bt_, "AddTrail", inc_bt_x1_, y1, inc_bt_x2_, adj_button_y2, "+")) return false;
   if (!CreateAdjustButton(decrement_trail_bt_, "SubTrail", dec_bt_x1_, y1, dec_bt_x2_, adj_button_y2, "-")) return false;
   if (!CreateCheckbox(trail_checkbox_, "TrailCheckbox", checkbox_x1, checkbox_y1, checkbox_x2, checkbox_y2, "TS")) return false; 
   if (!trail_checkbox_.Checked(TradeMain.TrailEnabled())) return false; 
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


bool        CTradeApp::CreateBEAllButton() {
   
   int x1   = dec_bt_x1_; 
   int bt_width = (WIDE_BUTTON_WIDTH/2) - 4;  
   
   int x2   = x1 + Scale(bt_width); 
   //int y1   = be_field_.Top() - Scale(10); 
   //int y1   = CAppDialog::Top() + Scale(200); 
   int y1   = CAppDialog::Top() + Scale(TOP_Y_OFFSET + WideButtonYOffset(1)); 
   int y2   = y1 + Scale(WIDE_BUTTON_HEIGHT); 
   if (!CreateWideButton(be_all_bt_, "BEAll", x1, y1, x2, y2, "BE All")) return false; 
   return true; 
}

bool        CTradeApp::CreateTrailAllButton() {
   int terminal_width = CAppDialog::Right() - CAppDialog::Left() - MAIN_PANEL_X1; 
   //int x1   = Scale(WIDE_BUTTON_WIDTH / 2);
   int bt_width   = (WIDE_BUTTON_WIDTH/2) - 4; 
   int x1   = (terminal_width / 2); 
   int x2   = x1 + Scale(bt_width)-1;
   int y1   = CAppDialog::Top() + Scale(TOP_Y_OFFSET + WideButtonYOffset(1));
   int y2   = y1 + Scale(WIDE_BUTTON_HEIGHT);
   
   if (!CreateWideButton(trail_all_bt_, "TrailAll", x1, y1, x2, y2, "Trail All ")) return false;
   return true;
}

bool        CTradeApp::CreateCloseAllButton() {
   
   int row  = 2; 
   
   int x1   = dec_bt_x1_;
   int x2   = x1 + Scale(WIDE_BUTTON_WIDTH);
   //int y1   = (be_all_bt_.Bottom() / dpi_scale_) + MAIN_PANEL_Y1 + 15;
   //int y1   = PRICE_FIELD_INDENT_TOP + ((6*BUTTON_HEIGHT)) + 5; 
   //int y1   = be_all_bt_.Bottom() - Scale(WIDE_BUTTON_HEIGHT);
   //int y1   = CAppDialog::Top() + Scale(200 + WIDE_BUTTON_HEIGHT + 5);
   int y1   = CAppDialog::Top() + Scale(TOP_Y_OFFSET + WideButtonYOffset(2));
   int y2   = y1 + Scale(WIDE_BUTTON_HEIGHT); 
   if (!CreateWideButton(close_all_bt_, "CloseAll", x1, y1, x2, y2, "Close All Positions")) return false; 
   return true; 
}

bool        CTradeApp::CreateNewsButton() {
   
   int x1   = dec_bt_x1_; 
   int x2   = x1 + Scale(WIDE_BUTTON_WIDTH); 
   //int y1   = close_all_bt_.Bottom() - Scale(WIDE_BUTTON_HEIGHT); 
   //int y1   = CAppDialog::Top() + Scale(200 + (2*(WIDE_BUTTON_HEIGHT + 5))); 
   int y1     = CAppDialog::Top() + Scale(TOP_Y_OFFSET + WideButtonYOffset(3)); 
   //int y1   = (close_all_bt_.Bottom() / dpi_scale_) + MAIN_PANEL_Y1 + 25;
   
   //int y1   = PRICE_FIELD_INDENT_TOP + ((6.9*BUTTON_HEIGHT)) + 5; 
   int y2   = y1 + Scale(WIDE_BUTTON_HEIGHT); 
   
   if (!CreateWideButton(news_bt_, "News", x1, y1, x2, y2, "News")) return false; 
   return true; 
}

void        CTradeApp::OnClickMarketBuy() {
   if (!TradingAllowed()) {
      market_buy_bt_.Pressed(false);
      return; 
   }
   market_buy_bt_.Pressed(true); 
   
   TradeMain.OrderSendMarketBuy();
   
   market_buy_bt_.Pressed(false); 
   
}

void        CTradeApp::OnClickMarketSell() {
   if (!TradingAllowed()) {
      market_sell_bt_.Pressed(false);
      return; 
   }
   market_sell_bt_.Pressed(true); 
   
   TradeMain.OrderSendMarketSell(); 
   
   market_sell_bt_.Pressed(false);
}


//+------------------------------------------------------------------+
//| ADJUSTMENTS                                                      |
//+------------------------------------------------------------------+

void        CTradeApp::OnClickIncrementLots() {
   double target_value  = TradeMain.Lots() + UTIL_SYMBOL_LOTSTEP(); 
   if (target_value > UTIL_SYMBOL_MAXLOT()) return; 
   UpdateLots(target_value); 
}

void        CTradeApp::OnClickDecrementLots() {
   double target_value  = TradeMain.Lots() - UTIL_SYMBOL_LOTSTEP(); 
   if (target_value < UTIL_SYMBOL_MINLOT()) return; 
   UpdateLots(target_value); 
   
}

void        CTradeApp::OnClickIncrementSLPoints() {
   int      target_value   = TradeMain.Increment(TradeMain.SLPoints()); 
   if (!ValidFieldInput(IntegerToString(target_value))) return; 
   TradeMain.SLPoints(target_value); 
   sl_field_.Text((string)TradeMain.SLPoints()); 
   UpdateRiskReward();
} 

void        CTradeApp::OnClickDecrementSLPoints() {
   int      target_value   = TradeMain.Decrement(TradeMain.SLPoints());
   if (!ValidFieldInput(IntegerToString(target_value))) return; 
   TradeMain.SLPoints(target_value); 
   sl_field_.Text((string)TradeMain.SLPoints());
   UpdateRiskReward();
}

void        CTradeApp::OnClickIncrementTPPoints() {
   int      target_value   = TradeMain.Increment(TradeMain.TPPoints());
   if (!ValidFieldInput(IntegerToString(target_value))) return; 
   TradeMain.TPPoints(target_value); 
   tp_field_.Text((string)TradeMain.TPPoints());
   UpdateRiskReward();
} 

void        CTradeApp::OnClickDecrementTPPoints() {   
   int      target_value   = TradeMain.Decrement(TradeMain.TPPoints()); 
   if (!ValidFieldInput(IntegerToString(target_value))) return; 
   TradeMain.TPPoints(target_value); 
   tp_field_.Text((string)TradeMain.TPPoints());
   UpdateRiskReward();
}


void        CTradeApp::OnClickIncrementBEPoints() {
   int   target_value   = TradeMain.Increment(TradeMain.BEPoints()); 
   if (!ValidFieldInput(IntegerToString(target_value))) return; 
   TradeMain.BEPoints(target_value); 
   be_field_.Text((string)TradeMain.BEPoints());
}

void        CTradeApp::OnClickDecrementBEPoints() {
   int target_value  = TradeMain.Decrement(TradeMain.BEPoints());
   if (!ValidFieldInput(IntegerToString(target_value))) return; 
   TradeMain.BEPoints(target_value); 
   be_field_.Text((string)TradeMain.BEPoints());
}

void        CTradeApp::OnClickIncrementTrailPoints() {
   int target_value  = TradeMain.Increment(TradeMain.TrailPoints()); 
   if (!ValidFieldInput(IntegerToString(target_value))) return;
   TradeMain.TrailPoints(target_value); 
   trail_field_.Text((string)TradeMain.TrailPoints()); 
}

void        CTradeApp::OnClickDecrementTrailPoints() {
   int target_value  = TradeMain.Decrement(TradeMain.TrailPoints());
   if (!ValidFieldInput(IntegerToString(target_value))) return;
   TradeMain.TrailPoints(target_value);
   trail_field_.Text((string)TradeMain.TrailPoints()); 
}

//+------------------------------------------------------------------+
//| FIELDS                                                           |
//+------------------------------------------------------------------+

void        CTradeApp::OnStartEditLotsField() {
   stored_lot_ = StringToDouble(lots_field_.Text()); 
}

void        CTradeApp::OnStartEditSLField() {
   stored_sl_  = (int)StringToInteger(sl_field_.Text()); 
}

void        CTradeApp::OnStartEditTPField() {
   stored_tp_  = (int)StringToInteger(tp_field_.Text());
}

void        CTradeApp::OnStartEditBEField() {
   stored_be_  = (int)StringToInteger(be_field_.Text()); 
}
void        CTradeApp::OnStartEditTrailField() {
   stored_trail_  = (int)StringToInteger(trail_field_.Text()); 
}
void        CTradeApp::OnEndEditSLField() {
   if (!ValidPointsField(sl_field_, stored_sl_)) return; 
   TradeMain.SLPoints((int)StringToInteger(sl_field_.Text()));
   sl_field_.Text((string)TradeMain.SLPoints()); 
   UpdateRiskReward();
}

void        CTradeApp::OnEndEditTPField() {
   
   if (!ValidPointsField(tp_field_, stored_tp_)) return; 
   TradeMain.TPPoints((int)StringToInteger(tp_field_.Text()));
   tp_field_.Text((string)TradeMain.TPPoints()); 
   UpdateRiskReward();

}

void        CTradeApp::OnEndEditLotsField() {

   string target_value  = lots_field_.Text(); 
   if (!ValidFieldInput(target_value)) {
      ValidationError(ERR_NON_NUMERIC, target_value, __FUNCTION__);
      lots_field_.Text(UTIL_LOT_STRING(stored_lot_)); 
      return;
   }
   if (!ValidLots((double)StringToDouble(target_value))) {
      ValidationError(ERR_INVALID_ADJUST, target_value, __FUNCTION__);
      lots_field_.Text(UTIL_LOT_STRING(stored_lot_)); 
      return;
   }
   
   TradeMain.Lots((double)StringToDouble(target_value));
   lots_field_.Text((string)TradeMain.Lots());
   UpdateRiskReward();
}


void        CTradeApp::OnEndEditBEField() {
   if (!ValidPointsField(be_field_, stored_be_)) return; 
   TradeMain.BEPoints((int)StringToInteger(be_field_.Text()));
   be_field_.Text((string)TradeMain.BEPoints()); 
   
}



void        CTradeApp::OnEndEditTrailField() {
   if (!ValidPointsField(trail_field_, stored_trail_)) return;
   TradeMain.TrailPoints((int)StringToInteger(trail_field_.Text())); 
   trail_field_.Text((string)TradeMain.TrailPoints()); 
}



//+------------------------------------------------------------------+
//| CHECKBOX                                                         |
//+------------------------------------------------------------------+

void        CTradeApp::OnChangeSLCheckbox() {
   TradeMain.SLEnabled(sl_checkbox_.Checked()); 
   Console_.LogInformation(StringFormat("SL Enabled: %s", (string)TradeMain.SLEnabled()), __FUNCTION__); 
}

void        CTradeApp::OnChangeTPCheckbox() {
   TradeMain.TPEnabled(tp_checkbox_.Checked()); 
   Console_.LogInformation(StringFormat("TP Enabled: %s", (string)TradeMain.TPEnabled()), __FUNCTION__); 
}


void        CTradeApp::OnChangeBECheckbox() {
   TradeMain.BEEnabled(be_checkbox_.Checked());
   Console_.LogInformation(StringFormat("BE Enabled: %s", (string)TradeMain.BEEnabled()), __FUNCTION__); 
}

void        CTradeApp::OnChangeTrailCheckbox() {
   TradeMain.TrailEnabled(trail_checkbox_.Checked()); 
   Console_.LogInformation(StringFormat("Trail Enabled: %s", (string)TradeMain.TrailEnabled()), __FUNCTION__); 
}


//+------------------------------------------------------------------+
//| BATCH OPERATIONS                                                 |
//+------------------------------------------------------------------+

void        CTradeApp::OnClickTrailAllPositions() {
   TradeMain.TrailAllPositions(); 
}

void        CTradeApp::OnClickBEAllPositions() {
   
   TradeMain.BreakevenAllPositions(); 
}
   
void        CTradeApp::OnClickCloseAllPositions() {
   TradeMain.CloseAllPositions(); 
}

void        CTradeApp::OnClickNews() {
   
   CNewsPanel  *news    = (CNewsPanel*)GetPointer(News); 
   string   panel_name  = news.NAME(); 
   if (PageIsOpen(panel_name) && news.IsVisible()) {
      return; 
   }
   if (!OpenPage(news)) Console_.LogError(StringFormat("Failed to open panel: %s", panel_name), __FUNCTION__); 
  
}

string      CTradeApp::ActiveName() {
   if (CheckPointer(ActiveDialog) == POINTER_INVALID) return ""; 
   CAppDialog *d  = (CAppDialog*)GetPointer(ActiveDialog); 
   return d.Caption(); 
}

bool        CTradeApp::PageIsOpen(string panel_name) {
   string name = ActiveName(); 
   
   if (CheckPointer(ActiveDialog) != POINTER_INVALID) {
      ActiveDialog.Destroy(1); 
   }
   if (name == panel_name) {
      CloseActiveWindow(); 
      return true; 
   }
   return false; 
}

template <typename T>
bool        CTradeApp::OpenPage(T &Page) {
   if (!Page.Create()) return false; 
   if (!Add(Page)) return false; 
   Page.Run();
   
   ActiveDialog   = Page;
   ActiveDialog.Visible(true);  
   return true; 
}

void        CTradeApp::CloseActiveWindow() { 
   CAppDialog *pt = (CAppDialog*)GetPointer(ActiveDialog);
   delete ActiveDialog; 
}

void        CTradeApp::Minimize() {
   if (CheckPointer(ActiveDialog) != POINTER_INVALID) ActiveDialog.Destroy(1); 
   CloseActiveWindow(); 
   CAppDialog::Minimize(); 
}

//+------------------------------------------------------------------+
//| VALIDATION                                                       |
//+------------------------------------------------------------------+

bool        CTradeApp::ValidValue(double value) {
   return value > 0; 
}

bool        CTradeApp::ValidLots(double value) {
   if (value < UTIL_SYMBOL_MINLOT()) return false; 
   if (value > UTIL_SYMBOL_MAXLOT()) return false; 
   if (value < 0) return false;
   return true; 
}

bool        CTradeApp::ValidPoints(int value) {
   
   if (value < TradeMain.MinPoints()) return false; 
   if (value < 0) return false; 
   return true; 
}


bool        CTradeApp::ValidFieldInput(string input_string) {
   /**
      Validates input field. Returns false if non-numerical character is found.
   **/
   int ch; 
   for (int i = 0; i < StringLen(input_string); i++) {
      ch = StringGetCharacter(input_string, i); 
      if (ch > 57) return false;
      if (ch < 48 && ch != 46) return false; 
   }
   return true; 
}

bool        CTradeApp::ValidPointsField(CEdit &field, int default_value) {
   /**
      Validates input string and points value for sl, tp, be input fields.
   **/
   string target_value  = field.Text(); 
   if (!ValidFieldInput(target_value)) {
      ValidationError(ERR_NON_NUMERIC, target_value, __FUNCTION__);
      field.Text(IntegerToString(default_value)); 
      return false;
   }
   if (!ValidPoints((int)StringToInteger(target_value))) {
      ValidationError(ERR_INVALID_ADJUST, target_value, __FUNCTION__);
      field.Text(IntegerToString(default_value)); 
      return false;
   }
   return true; 
}


void        CTradeApp::ValidationError(ENUM_VALIDATION_ERROR error,string target_value, string func) {
   string message; 
   switch(error) {
      case ERR_NON_NUMERIC: 
         message  = "Field contains non-numeric character."; 
         break;
      case ERR_INVALID_ADJUST:
         message  = "Value Limit Reached."; 
         break; 
      case ERR_NEGATIVE_VALUE:
         message  = "Negative value.";
         break;   
      default:
         message  = "Unkown Error."; 
         break; 
   }
   Console_.LogInformation(StringFormat("Error. %s Source: %s, Value: %s", message, func, target_value), __FUNCTION__); 
}

bool        CTradeApp::TradingAllowed() {
   if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      MessageBox("Error. Autotrading is disabled.", "Terminal Error");
      return false; 
   }
   if (!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
      MessageBox(StringFormat("Error. Automated trading is forbidden in the program settings for %s.", 
         MQLInfoString(MQL_PROGRAM_NAME)));
      return false; 
   }
   return true; 
}
//+------------------------------------------------------------------+
//| UPDATING                                                         |
//+------------------------------------------------------------------+

void        CTradeApp::UpdateValuesOnTick() {
   ask_label_.Text(UTIL_PRICE_STRING(UTIL_PRICE_ASK())); 
   bid_label_.Text(UTIL_PRICE_STRING(UTIL_PRICE_BID())); 
   TradeMain.BreakevenValidPositions(TradeMain.BEPoints()); 
   TradeMain.TrailValidPositions(); 
}

void        CTradeApp::UpdateRiskReward() {
   TradeMain.CalculateRiskParameters(); 
   risk_value_label_.Text(DollarValue(TradeMain.RiskUSD())); 
   reward_value_label_.Text(DollarValue(TradeMain.RewardUSD())); 
}

void        CTradeApp::UpdateLots(double value) {
   TradeMain.Lots(value);
   lots_field_.Text(UTIL_LOT_STRING(TradeMain.Lots()));
   UpdateRiskReward(); 
}

string      CTradeApp::BuyButtonString() const  { return StringFormat("Buy: %.5f", UTIL_PRICE_ASK()); }
string      CTradeApp::SellButtonString() const { return StringFormat("Sell: %.5f", UTIL_PRICE_BID()); }

//+------------------------------------------------------------------+
//| UTILITY                                                          |
//+------------------------------------------------------------------+

int         CTradeApp::WideButtonYOffset(int row) {
   return ((row)*(WIDE_BUTTON_HEIGHT+BUTTON_Y_SPACING)); 
}
