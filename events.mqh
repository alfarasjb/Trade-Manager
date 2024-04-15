
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
         
      //--- UTILITIES
         datetime    EventDatetime(string datetime_string);
      
      /*
         events_all_: stores all events in downloaded csv file 
         events_target_: stores queried events
      */
      SCalendarEvent    events_all_[], events_target_[]; 
      
         string      Directory()    const { return R4F_DIRECTORY; }
         int         DownloadNews(const string file_name); 
         int         Parse(const int handle); 

      //--- ARRAY OPERATIONS 
         int         AddEvent(SCalendarEvent &event, SCalendarEvent &dst[]); 
         
         
public:
      
         CEvents();
         ~CEvents(); 
         
         void        Initialize(); 
         int         FetchData(); 
         int         Query(ENUM_COUNTRY_FILTERS country=COUNTRY_ALL, ENUM_DATE_FILTERS date=DATE_TODAY, ENUM_IMPACT_FILTERS impact=IMPACT_ALL); 

      //--- WRAPPERS
         SCalendarEvent EventAll(const int index)     const { return events_all_[index]; }
         SCalendarEvent EventTarget(const int index)  const { return events_target_[index]; }
                    
         int         NumAllEvents() const    { return ArraySize(events_all_); }
         int         NumTargetEvents() const { return ArraySize(events_target_); }
       
      
}; 

CEvents::CEvents() 
   : CCalendarDownload(Directory(), 50000) {
   
   Console_    = new CConsole(true, false, false); 
}

CEvents::~CEvents() {
   delete Console_; 
}


void        CEvents::Initialize() {
   TimeMode(InpTimeMode); 
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
   
   //--- Open File and Parse
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
   
   string result[], file_string, datetime_string;
   int split, line = 0;
   
   while(!FileIsLineEnding(handle)) {
      file_string    = FileReadString(handle); 
      split          = (int)StringSplit(file_string, ',', result); 
      
      if (!split) break; 
      if (StringFind(result[0], "/", 0) < 0) continue; 
      
      //--- Reformats date string
      StringReplace(result[0], "/", ".");
      datetime_string  = StringFormat("%s %s", result[0], result[1]); 
      
      StringReplace(result[4],"\"", ""); 
      SCalendarEvent event; 
      event.title    = result[4];
      event.time     = EventDatetime(datetime_string); 
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
   
   //--- Clears contents to prevent overlap
   ClearArray(events_target_); 
   
   Console_.LogInformation(StringFormat("Num Available Events: %i, Target Size: %i, Country Filter: %s, Date Filter: %s, Impact Filter: %s", 
      NumAllEvents(), 
      NumTargetEvents(), 
      EnumToString(country),
      EnumToString(date),
      EnumToString(impact)), __FUNCTION__); 
   
   
   SCalendarEvent event; 
   for (int i = 0; i < NumAllEvents(); i++) {
      event = events_all_[i]; 
      //--- Country 
      if (!FilterCountry(country, event.country)) continue; 
      //--- Date
      if (!FilterDate(date, event.time)) continue; 
      //--- Impact
      if (!FilterImpact(impact, event.impact)) continue;
      AddEvent(event, events_target_); 
   }
   Console_.LogInformation(StringFormat("%i events added.", NumTargetEvents()), __FUNCTION__); 
   return NumTargetEvents(); 
   
}

//+------------------------------------------------------------------+
//| FILTERS                                                          |
//+------------------------------------------------------------------+

/*
   Returns true if no filters are specified, and event may be added to target events 
   
   Added events are displayed on news panel 
*/

bool        CEvents::FilterCountry(ENUM_COUNTRY_FILTERS country_filter, const string country) {
   //--- If no filters are specified, add to list 
   if (country_filter == COUNTRY_ALL) return true;
   //--- If filter is specified and country matches symbol, add to list  
   if (SymbolMatch(country)) return true; 
   //--- If filter is specified and symbol mismatch, skip
   return false; 
}

bool        CEvents::FilterDate(ENUM_DATE_FILTERS date_filter, const datetime target) {
   
   if (date_filter == DATE_ALL) return true; 
   if (UTIL_DATE_TODAY() == UTIL_GET_DATE(target)) return true; 
   
   return false; 
} 

bool        CEvents::FilterImpact(ENUM_IMPACT_FILTERS impact_filter, const string impact) {
   if (impact_filter == IMPACT_ALL) return true; 
   return impact_filter == ImpactToEnum(impact);   
}

ENUM_IMPACT_FILTERS  CEvents::ImpactToEnum(const string impact) {
   /*
      Values = High, Medium, Low, Neutral
      
      Temporary
   */
   if (impact == "High") return IMPACT_HIGH;
   if (impact == "Medium") return IMPACT_MEDIUM;
   if (impact == "Low") return IMPACT_LOW; 
   if (impact == "Neutral") return IMPACT_NEUTRAL; 
   return IMPACT_ALL; 
}


//+------------------------------------------------------------------+
//| UTILITIES                                                        |
//+------------------------------------------------------------------+

int         CEvents::AddEvent(SCalendarEvent &event,SCalendarEvent &dst[]) {
   /*
      Adds calendar event to designated array. 
   */
   int size = ArraySize(dst); 
   ArrayResize(dst, size+1); 
   dst[size] = event;
   
   return ArraySize(dst); 
}

int         CEvents::DownloadNews(const string file_name) {
   return CCalendarDownload::DownloadFile(file_name, R4F_WEEKLY);    
}

datetime    CEvents::FileDate() {
   /*
      Used as filename of downloaded csv
   */
   datetime latest   = LatestWeeklyCandle(); 
   int delta         = (int)(TimeCurrent() - latest);
   int weekly_delta  = PeriodSeconds(PERIOD_W1); 
   
   datetime file_date = delta > weekly_delta ? latest + weekly_delta : latest; 
   return file_date;  
}


int        CEvents::ClearHandle() {
   /*
      Clears file handle
   */
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
   /*
      Checks if event country matches attached symbol.
      
      Used for filtering
   */
   return StringFind(Symbol(), country) >= 0; 
}



datetime    CEvents::EventDatetime(string datetime_string) {
   /*
      Converts datetime string from news source into datetime + offset 
   */
   MqlDateTime target_date;
   TimeToStruct(StringToTime(datetime_string), target_date); 
   target_date.hour += Offset(); // Hour + GMT Offset if selected 
   return StructToTime(target_date); 
}


datetime       CEvents::LatestWeeklyCandle()    const    { return iTime(Symbol(), PERIOD_W1, 0); }
