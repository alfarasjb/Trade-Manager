


#include "definition.mqh"

class CNewsEvents{

   protected:
   private:
      datetime    entry_window_open_, entry_window_close_;
      
      CConsole    *Console_;
   
   public:
      
      SCalendarEvent    NEWS_CURRENT[], NEWS_TODAY[], NEWS_SYMBOL_TODAY[], NEWS_IN_TRADING_WINDOW[];
      int         FILE_HANDLE;
      
      CNewsEvents();
      ~CNewsEvents();
      
      void        UpdateEntryWindow(datetime window_open, datetime window_end);
      
      int         FetchData();
      int         AppendToNews(SCalendarEvent &event, SCalendarEvent &news_data[]);
      int         DownloadNews(string file_name, Source src);
      int         GetNewsSymbolToday();
      
      datetime    DateToday();
      datetime    LatestWeeklyCandle();
      datetime    GetDate(datetime parse_datetime);
      datetime    ParseDates(string date, string time);
      
      int         ClearArray(SCalendarEvent &data[]);
      bool        DateMatch(datetime target, datetime reference);
      bool        SymbolMatch(string country);
      bool        ArrayIsEmpty(SCalendarEvent &data[]);
      bool        FileExists(string file_path);
      bool        HighImpactNewsToday();
      int         NumNews();
      int         NumNewsToday();
      int         NumNewsInWindow();
      int         ClearHandle();
      int         GetHighImpactNewsInEntryWindow(datetime entry_open, datetime entry_close);
      bool        HighImpactNewsInEntryWindow();
      string      Directory();
      int         ParseFXFactoryData(int handle);
      int         ParseR4FData(int handle);
      string      ParseImpact(string impact);
      
      
      //--- MAIN FUNCTIONALITY 
      int         EventsToday(); 
      
};


CNewsEvents::CNewsEvents(void){
   Console_ = new CConsole(true, false, false); 
}

CNewsEvents::~CNewsEvents(void){
   ClearHandle();
   delete Console_; 
}

void        CNewsEvents::UpdateEntryWindow(datetime window_open,datetime window_end){
   entry_window_open_ = window_open;
   entry_window_close_ = window_end;
}

int         CNewsEvents::ClearHandle(void){
   FileClose(FILE_HANDLE);
   FileFlush(FILE_HANDLE);
   FILE_HANDLE = 0;
   return FILE_HANDLE;
}

int         CNewsEvents::FetchData(void){
   /**
      Fetches news data and adds to NEWS_CURRENT Data structure
      
      Called every week or if target filename does not exist. 
      
      Sources: ForexFactory / Robots4Forex 
   **/
   
   
   if (UTIL_IS_TESTING()) return 0; 

   ResetLastError();
   //--- Clears Array Contents and handle. 
   ClearArray(NEWS_CURRENT);
   ClearHandle();

   //--- Used as filename of news csv. 
   datetime latest = LatestWeeklyCandle(); 
   int delta = (int)(TimeCurrent() - latest); 
   int weekly_delta = PeriodSeconds(PERIOD_W1);
   
   datetime file_date = delta > weekly_delta ? latest + weekly_delta : latest;
   
   string file_name = StringFormat("%s.csv", TimeToString(file_date, TIME_DATE));
   string file_path = StringFormat("%s\\%s", Directory(), file_name);

   //--- Download from internet if file does not exist. 
   if (!FileIsExist(file_path)) {
      Console_.LogError(StringFormat("File %s not found. Downloading from forex factory.", file_path), __FUNCTION__);
      if (DownloadNews(file_name, InpNewsSource) == -1) Console_.LogError(StringFormat("Download Failed. Error: %i", GetLastError()), __FUNCTION__);
   }
   else Console_.LogInformation(StringFormat("File %s found", file_path), __FUNCTION__);
   
   
   FILE_HANDLE = FileOpen(file_path, FILE_CSV | FILE_READ | FILE_ANSI, "\n");
   if (FILE_HANDLE == -1) return -1;
   
   switch(InpNewsSource) {
      //--- Files are not structured in the same way 
      case FXFACTORY_WEEKLY:     ParseFXFactoryData(FILE_HANDLE); break; 
      case R4F_WEEKLY:           ParseR4FData(FILE_HANDLE); break;
   }
   
   GetNewsSymbolToday();
   ClearHandle();
   return NumNews();
}

