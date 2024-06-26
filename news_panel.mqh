//--- UNDER CONSTRUCTION 

// TODO

#include "events.mqh"

#include <Controls/Listview.mqh>



class CNewsObject : public CAppDialog {
/*
   Used to hold information on a news event, and their labels 
*/
private:
   SCalendarEvent    event_; 
   int               id_; 
   
   //--- Label Names 
   string            country_label_name_, title_label_name_, time_label_name_, impact_label_name_; 
   
public:
   CNewsObject(SCalendarEvent &event, const int id); 
   ~CNewsObject(); 
            
            CLabel      country_label_, title_label_, time_label_, impact_label_;  
            SCalendarEvent Event()           const { return event_; }
            string      EventTitle()         const { return event_.title; }
            string      EventCountry()       const { return event_.country; }
            string      EventTime()          const { return TimeToString(event_.time); }
            string      EventImpact()        const { return event_.impact; }
            
            //--- Label Names
            string      CountryLabelName()   const { return country_label_name_; }
            string      TitleLabelName()     const { return title_label_name_; }
            string      TimeLabelName()      const { return time_label_name_; }
            string      ImpactLabelName()    const { return impact_label_name_; }
            
            
            bool        Create(int col1, int col2, int col3, int col4); 
            bool        ClearLabel(); 
            
}; 

CNewsObject::CNewsObject(SCalendarEvent &event,const int id) {
   event_ = event; 
   id_ = id; 
   
   country_label_name_  = StringFormat("%i_%s", id_, event_.country); 
   title_label_name_    = StringFormat("%i_%s", id_, event_.title);
   time_label_name_     = StringFormat("%i_%s", id_, event_.time); 
   impact_label_name_   = StringFormat("%i_%s", id_, event_.impact); 
}

CNewsObject::~CNewsObject() {
}

bool     CNewsObject::ClearLabel() {
   country_label_.Destroy(1); 
   title_label_.Destroy(1);
   time_label_.Destroy(1);
   impact_label_.Destroy(1);
   return true;    
}

class CNewsPanel : public CAppDialog {
private: 
            
            
            
            int         wnd_x1_, wnd_y1_, wnd_x2_, wnd_y2_; 
            
            double      dpi_scale_; 
            string      name_; 
            
            CEvents news_events; 
            
            CNewsObject *news_objects[]; 
            
            //--- Grid
            int         col_1_, col_2_, col_3_, col_4_; 
            
            //--- Header Elements 
            //CLabel      country_label_, title_label_, time_label_, impact_label_; 
            CLabel      country_header_, title_header_, time_header_, impact_header_; 
            
            //--- Contents
            ushort      string_max_length_; 
            
            //--- Navigation
            CLabel      page_num_label_;
            CButton     next_page_bt_, prev_page_bt_; 
            ushort      page_, page_max_, page_min_, num_elements_per_page_; 
            
            CNewsObject *page_info_[]; 
            
            bool        CreateHeader(); 
            bool        CreateLabel(CLabel &lbl, string name, int x, int row); 
            bool        CreateNewsLabel(CLabel &lbl, string name, string text, int x, int row); 
            bool        CreateNavigation(); 
            bool        CreatePageLabel(const int page); 
            
            bool        ClearExistingLabels(); 
            int         AddPageInfo(CNewsObject *obj);
            
            int         Col1()   const    { return col_1_; }
            int         Col2()   const    { return col_2_; }
            int         Col3()   const    { return col_3_; }
            int         Col4()   const    { return col_4_; }
            
            int         Scale(double value)     { return (int)MathRound(value * dpi_scale_); }
   
            ushort      Page()   const    { return page_; }
            void        Page(int pg)      { page_ = (ushort)MathAbs(pg); }           
   
   virtual  bool        CreateRow(); 
   virtual  void        OnClickButtonMinMax(); 
   virtual  void        OnClickButtonClose(); 
   
            void        GenerateNews(); 


      //--- EVENT HANDLERS
            void        OnClickNextPage();
            void        OnClickPrevPage(); 
            
         EVENT_MAP_BEGIN(CNewsPanel)
         ON_NAMED_EVENT(ON_CLICK, next_page_bt_, OnClickNextPage);
         ON_NAMED_EVENT(ON_CLICK, prev_page_bt_, OnClickPrevPage); 
         EVENT_MAP_END(CAppDialog)
     
public:
   CNewsPanel(); 
   ~CNewsPanel(); 
            
   virtual  bool        Create(); 
            string      NAME() const { return name_; }            
            void        InitializeEvents();             
            void        ClearObjects(); 
            bool        PageButtonPressed(const string sparam); 
}; 


