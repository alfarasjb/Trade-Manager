

#include "forex_factory.mqh"


class CNewsPanel : public CAppDialog {
private: 
            double      dpi_scale_; 
            string      name_; 
public:
   CNewsPanel(); 
   ~CNewsPanel(); 
            
            string      NAME() const { return name_; }
            int         Scale(double value)     { return (int)MathRound(value * dpi_scale_); }
   
   virtual  bool        Create(); 

}; 


CNewsPanel::CNewsPanel() {
   name_ = "news";
   double screen_dpi = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   dpi_scale_  = screen_dpi / 96; 
   
   

}

CNewsPanel::~CNewsPanel() { }



bool        CNewsPanel::Create() {
   int x1      = Scale(MAIN_PANEL_WIDTH + 20);
   int y1      = Scale(NEWS_PANEL_Y1);
   int x2      = Scale(x1 + NEWS_PANEL_WIDTH);
   int y2      = Scale(y1 + NEWS_PANEL_HEIGHT); 
   if (!CAppDialog::Create(0, name_, 0, x1, y1, x2, y2)) return false; 
   return true;
}