int         CNewsEvents::ParseFXFactoryData(int handle) { 
   /**
      Parse data received from forex factory
   **/
   string result[];
   int line = 0;
   while (!FileIsLineEnding(handle)) {
      string file_string = FileReadString(handle);
      
      int split = (int)StringSplit(file_string, ',', result);
      line++; 
      if (line == 1) continue;
      
      SCalendarEvent event; 
      event.title = result[0];
      event.country = result[1];
      event.time = ParseDates(result[2], result[3]);
      event.impact = result[4];
      event.forecast = result[5];
      event.previous = result[6];
      AppendToNews(event, NEWS_CURRENT);
      
   }
   
   return NumNews();
}

int         CNewsEvents::ParseR4FData(int handle) { 
   /**
      Parse data received from robots4forex
   **/
   string result [];
   int line = 0;
   while(!FileIsLineEnding(handle)) { 
      string file_string = FileReadString(handle);
      
      int split = (int)StringSplit(file_string, ',', result);
      
      if (split == 0) break;
      if (StringFind(result[0], "/", 0) < 0) continue; 
      
      StringReplace(result[0], "/", ".");
      string datetime_string = result[0] + " " + result[1];
      
      MqlDateTime r4fdate;
      TimeToStruct(StringToTime(datetime_string), r4fdate);
      r4fdate.hour = r4fdate.hour + 2; 
      
      datetime r4fdatetime = StructToTime(r4fdate);
      
      SCalendarEvent event;
      event.title = result[4];
      event.time = r4fdatetime;
      event.country = result[2];
      event.impact = ParseImpact(result[3]);      
      
      AppendToNews(event, NEWS_CURRENT);
      
   }
   return 0;
}

string         CNewsEvents::ParseImpact(string impact) { 
   if (impact == "H") return "High";
   if (impact == "M") return "Medium";
   if (impact == "L") return "Low";
   if (impact == "N") return "Neutral";
   return "";
}

bool           CNewsEvents::FileExists(string file_path){
   int handle = FileOpen(file_path, FILE_CSV | FILE_READ | FILE_ANSI, "\n");
   if (handle == -1) return false;
   FileClose(handle);
   FileFlush(handle);
   return true;
}

datetime       CNewsEvents::ParseDates(string date, string time){
   /**
      Converts download datetime to server time
   **/

   string result[];
   ushort u_sep = StringGetCharacter("-", 0);
   int split = StringSplit(date, u_sep, result);
   
   
   if (split == 0) return 0;
   int gmt_offset = (int)MathAbs(TimeGMTOffset());
   int server_offset = (int)(TimeLocal() - TimeCurrent());
   
   int gmt_offset_hours = gmt_offset / PeriodSeconds(PERIOD_H1);
   int server_offset_hours = server_offset / PeriodSeconds(PERIOD_H1);
   int gmt_server_offset_hours = gmt_offset_hours - server_offset_hours - 1;
   
   int gmt_server_offset_seconds = gmt_server_offset_hours * PeriodSeconds(PERIOD_H1);
   
   
   datetime time_string = StringToTime(time);
   MqlDateTime event_date, event_time;
   TimeToStruct(time_string, event_time);
   TimeToStruct(date, event_date);
   
   bool IsPM = StringFind(time, "pm") > -1 ? true : false;
   
   event_time.mon = (int)result[0]; 
   event_time.day = (int)result[1];
   event_time.year = (int)result[2];
   event_time.hour = !IsPM ? event_time.hour == 12 ? 0 : event_time.hour : event_time.hour != 12 ? event_time.hour + 12 : event_time.hour;
   
   
   // GMT DATETIME
   datetime event = StructToTime(event_time);
   
   datetime final_dt = event + gmt_server_offset_seconds;
   return final_dt;
}


int         CNewsEvents::GetNewsSymbolToday(void){
   /**
      Iterates through main dataset and identify symbol and date. 
      
      Appends to news today: High Impact and holiday 
      
      News filter can be manually modified depending on model requirements. 
      
      For this algo, only filter holidays. 
   **/
   
   
   ClearArray(NEWS_SYMBOL_TODAY);
   int size = NumNews();
  
   
   for (int i = 0; i < size; i++){
       
       if (!SymbolMatch(NEWS_CURRENT[i].country)) continue; 
       
       if (!DateMatch(DateToday(), NEWS_CURRENT[i].time)) continue; 
       AppendToNews(NEWS_CURRENT[i], NEWS_SYMBOL_TODAY); 
   }
   return ArraySize(NEWS_SYMBOL_TODAY);
}

