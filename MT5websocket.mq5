
#import "MT5websocket.dll"   
    void onDLL (string pair); 
    void onTick (double bid, double ask); 
    void onBar (); 
#import
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

void OnInit()
  {
//---
     onDLL(Symbol());
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MqlTick  tick;
   SymbolInfoTick(Symbol(), tick );
   onTick(tick.bid, tick.ask);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   onBar();
  }
//+------------------------------------------------------------------+
