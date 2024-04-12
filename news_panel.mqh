

// TODO

#include "forex_factory.mqh"

#include <Controls/Listview.mqh>

class CNewsObject : public CAppDialog {
private:
   SCalendarEvent    event_; 
   CLabel            date_label_, title_label_, impact_label_; 
public:
   CNewsObject(SCalendarEvent &event); 
   ~CNewsObject(); 
            
            bool        Create(); 
}; 

CNewsObject::CNewsObject(SCalendarEvent &event) {
   event_ = event; 
   Create(); 
}

CNewsObject::~CNewsObject() {
}

bool        CNewsObject::Create() {
   if (!date_label_.Create(0, TimeToString(event_.date), 0, 10, 10, 50, 20)) return false; 
   return true;    
}

class CNewsPanel : public CAppDialog {
private: 
            double      dpi_scale_; 
            string      name_; 
            
            CNewsEvents news_events; 
            
            CNewsObject *news_objects[]; 
   
public:
   CNewsPanel(); 
   ~CNewsPanel(); 
            
            
            string      NAME() const { return name_; }
            int         Scale(double value)     { return (int)MathRound(value * dpi_scale_); }
   
   virtual  bool        Create(); 
   virtual  bool        RowCreate(); 
   virtual  void        OnClickButtonMinMax(); 
   virtual  void        OnClickButtonClose(); 

}; 


CNewsPanel::CNewsPanel() {
   name_ = "news";
   double screen_dpi = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   dpi_scale_  = screen_dpi / 96;
   int num_news = news_events.FetchData(); 
   Print("NEWS: ", num_news); 
   int news_today = news_events.GetNewsSymbolToday();
   Print("Today: ", news_today); 
   
}

CNewsPanel::~CNewsPanel() { }



bool        CNewsPanel::Create() {
   int x1      = Scale(MAIN_PANEL_WIDTH + 20);
   int y1      = Scale(NEWS_PANEL_Y1);
   int x2      = Scale(x1 + NEWS_PANEL_WIDTH);
   int y2      = Scale(y1 + NEWS_PANEL_HEIGHT); 
   if (!CAppDialog::Create(0, name_, 0, x1, y1, x2, y2)) return false; 
   
   CNewsObject *obj = new CNewsObject(news_events.NEWS_SYMBOL_TODAY[0]); 
   
   return true;
}


void        CNewsPanel::OnClickButtonMinMax() {
   Visible(false); 
   
}

void        CNewsPanel::OnClickButtonClose() {}