int         CNewsEvents::EventsToday() {
   
   ClearArray(NEWS_TODAY);
   int size = NumNews(); 
   
   for (int i = 0; i < size; i++) {
      if (!DateMatch(DateToday(), NEWS_CURRENT[i].time)) continue; 
      AppendToNews(NEWS_CURRENT[i], NEWS_TODAY); 
   }
   return ArraySize(NEWS_TODAY); 
}

bool        CNewsEvents::HighImpactNewsToday(void) {
   if (ArraySize(NEWS_SYMBOL_TODAY) == 0) return false;
   if (InpTradeOnNews) return false;
   return true; 
}

int         CNewsEvents::GetHighImpactNewsInEntryWindow(datetime entry_open,datetime entry_close){
   // REFRESH THIS EVERY DAY 
   
   ClearArray(NEWS_IN_TRADING_WINDOW);
   int size = ArraySize(NEWS_SYMBOL_TODAY);
   
   for (int i = 0; i < size; i ++){
      datetime news_time = NEWS_SYMBOL_TODAY[i].time;
      //Print(NEWS_SYMBOL_TODAY[i].title, news_time);
      if (news_time < entry_open) continue; // before
      if (news_time > entry_close) continue; // after 
      AppendToNews(NEWS_SYMBOL_TODAY[i], NEWS_IN_TRADING_WINDOW);
   }
   return NumNewsInWindow();
}

bool        CNewsEvents::HighImpactNewsInEntryWindow(void){

   if (InpTradeOnNews) return false; 
   if (ArraySize(NEWS_IN_TRADING_WINDOW) == 0) return false;
   return true;
}

int         CNewsEvents::AppendToNews(SCalendarEvent &event, SCalendarEvent &news_data[]){
   
   int size = ArraySize(news_data);
   ArrayResize(news_data, size + 1);
   news_data[size] = event; 
   
   
   return ArraySize(news_data);
}


int         CNewsEvents::DownloadNews(string file_name, Source src) { 
   CCalendarDownload *downloader = new CCalendarDownload(Directory(), 50000);
   
   
   bool success = downloader.DownloadFile(file_name, src);
   
   delete downloader;
   if (!success) return -1; 
   return NumNews();
}



datetime    CNewsEvents::GetDate(datetime parse_datetime){
   MqlDateTime dt_struct;
   TimeToStruct(parse_datetime, dt_struct);
   
   dt_struct.hour = 0;
   dt_struct.min = 0;
   dt_struct.sec = 0; 
   
   return StructToTime(dt_struct);
}

int         CNewsEvents::ClearArray(SCalendarEvent &data[]){
   ArrayFree(data);
   ArrayResize(data, 0);
   return ArraySize(data);
}

bool        CNewsEvents::DateMatch(datetime target,datetime reference){
   if (StringFind(TimeToString(target), TimeToString(reference, TIME_DATE)) == -1) return false;
   return true;
}

bool        CNewsEvents::SymbolMatch(string country){
   int match = StringFind(Symbol(), country);
   //PrintFormat("FIND: %s, COUNTRY: %s, RESULT: %i", Symbol(), country, match);
   
   if (StringFind(Symbol(), country) == -1) return false;
   return true;
}

bool        CNewsEvents::ArrayIsEmpty(SCalendarEvent &data[]){
   if (ArraySize(data) == 0) return true; 
   return false;
}

string      CNewsEvents::Directory(void) { 
   switch(InpNewsSource) { 
      case FXFACTORY_WEEKLY:  return FXFACTORY_DIRECTORY; 
      case R4F_WEEKLY:        return R4F_DIRECTORY;
   }
   return "";
}

datetime    CNewsEvents::LatestWeeklyCandle()      { return iTime(Symbol(), PERIOD_W1, 0); }
datetime    CNewsEvents::DateToday(void)           { return (GetDate(TimeCurrent())); }
int         CNewsEvents::NumNews(void)             { return ArraySize(NEWS_CURRENT); }
int         CNewsEvents::NumNewsToday(void)        { return ArraySize(NEWS_SYMBOL_TODAY); }
int         CNewsEvents::NumNewsInWindow(void)     { return ArraySize(NEWS_IN_TRADING_WINDOW); }