
/*
   UNDER CONSTRUCTION
*/



#include "definition.mqh"




class CEvents : public CCalendarDownload {
private:
         
         CConsole    *Console_; 
         int         file_handle_;
   
         
   
         int         ClearHandle(); 
         
         template <typename T> int  ClearArray(T &src[]); 
         datetime    LatestWeeklyCandle() const; 
         datetime    FileDate(); 
         
         bool        SymbolMatch(const string country); 
         bool        FilterCountry(ENUM_COUNTRY_FILTERS country_filter, const string country);
         bool        FilterDate(ENUM_DATE_FILTERS date_filter, const datetime target);
         bool        FilterImpact(ENUM_IMPACT_FILTERS impact_filter, const string impact); 
         ENUM_IMPACT_FILTERS  ImpactToEnum(const string impact); 
public:
   
   /*
      events_all_: stores all events in downloaded csv file 
      events_target_: stores queried events
   */
   SCalendarEvent    events_all_[], events_target_[]; 
   
   CEvents();
   ~CEvents(); 
            string      Directory()    const { return R4F_DIRECTORY; }
         
            int         FetchData(); 
            int         DownloadNews(const string file_name); 
            int         Parse(const int handle); 
            int         Query(ENUM_COUNTRY_FILTERS country=COUNTRY_ALL, ENUM_DATE_FILTERS date=DATE_TODAY, ENUM_IMPACT_FILTERS impact=IMPACT_ALL); 

         

         //--- ARRAY OPERATIONS 
            int         AddEvent(SCalendarEvent &event, SCalendarEvent &dst[]); 
            int         NumAllEvents() const;
            int         NumTargetEvents() const; 
         
         //--- UTILITIES
            datetime    DateToday() const; 
}; 

CEvents::CEvents() 
   : CCalendarDownload(Directory(), 50000, InpTimeMode) {
   
   Console_    = new CConsole(true, false, false); 
}

CEvents::~CEvents() {
   delete Console_; 
}


int         CEvents::FetchData() {
   /*
      Fetches data and stores into events_all_. 
      
      If file does not exist, new file is downloaded from url
   */
   
   if (UTIL_IS_TESTING()) return 0; 
   
   ResetLastError(); 
   
   //--- Clear contents and handle
   ClearArray(events_all_);
   ClearHandle(); 
   
   string file_name  = StringFormat("%s.csv", TimeToString(FileDate(), TIME_DATE)); 
   string file_path  = StringFormat("%s\\%s", Directory(), file_name); 
   
   //--- Download new file if specified file for this week does not exist
   if (!FileIsExist(file_path)) {
      Console_.LogError(StringFormat("File %s not found. Downloading new file.", file_path), __FUNCTION__); 
      if (!DownloadNews(file_name)) Console_.LogError(StringFormat("Download Failed. Error: %i", GetLastError()), __FUNCTION__); 
   }
   else Console_.LogInformation(StringFormat("File %s found.", file_path), __FUNCTION__); 
   
   file_handle_   = FileOpen(file_path, FILE_CSV | FILE_READ | FILE_ANSI, "\n"); 
   if (file_handle_ == -1) return -1; 
   Parse(file_handle_); 
   
   ClearHandle();  
   
   return NumAllEvents(); 
}

int         CEvents::Parse(const int handle) {
   /*
      Parse Data
      
      Return stored events
   */
   
   string result[], file_string;
   int split, line = 0;
   
   while(!FileIsLineEnding(handle)) {
      file_string    = FileReadString(handle); 
      split          = (int)StringSplit(file_string, ',', result); 
      
      if (!split) break; 
      if (StringFind(result[0], "/", 0) < 0) continue; 
      
      StringReplace(result[0], "/", ".");
      string datetime_string  = StringFormat("%s %s", result[0], result[1]); 
      MqlDateTime target_date;
      TimeToStruct(StringToTime(datetime_string), target_date); 
      target_date.hour+=Offset();
      
      
      StringReplace(result[4],"\"", ""); 
      SCalendarEvent event; 
      event.title    = result[4];
      event.time     = StructToTime(target_date); 
      event.country  = result[2];
      event.impact   = ParseImpact(result[3]); 
      
      AddEvent(event, events_all_); 
      
   }
   return NumAllEvents();  
}



