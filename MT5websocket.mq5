
#import "MT5websocket.dll"   
    void onDLL (string pair,string period); 
    void onTick (double bid, double ask);  
    void onBar (int time, double open, double high, double low, double close); 
#import
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+


class CisNewBar 
  {
   protected:
      datetime          m_lastbar_time;   // Time of opening last bar

      string            m_symbol;         // Symbol name
      ENUM_TIMEFRAMES   m_period;         // Chart period
      
      uint              m_retcode;        // Result code of detecting new bar 
      int               m_new_bars;       // Number of new bars
      string            m_comment;        // Comment of execution
      
   public:
      void              CisNewBar();      // CisNewBar constructor      
      //--- Methods of access to protected data:
      uint              GetRetCode() const      {return(m_retcode);     }  // Result code of detecting new bar 
      datetime          GetLastBarTime() const  {return(m_lastbar_time);}  // Time of opening new bar
      int               GetNewBars() const      {return(m_new_bars);    }  // Number of new bars
      string            GetComment() const      {return(m_comment);     }  // Comment of execution
      string            GetSymbol() const       {return(m_symbol);      }  // Symbol name
      ENUM_TIMEFRAMES   GetPeriod() const       {return(m_period);      }  // Chart period
      //--- Methods of initializing protected data:
      void              SetLastBarTime(datetime lastbar_time){m_lastbar_time=lastbar_time;                            }
      void              SetSymbol(string symbol)             {m_symbol=(symbol==NULL || symbol=="")?Symbol():symbol;  }
      void              SetPeriod(ENUM_TIMEFRAMES period)    {m_period=(period==PERIOD_CURRENT)?Period():period;      }
      //--- Methods of detecting new bars:
      bool              isNewBar(datetime new_Time);                       // First type of request for new bar
      int               isNewBar();                                        // Second type of request for new bar 
  };
   
//+------------------------------------------------------------------+
//| CisNewBar constructor.                                           |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CisNewBar::CisNewBar()
  {
   m_retcode=0;         // Result code of detecting new bar 
   m_lastbar_time=0;    // Time of opening last bar
   m_new_bars=0;        // Number of new bars
   m_comment="";        // Comment of execution
   m_symbol=Symbol();   // Symbol name, by default - symbol of current chart
   m_period=Period();   // Chart period, by default - period of current chart    
  }

//+------------------------------------------------------------------+
//| First type of request for new bar                     |
//| INPUT:  newbar_time - time of opening (hypothetically) new bar|
//| OUTPUT: true   - if new bar(s) has(ve) appeared                  |
//|         false  - if there is no new bar or in case of error      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CisNewBar::isNewBar(datetime newbar_time)
  {
   //--- Initialization of protected variables
   m_new_bars = 0;      // Number of new bars
   m_retcode  = 0;      // Result code of detecting new bar: 0 - no error
   m_comment  =__FUNCTION__+" Successful check for new bar";
   //---
   
   //--- Just to be sure, check: is the time of (hypothetically) new bar m_newbar_time less than time of last bar m_lastbar_time? 
   if(m_lastbar_time>newbar_time)
     { // If new bar is older than last bar, print error message
      m_comment=__FUNCTION__+" Synchronization error: time of previous bar "+TimeToString(m_lastbar_time)+
                                                  ", time of new bar request "+TimeToString(newbar_time);
      m_retcode=-1;     // Result code of detecting new bar: return -1 - synchronization error
      return(false);
     }
   //---
        
   //--- if it's the first call 
   if(m_lastbar_time==0)
     {  
      m_lastbar_time=newbar_time; //--- set time of last bar and exit
      m_comment   =__FUNCTION__+" Initialization of lastbar_time = "+TimeToString(m_lastbar_time);
      return(false);
     }   
   //---

   //--- Check for new bar: 
   if(m_lastbar_time<newbar_time)       
     { 
      m_new_bars=1;               // Number of new bars
      m_lastbar_time=newbar_time; // remember time of last bar
      return(true);
     }
   //---
   
   //--- if we've reached this line, then the bar is not new; return false
   return(false);
  }

//+------------------------------------------------------------------+
//| Second type of request for new bar                     |
//| INPUT:  no.                                                      |
//| OUTPUT: m_new_bars - Number of new bars                          |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CisNewBar::isNewBar()
  {
   datetime newbar_time;
   datetime lastbar_time=m_lastbar_time;
      
   //--- Request time of opening last bar:
   ResetLastError(); // Set value of predefined variable _LastError as 0.
   if(!SeriesInfoInteger(m_symbol,m_period,SERIES_LASTBAR_DATE,newbar_time))
     { // If request has failed, print error message:
      m_retcode=GetLastError();  // Result code of detecting new bar: write value of variable _LastError
      m_comment=__FUNCTION__+" Error when getting time of last bar opening: "+IntegerToString(m_retcode);
      return(0);
     }
   //---
   
   //---Next use first type of request for new bar, to complete analysis:
   if(!isNewBar(newbar_time)) return(0);
   
   //---Correct number of new bars:
   m_new_bars=Bars(m_symbol,m_period,lastbar_time,newbar_time)-1;

   //--- If we've reached this line - then there is(are) new bar(s), return their number:
   return(m_new_bars);
  }
  






