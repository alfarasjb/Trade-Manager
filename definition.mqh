
#include <MAIN/CalendarDownloader.mqh>  
#include <MAIN/console.mqh> 
#include <Controls/Defines.mqh> 
#include <Controls/Dialog.mqh>
#include <Controls/Button.mqh>
#include <Controls/Label.mqh>
#include <Controls/Checkbox.mqh>

#include "trade_ops.mqh"




#undef      CONTROLS_FONT_SIZE
#undef      CONTROLS_FONT_NAME
#define     CONTROLS_FONT_NAME      "Calibri"

#define     MAIN_PANEL_X1  10 
#define     MAIN_PANEL_Y1  20
#define     MAIN_PANEL_X2  250 
#define     MAIN_PANEL_Y2  400 
#define     MAIN_PANEL_WIDTH  250
#define     MAIN_PANEL_HEIGHT 380
#define     BUTTON_WIDTH   100 
#define     BUTTON_HEIGHT  50

#define     NEWS_PANEL_X1  10 
#define     NEWS_PANEL_Y1  20 
#define     NEWS_PANEL_WIDTH 470
#define     NEWS_PANEL_HEIGHT 380

#define  CONTROLS_FONT_SIZE      8
#define  SUBTITLE_FONT_SIZE      10
#define  FIELD_LABEL_FONT_SIZE   9  
#define     COLUMN_1       10 
#define     COLUMN_2       120 
#define     COLUMN_3       230 

#define MAIN_BT_INDENT_TOP          8 
   
#define MAIN_BT_LABEL_HEIGHT        45
#define MAIN_BT_LABEL_WIDTH         100
#define MAIN_BT_LABEL_INDENT_LEFT   11 
#define MAIN_BT_LABEL_INDENT_TOP    25
#define MAIN_BT_ORDER_FONTSIZE      12 
#define MAIN_BT_PRICE_FONTSIZE      11

#define PRICE_FIELD_INDENT_TOP      10 
//#define PRICE_FIELD_INDENT_LEFT     38  
#define PRICE_FIELD_INDENT_LEFT     33 // changed from 30
#define PRICE_FIELD_HEIGHT          20
#define PRICE_FIELD_WIDTH           130
#define ADJ_BUTTON_SIZE             20

#define CHECKBOX_X_GAP              5
#define CHECKBOX_Y_GAP              1 
#define CHECKBOX_WIDTH              40 
#define CHECKBOX_HEIGHT             18

#define WIDE_BUTTON_WIDTH     210
#define WIDE_BUTTON_HEIGHT    28
#define BUTTON_Y_SPACING      5
#define TOP_Y_OFFSET          190


#define BUY_BUTTON_COLOR            clrDodgerBlue 
#define SELL_BUTTON_COLOR           clrCrimson
#define ORDER_BUTTON_FONT_COLOR     clrWhite

#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)  


enum ENUM_VALIDATION_ERROR {
   ERR_NON_NUMERIC, 
   ERR_INVALID_ADJUST,
   ERR_NEGATIVE_VALUE
}; 

enum ENUM_COUNTRY_FILTERS {
   COUNTRY_ALL, // All
   COUNTRY_SYMBOL // Symbol
};
enum ENUM_DATE_FILTERS {
   DATE_ALL, // All
   DATE_TODAY // Today
}; 
enum ENUM_IMPACT_FILTERS {
   IMPACT_ALL, // All
   IMPACT_HIGH, // High
   IMPACT_MEDIUM, // Medium
   IMPACT_LOW, // Low
   IMPACT_NEUTRAL // Neutral 
};




input ENUM_TIME_CONVERSION    InpTimeMode          = TIME_SERVER; // Time Display Mode
input ENUM_COUNTRY_FILTERS    InpCountryFilter     = COUNTRY_SYMBOL; // Country Filter 
input ENUM_DATE_FILTERS       InpDateFilter        = DATE_TODAY; // Date Filter
input ENUM_IMPACT_FILTERS     InpImpactFilter      = IMPACT_ALL; // Impact Filter
input int                     InpMagic             = 111111; // Magic Number
input int                     InpSLPoints          = 100; // SL Points 
input int                     InpTPPoints          = 100; // TP Points 
input int                     InpBEPoints          = 50; // BE Points 
input int                     InpTSPoints          = 50; // TS Points
input int                     InpMinPoints         = 50; // Min Points 
input int                     InpStep              = 10; // Step 
input bool                    InpSLEnabled         = false; // SL Enabled 
input bool                    InpTPEnabled         = false; // TP Enabled
input bool                    InpBEEnabled         = false; // BE Enabled
input bool                    InpTSEnabled         = false; // TS Enabled

input bool                    InpTradeOnNews       = false; // TRADE ON NEWS
input Source                  InpNewsSource        = R4F_WEEKLY; // NEWS SOURCE


const string   FXFACTORY_DIRECTORY  = "events\\ff_news";
const string   R4F_DIRECTORY        = "events\\r4f_news";