int         CEvents::Query(ENUM_COUNTRY_FILTERS country, ENUM_DATE_FILTERS date, ENUM_IMPACT_FILTERS impact) {
   /*
      Queries: 
         1. Country (All/This Symbol)
         2. Date (All/Today)
         3. Impact (All/High/Medium/Low/Neutral)
         
      Default
         Country: All (No filter)
         Date: Today 
         Impact: All (No Filter)
   
      
      Search events_all_, migrate to events_target_ 
   */
   
   Console_.LogInformation(StringFormat("Num Available Events: %i, Country Filter: %s, Date Filter: %s, Impact Filter: %s", 
      NumAllEvents(), 
      EnumToString(country),
      EnumToString(date),
      EnumToString(impact)), __FUNCTION__); 
   
   
   SCalendarEvent event; 
   for (int i = 0; i < NumAllEvents(); i++) {
      event = events_all_[i]; 
      //--- Country 
      if (!FilterCountry(country, event.country)) continue; 
      if (!FilterDate(date, event.time)) continue; 
      //if (!FilterImpact(impact, event.impact)) continue;
      AddEvent(event, events_target_); 
   }
   Console_.LogInformation(StringFormat("%i events added.", NumTargetEvents()), __FUNCTION__); 
   return NumTargetEvents(); 
   
}

bool        CEvents::FilterCountry(ENUM_COUNTRY_FILTERS country_filter, const string country) {
   //--- If no filters are specified, add to list 
   if (country_filter == COUNTRY_ALL) return true;
   //--- If filter is specified and country matches symbol, add to list  
   if (SymbolMatch(country)) return true; 
   //--- If filter is specified and symbol mismatch, skip
   PrintFormat("Mismatch country. Country: %s, Symbol: %s", country, Symbol()); 
   return false; 
}

bool        CEvents::FilterDate(ENUM_DATE_FILTERS date_filter, const datetime target) {
   if (date_filter == DATE_ALL) return true; 
   if (DateToday() == UTIL_GET_DATE(target)) return true; 
   
   return false; 
} 

bool        CEvents::FilterImpact(ENUM_IMPACT_FILTERS impact_filter, const string impact) {
   if (impact_filter == IMPACT_ALL) return true; 
   return impact_filter == ParseImpact(impact);   
}

ENUM_IMPACT_FILTERS  CEvents::ImpactToEnum(const string impact) {
   /*
      Values = High, Medium, Low, Neutral
   */
   if (impact == "High") return IMPACT_HIGH;
   if (impact == "Medium") return IMPACT_MEDIUM;
   if (impact == "Low") return IMPACT_LOW; 
   if (impact == "Neutral") return IMPACT_NEUTRAL; 
   return IMPACT_ALL; 
}


int         CEvents::AddEvent(SCalendarEvent &event,SCalendarEvent &dst[]) {
   int size = ArraySize(dst); 
   ArrayResize(dst, size+1); 
   dst[size] = event;
   
   return ArraySize(dst); 
}

int         CEvents::DownloadNews(const string file_name) {
   bool success = CCalendarDownload::DownloadFile(file_name, R4F_WEEKLY); 
   return success;
   
}

datetime    CEvents::FileDate() {
   //--- Used as filename of downloaded csv
   datetime latest   = LatestWeeklyCandle(); 
   int delta         = (int)(TimeCurrent() - latest);
   int weekly_delta  = PeriodSeconds(PERIOD_W1); 
   
   datetime file_date = delta > weekly_delta ? latest + weekly_delta : latest; 
   return file_date;  
}


//--- UTILITIES
int        CEvents::ClearHandle() {
   FileClose(file_handle_); 
   FileFlush(file_handle_);
   file_handle_   = 0;
   return file_handle_; 
}

template <typename T> 
int         CEvents::ClearArray(T &src[]) {
   ArrayFree(src);
   ArrayResize(src, 0);
   return ArraySize(src); 
}

bool           CEvents::SymbolMatch(const string country) {
   return StringFind(Symbol(), country) >= 0; 
}



datetime       CEvents::LatestWeeklyCandle()    const    { return iTime(Symbol(), PERIOD_W1, 0); }



int            CEvents::NumAllEvents() const    { return ArraySize(events_all_); }
int            CEvents::NumTargetEvents() const { return ArraySize(events_target_); }
datetime       CEvents::DateToday() const       { return UTIL_GET_DATE(TimeCurrent()); }