//=============================
CisNewBar current_chart; // instance of the CisNewBar class: current chart

double bid0;
double ask0;

void OnInit()
  {
//---
      string period;
      if(Period() == PERIOD_MN1)
         period = "mTick";
      if(Period() == PERIOD_W1)
         period = "mW"; 
      if(Period() == PERIOD_D1)
         period = "mD";
      if(Period() == PERIOD_H2)
         period = "m120"; 
      if(Period() == PERIOD_M30)
         period = "m30";
      if(Period() == PERIOD_M5)
         period = "m5"; 
      if(Period() == PERIOD_M1)
         period = "m1";    
         
     onDLL(Symbol(), period);
     
     Print(Symbol());   
     Print(Period());

     Sleep(3000);  
     OnDLL1();
  
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
    if(Period() == PERIOD_MN1)
    {
      MqlTick  tick;
      SymbolInfoTick(Symbol(), tick );
      
      if((tick.bid != bid0)||(tick.ask != ask0))
      {
         onTick(tick.bid, tick.ask); 
         bid0 = tick.bid;
         ask0 = tick.ask;
      }
      
    } 
     
   int period_seconds=PeriodSeconds(_Period);                     // Number of seconds in current chart period
   datetime new_time=TimeCurrent()/period_seconds*period_seconds; // Time of bar opening on current chart
   if(current_chart.isNewBar(new_time)) OnNewBar();               // When new bar appears - launch the NewBar event handler
                            
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
  }
//+------------------------------------------------------------------+

datetime Time[]; 
int Time1[];
double Open[],High[],Low[],Close[];
double Open1[],High1[],Low1[],Close1[];

double iOpen(string symbol,ENUM_TIMEFRAMES timeframe,int index)
  {
   double open=0;
   ArraySetAsSeries(Open,true);
   int copied=CopyOpen(symbol,timeframe,0,5,Open);
   if(copied>0 && index<copied) open=Open[index];
   return(open);
  }

double iHigh(string symbol,ENUM_TIMEFRAMES timeframe,int index)
  {
   double high=0;
   ArraySetAsSeries(High,true);
   int copied=CopyHigh(symbol,timeframe,0,5,High);
   if(copied>0 && index<copied) high=High[index];
   return(high);
  }
  
    
double iLow(string symbol,ENUM_TIMEFRAMES timeframe,int index)
  {
   double low=0;
   ArraySetAsSeries(Low,true);
   int copied=CopyLow(symbol,timeframe,0,5,Low);
   if(copied>0 && index<copied) low=Low[index];
   return(low);
  } 
  
double iClose(string symbol,ENUM_TIMEFRAMES timeframe,int index)
  {
   double close=0;
   ArraySetAsSeries(Close,true);
   int copied=CopyClose(symbol,timeframe,0,5,Close);
   if(copied>0 && index<copied) close=Close[index];
   return(close);
  }

void OnNewBar()
{
  PrintFormat("New bar: %s",TimeToString(TimeCurrent(),TIME_SECONDS));
 
 Print( iOpen(Symbol(),Period(),1));
 Print( iHigh(Symbol(),Period(),1));
 Print( iLow(Symbol(),Period(),1));
 Print( iClose(Symbol(),Period(),1));
   
 
  
 onBar (TimeCurrent()*1,
  iOpen(Symbol(),Period(),1), 
  iHigh(Symbol(),Period(),1), 
  iLow(Symbol(),Period(),1),  
  iClose(Symbol(),Period(),1)); 

}

void OnDLL1()
{
  int bars = Bars(Symbol(),Period());
 
  ArraySetAsSeries(Time,true);
  int timeCount = CopyTime(Symbol(),Period(),0,bars,Time);
  
  ArraySetAsSeries(Open1,true);
  int openCount = CopyOpen(Symbol(),Period(),0,timeCount,Open1);

  ArraySetAsSeries(High1,true);
  int highCount = CopyHigh(Symbol(),Period(),0,timeCount,High1);
  
  ArraySetAsSeries(Low1,true);
  int lowCount = CopyLow(Symbol(),Period(),0,timeCount,Low1);
  
  ArraySetAsSeries(Close1,true);
  int closeCount = CopyClose(Symbol(),Period(),0,timeCount,Close1);
    
  Print( Time[1]);
 
  Print("closeCount: "+closeCount+" "+Close1[1]);  
  Print("lowCount: "+lowCount+" "+Low1[1]);
  Print("highCount: "+highCount+" "+High1[1]);
  Print("openCount: "+openCount+" "+Open1[1]); 
  
  ArrayResize(Time1, timeCount);
  
  int limit = 1000;
  
  if(timeCount < limit)
    limit = timeCount;
  
  for(int i=0;i< limit; i++)
  {  Print( Time[i]);

     Time1[i] = Time[i] *1;     
     onBar (Time1[i], Open1[i], High1[i], Low1[i], Close1[i]);
  } 

  Print("history done"); 
  
  
  //onDLL1(timeCount,/*Time1,*/ Open1,High1,Low1,Close1);
}