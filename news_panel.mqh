

// TODO

#include "forex_factory.mqh"

#include <Controls/Listview.mqh>

class CNewsObject : public CAppDialog {
private:
   SCalendarEvent    event_; 
public:
   CNewsObject(SCalendarEvent &event); 
   ~CNewsObject(); 
            
            CLabel      country_label_, title_label_, time_label_, impact_label_;  
            //CLabel*     CountryLabel()    const { return GetPointer(country_label_); }
            SCalendarEvent Event()        const { return event_; }
            string      EventTitle()     const { return event_.title; }
            
            bool        Create(int col1, int col2, int col3, int col4); 
            
}; 

CNewsObject::CNewsObject(SCalendarEvent &event) {
   event_ = event; 
}

CNewsObject::~CNewsObject() {
}

class CNewsPanel : public CAppDialog {
private: 
            
            
            
            int         wnd_x1_, wnd_y1_, wnd_x2_, wnd_y2_; 
            
            double      dpi_scale_; 
            string      name_; 
            
            CNewsEvents news_events; 
            
            CNewsObject *news_objects[]; 
            
            //--- Grid
            int         col_1_, col_2_, col_3_, col_4_; 
            
            //--- Header Elements 
            CLabel      country_label_, title_label_, time_label_, impact_label_; 
            
            //--- Sample
            CLabel      event_country_, event_title_, event_time_, event_impact_; 
            
            //--- List
            CListView   events_list_;
            
            bool        CreateHeader(); 
            bool        CreateLabel(CLabel &lbl, string name, int x, int row); 
   
public:
   CNewsPanel(); 
   ~CNewsPanel(); 
            
            
            int         Col1()   const    { return col_1_; }
            int         Col2()   const    { return col_2_; }
            int         Col3()   const    { return col_3_; }
            int         Col4()   const    { return col_4_; }
            
            string      NAME() const { return name_; }
            int         Scale(double value)     { return (int)MathRound(value * dpi_scale_); }
   
   virtual  bool        Create(); 
   virtual  bool        CreateRow(); 
   virtual  void        OnClickButtonMinMax(); 
   virtual  void        OnClickButtonClose(); 
   
            void        GenerateNews(); 
            void        ClearObjects(); 
            bool        CreateList(); 

}; 


CNewsPanel::CNewsPanel() {
   name_ = "news";
   double screen_dpi = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   dpi_scale_  = screen_dpi / 96;
   
   int num_news = news_events.FetchData();
   
   wnd_x1_  = MAIN_PANEL_WIDTH;
   wnd_y1_  = -25; 
   wnd_x2_  = wnd_x1_ + NEWS_PANEL_WIDTH; 
   wnd_y2_  = wnd_y1_ + NEWS_PANEL_HEIGHT; 
   
   col_1_      = 10; 
   col_2_      = 70; 
   col_3_      = 320; 
   col_4_      = 380; 
   
   GenerateNews();
   
}

CNewsPanel::~CNewsPanel() {
   ClearObjects(); 

}

void        CNewsPanel::ClearObjects() {
   int size = ArraySize(news_objects); 
   for (int i = 0; i < size; i++) delete news_objects[i]; 
}

void        CNewsPanel::GenerateNews() {
   //-- don't forget to delete the objects 
   CNewsObject *news_obj   = new CNewsObject(news_events.NEWS_CURRENT[0]); 
   
   int size=ArraySize(news_objects); 
   ArrayResize(news_objects, size+1); 
   news_objects[size] = news_obj; 
   
   CNewsObject *test_obj = news_objects[0]; 
   Print("TEST: ", test_obj.EventTitle()); 
}

bool        CNewsPanel::CreateList() {
   if (!events_list_.Create(0, "events_list", 0, 0, 30, NEWS_PANEL_WIDTH-5, NEWS_PANEL_HEIGHT-25)) return false; 
   events_list_.VScrolled(true); 
   events_list_.ItemAdd("HELLO"); 
   if (!Add(events_list_)) return false; 
   return true; 
}


bool        CNewsPanel::Create() {
   if (!CAppDialog::Create(0, name_, 0, wnd_x1_, wnd_y1_, Scale(wnd_x2_), Scale(wnd_y2_))) return false; 
   if (!CreateHeader()) return false; 
   //if (!CreateRow()) return false; 
   //CNewsObject *obj = new CNewsObject(news_events.NEWS_SYMBOL_TODAY[0]); 
   if (!CreateList()) return false; 
   CAppDialog::Maximize(); 
   
   return true;
}


bool        CNewsPanel::CreateRow() {
   int row = 1; 
   
   int country_x1 = Col1() + 5; 
   int title_x1   = Col2(); 
   int time_x1    = Col3(); 
   int impact_x1  = Col4() + 5; 
   
   CNewsObject *test = news_objects[0]; 
   SCalendarEvent event = test.Event(); 
   
   
   if (!CreateLabel(test.country_label_, event.country, country_x1, 2)) return false; 
   if (!CreateLabel(test.title_label_, event.title, title_x1, 2)) return false;
   if (!CreateLabel(test.time_label_, TimeToString(event.time, TIME_MINUTES), time_x1, 2)) return false; 
   if (!CreateLabel(test.impact_label_, event.impact, impact_x1, 2)) return false; 
   return true; 
}


bool        CNewsPanel::CreateLabel(CLabel &lbl, string name, int x, int row) {
   int y_offset   = (20 * (row-1)); 

   int y1   = 10 + y_offset; 
   int x2   = x + 50; 
   int y2   = y1 + 20; 
   
   if (!lbl.Create(0, name+"label", 0, x, y1, x2, y2)) return false; 
   if (!lbl.Text(name)) return false; 
   if (!Add(lbl)) return false;  
   return true; 
}

bool        CNewsPanel::CreateHeader() {
   int x1   = Scale(MAIN_PANEL_WIDTH + 50);
   int y1   = Scale(NEWS_PANEL_Y1 + 100); 
   int x2   = Scale(x1 + 50);
   int y2   = Scale(y1 +50);
   if (!CreateLabel(country_label_, "Country", Col1(), 1)) return false; 
   if (!CreateLabel(title_label_, "Title", Col2(), 1)) return false; 
   if (!CreateLabel(time_label_, "Time", Col3(), 1)) return false; 
   if (!CreateLabel(impact_label_, "Impact", Col4(), 1)) return false; 
   return true; 
}

void        CNewsPanel::OnClickButtonMinMax() {
   Visible(false); 
   
}

void        CNewsPanel::OnClickButtonClose() {}