CNewsPanel::CNewsPanel() {
   Print(__FUNCTION__, " Constructor Called"); 
   name_ = "news";
   double screen_dpi = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   dpi_scale_  = screen_dpi / 96;
      
   wnd_x1_  = Scale(MAIN_PANEL_WIDTH);
   wnd_y1_  = -25; 
   wnd_x2_  = wnd_x1_ + NEWS_PANEL_WIDTH; 
   wnd_y2_  = wnd_y1_ + NEWS_PANEL_HEIGHT; 
   
   col_1_      = 10; 
   col_2_      = 65; 
   col_3_      = 290; 
   col_4_      = 400; 
   
   page_       = 1; 
   page_min_   = 1; 
   num_elements_per_page_  = 13; 
   
   string_max_length_   = 30; 
   
   InitializeEvents(); 
   
}


CNewsPanel::~CNewsPanel() {
   Print(__FUNCTION__, ": Destructor Called"); 
   ClearObjects(); 

}

void        CNewsPanel::ClearObjects() {
   int size = ArraySize(news_objects); 
   for (int i = 0; i < size; i++) delete news_objects[i]; 
}

void        CNewsPanel::InitializeEvents() {
   news_events.Initialize();
   double num_news   = (double)news_events.FetchData();
   double num_query  = (double)news_events.Query(InpCountryFilter, InpDateFilter, InpImpactFilter); 
   
   double max        = num_query / num_elements_per_page_; 
   page_max_         = (int)max < max ? (int)(max)+1 : (int)max;
   
   GenerateNews(); 
   
}

void        CNewsPanel::GenerateNews() {
   //--- CORRECT PROCEDURE 
   ClearObjects(); 
   int num_news   = news_events.NumTargetEvents(); 
   ArrayResize(news_objects, num_news); 
   for (int i = 0; i < num_news; i++) { 
      CNewsObject *obj  = new CNewsObject(news_events.EventTarget(i), i); 
      news_objects[i] = obj; 
    }
}

bool        CNewsPanel::Create() {
   if (!CAppDialog::Create(0, name_, 0, wnd_x1_, wnd_y1_, Scale(wnd_x2_), Scale(wnd_y2_))) return false; 
   if (!CreateHeader()) return false; 
   //--- CREATE PAGE BUTTONS 
   if (!CreateNavigation()) return false; 
   
   CAppDialog::Maximize(); 
   
   return true;
}


bool        CNewsPanel::CreateNavigation() {

   const int bt_height  = 30;
   const int bt_width   = 100; 
   const int bt_y1      = 310; 
   const int bt_y2      = bt_y1 + bt_height; 
   
   const int nxt_pg_bt_x2_    = Scale(NEWS_PANEL_WIDTH + 40); 
   const int nxt_pg_bt_x1_    = nxt_pg_bt_x2_ - Scale(bt_width);
   
   //if (!next_page_bt_.Create(0, "Next Page", 0, Scale(Col3()+50), Scale(bt_y1), Scale(Col3() + bt_width+50), Scale(bt_y2))) return false; 
   if (!next_page_bt_.Create(0, "Next Page", 0 ,nxt_pg_bt_x1_, Scale(bt_y1), nxt_pg_bt_x2_, Scale(bt_y2))) return false; 
   if (!next_page_bt_.Text("Next Page")) return false; 
   if (!Add(next_page_bt_)) return false; 
   
   if (!prev_page_bt_.Create(0, "Prev Page", 0, Scale(Col1()), Scale(bt_y1), Scale(Col1() + bt_width), Scale(bt_y2))) return false;
   if (!prev_page_bt_.Text("Prev Page")) return false; 
   if (!Add(prev_page_bt_)) return false; 
   
   if (!CreatePageLabel(Page())) return false; 
   if (!CreateRow()) return false; 
   return true; 
}

bool        CNewsPanel::CreatePageLabel(const int page) {
   const int page_label_x1 = Scale(NEWS_PANEL_WIDTH / 2);
   //if (!page_num_label_.Create(0, "Page", 0, Scale(Col2() + 150), Scale(315), Scale(Col3() - 20), Scale(340))) return false; 
   if (!page_num_label_.Create(0, "Page", 0, page_label_x1, Scale(315), Scale(Col3() - 20), Scale(340))) return false; 
   if (!page_num_label_.Text((string)page)) return false; 
   if (!Add(page_num_label_)) return false; 
   return true; 
}

