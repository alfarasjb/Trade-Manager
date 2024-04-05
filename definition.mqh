
#include <RECURVE/CalendarDownloader.mqh> 

#include <Controls/Defines.mqh> 
#include <Controls/Dialog.mqh>
#include <Controls/Button.mqh>
#include <Controls/Label.mqh>
#include <Controls/Checkbox.mqh>

#include "logging.mqh"
#include "trade_ops.mqh"




#undef      CONTROLS_FONT_SIZE
#define     MAIN_PANEL_X1  10 
#define     MAIN_PANEL_Y1  20
#define     MAIN_PANEL_X2  250 
#define     MAIN_PANEL_Y2  400 
#define     MAIN_PANEL_WIDTH  240
#define     MAIN_PANEL_HEIGHT 380
#define     BUTTON_WIDTH   100 
#define     BUTTON_HEIGHT  50

#define     NEWS_PANEL_X1  10 
#define     NEWS_PANEL_Y1  20 
#define     NEWS_PANEL_WIDTH 300
#define     NEWS_PANEL_HEIGHT 380

#define  CONTROLS_FONT_SIZE      8
#define  SUBTITLE_FONT_SIZE      9
#define  FIELD_LABEL_FONT_SIZE   8  
#define     COLUMN_1       10 
#define     COLUMN_2       120 
#define     COLUMN_3       230 

#define MAIN_BT_INDENT_TOP          8 
   
#define MAIN_BT_LABEL_HEIGHT        45
#define MAIN_BT_LABEL_WIDTH         100
#define MAIN_BT_LABEL_INDENT_LEFT   11 
#define MAIN_BT_LABEL_INDENT_TOP    28
#define MAIN_BT_ORDER_FONTSIZE      12 
#define MAIN_BT_PRICE_FONTSIZE      10

#define PRICE_FIELD_INDENT_TOP      10 
//#define PRICE_FIELD_INDENT_LEFT     38  
#define PRICE_FIELD_INDENT_LEFT     30
#define PRICE_FIELD_HEIGHT          20
#define PRICE_FIELD_WIDTH           130
#define ADJ_BUTTON_SIZE             20

#define CHECKBOX_X_GAP              5
#define CHECKBOX_Y_GAP              2 
#define CHECKBOX_WIDTH              40 
#define CHECKBOX_HEIGHT             18

#define WIDE_BUTTON_WIDTH     210
#define WIDE_BUTTON_HEIGHT    28


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
   ERR_INVALID_ADJUST
}; 

input bool                    InpTradeOnNews       = false; // TRADE ON NEWS
input Source                  InpNewsSource        = R4F_WEEKLY; // NEWS SOURCE


const string   FXFACTORY_DIRECTORY  = "recurve\\ff_news";
const string   R4F_DIRECTORY        = "recurve\\r4f_news";