bool        CNewsPanel::CreateRow() {
   //int row = 1; 
   
   int country_x1 = Col1() + 5; 
   int title_x1   = Col2(); 
   int time_x1    = Col3(); 
   int impact_x1  = Col4() + 5; 
   
   int page = Page(); 
   int starting_index   = ((page-1) * num_elements_per_page_); 
   int ending_index     = starting_index + num_elements_per_page_; 
   
   //--- This block clears existing labels 
   
   ClearExistingLabels(); 
   
   for (int i = starting_index; i < ending_index; i++) {
      //--- Index Exceeds available objects 
      if (i >= ArraySize(news_objects)) break; 
      
      CNewsObject *obj = news_objects[i]; 
      
      int row = (i-((page-1)*num_elements_per_page_))+2; 
      if (!CreateNewsLabel(obj.country_label_, obj.CountryLabelName(), obj.EventCountry(), country_x1, row)) return false; 
      if (!CreateNewsLabel(obj.title_label_, obj.TitleLabelName(), StringSubstr(obj.EventTitle(), 0, string_max_length_), title_x1, row)) return false; 
      if (!CreateNewsLabel(obj.time_label_, obj.TimeLabelName(), obj.EventTime(), time_x1, row)) return false; 
      if (!CreateNewsLabel(obj.impact_label_, obj.ImpactLabelName(), obj.EventImpact(), impact_x1, row)) return false;
      
      AddPageInfo(obj); 
      
   }
   
   return true; 
}

int         CNewsPanel::AddPageInfo(CNewsObject *obj) {
   /*
      Adds to array of visible objects 
   */
   int size = ArraySize(page_info_); 
   ArrayResize(page_info_, size+1);
   page_info_[size] = obj; 
   return ArraySize(page_info_); 
}

bool        CNewsPanel::ClearExistingLabels() {
   /*
      Deletes labels of existing objects. 
      
      Called when page is changed
   */
   int size = ArraySize(page_info_);
   for (int i = 0; i < size; i++) {
      CNewsObject *obj     = page_info_[i];
      if (CheckPointer(obj) == POINTER_INVALID) continue;
      obj.ClearLabel(); 
   }
   ArrayFree(page_info_); 
   return true; 
}

bool        CNewsPanel::CreateNewsLabel(CLabel &lbl,string name,string text,int x,int row) {
   int y_offset = (20 * (row - 1));
   
   int x1      = Scale(x); 
   int y1      = Scale(10 + y_offset);
   int x2      = x1 + Scale(50); 
   int y2      = y1 + Scale(20); 
   
   if (!lbl.Create(0, name, 0, x1, y1, x2, y2)) return false;
   if (!lbl.Text(text)) return false; 
   if (!Add(lbl)) return false; 
   return true; 
}


bool        CNewsPanel::CreateLabel(CLabel &lbl, string name, int x, int row) {

   int y_offset   = (20 * (row-1)); 

   int x1   = Scale(x); 
   int y1   = Scale(10 + y_offset); 
   int x2   = x1 + Scale(50); 
   int y2   = y1 + Scale(20); 
   
   string label_name = name+"label"; 
   
   if (!lbl.Create(0, label_name, 0, x1, y1, x2, y2)) return false; 
   if (!lbl.Text(name)) return false; 
   if (!Add(lbl)) return false;  
   return true; 
}

bool        CNewsPanel::CreateHeader() {

   if (!CreateLabel(country_header_, "Country", Col1(), 1)) return false; 
   if (!CreateLabel(title_header_, "Title", Col2(), 1)) return false; 
   if (!CreateLabel(time_header_, "Time", Col3(), 1)) return false; 
   if (!CreateLabel(impact_header_, "Impact", Col4(), 1)) return false; 
   return true; 
}



//--- EVENTS
void        CNewsPanel::OnClickButtonMinMax() {
   Visible(false); 
   
}

void        CNewsPanel::OnClickButtonClose() {}

void        CNewsPanel::OnClickNextPage() {
   if (Page() >= page_max_) return; 
   int pg   = Page()+1; 
   Page(pg); 
   page_num_label_.Text((string)Page()); 
   CreateRow();
}

void        CNewsPanel::OnClickPrevPage() {
   if (Page() <= page_min_) return; 
   int pg   = Page()-1; 
   Page(pg);
   page_num_label_.Text((string)Page()); 
   CreateRow();
}

bool        CNewsPanel::PageButtonPressed(const string sparam) {
   if (sparam == next_page_bt_.Name()) return true;
   if (sparam == prev_page_bt_.Name()) return true;
   return false; 
}