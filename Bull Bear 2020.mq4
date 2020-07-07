//+------------------------------------------------------------------+
//|                                                     bullbear.mq4 |
//|                                    Copyright © 2006, Yousky Soft |
//|                                            http://yousky.free.fr |
//+------------------------------------------------------------------+

#define LOG_LEVEL_ERR 1
#define LOG_LEVEL_WARN 2
#define LOG_LEVEL_INFO 3
#define LOG_LEVEL_DBG 4

enum MM {Manually_Lot, Automatically_Lot};

extern MM     TypeOfLotSize     = Manually_Lot;     // Type Of Lot Size
extern double RiskFactor        = 1.0;              // Risk Factro For Auto Lot
extern double ManualLotSize     = 0.01;             // Manual Lot Size
extern double StopLoss = 30.00;                     // StopLoss
extern double TakeProfit = 40.00;                   // TakeProfit
extern bool   BreakEvenRun      = false;            // Use Break Even
extern double BreakEvenAfter    = 10.0;             // Profit To Activate Break Even (Plus Stop Loss)
extern double TrailingProfit = false;               // TrailingStop for Profit
extern bool      UseProfitToClose       = true;     // ¿Use Profit for close?
extern double    ProfitToClose          = 100;      // Profit for close order
extern bool   SaverRun      = false;                // Use Saver
extern double OrderDistance     = 10.0;             // Distance For Pending Orders
extern double Risk_Multiplier=1;                    // Risk Multiplier
extern int Magic = 123456;                          // Magic Number (UNIQUE)

int pro=0;
datetime t=0;
string ExpertName;
int MultiplierPoint;
int i;
double DigitPoint;
double LotSize;
string BackgroundName;
color ChartColor;
//=========================================================================================================================================================================//
int OnInit()
  {
//------------------------------------------------------

//------------------------------------------------------
//Broker 4 or 5 digits
   DigitPoint=MarketInfo(Symbol(),MODE_POINT);
   MultiplierPoint=1;
   if(MarketInfo(Symbol(),MODE_DIGITS)==3||MarketInfo(Symbol(),MODE_DIGITS)==5)
     {
      MultiplierPoint=10;
      DigitPoint*=MultiplierPoint;
     }
//------------------------------------------------------
//Minimum take profit and stop loss and distance for pendings
   double StopLevel=MathMax(MarketInfo(Symbol(),MODE_FREEZELEVEL)/MultiplierPoint,MarketInfo(Symbol(),MODE_STOPLEVEL)/MultiplierPoint);
   if((TakeProfit>0)&&(TakeProfit<StopLevel))
      TakeProfit=StopLevel;
   if((StopLoss>0)&&(StopLoss<StopLevel))
      StopLoss=StopLevel;
   if(OrderDistance<StopLevel)
      OrderDistance=StopLevel;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
}

bool CheckMoneyForTrade(string symbol, double lot, int type)
  {
   double free_margin = AccountFreeMargin();
//-- if there is not enough money
   if(free_margin < 0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print(LOG_LEVEL_INFO, StringConcatenate("Not enough money", GetLastError()), true);
      return(false);
     }
//--- checking successful
   return(true);
  }
//------------------------------------------------------
   return(INIT_SUCCEEDED);
//------------------------------------------------------
  }
//=========================================================================================================================================================================//
void OnDeinit(const int reason)
  {
//------------------------------------------------------
   ObjectDelete(BackgroundName);
   Comment("");
//------------------------------------------------------
  }
//=========================================================================================================================================================================//
void OnTick()
  {
//------------------------------------------------------
   datetime Expire=0;
   double FreeMargin=0;
   bool WasOrderClosed=false;
   bool WasOrderDeleted=false;
   bool WasOrderModify=false;
   double DistAsk=0;
   double DistBid=0;
   double TP=0;
   double SL=0;
   bool CloseOrders=false;

//Set levels
   double OrderTP=NormalizeDouble(TakeProfit*DigitPoint,Digits);
   double OrderSL=NormalizeDouble(StopLoss*DigitPoint,Digits);
   double OrderDist=NormalizeDouble(OrderDistance*DigitPoint,Digits);
   double PipsAfter=NormalizeDouble(BreakEvenAfter*DigitPoint,Digits);
   double TrailingStep=NormalizeDouble(OrderDistance*DigitPoint,Digits);
   
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double LotSize()
//Set lot size
  { if(TypeOfLotSize==0)
      LotSize=ManualLotSize;
   if(TypeOfLotSize==1)
      LotSize=(AccountBalance()/MarketInfo(Symbol(),MODE_LOTSIZE))*RiskFactor;
      

    int total  = OrdersTotal();
    double lots = 0;
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {                                   
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(AllSymbols)
         {
            if(PendingOrders)
                  lots+=OrderLots();
            if(!PendingOrders)
               if(OrderType()==OP_BUY || OrderType()==OP_SELL)
                  lots+=OrderLots();
         }
        {  if(!AllSymbols)
         {
            if(OrderSymbol()==Symbol())
            {
               if(PendingOrders)
                     lots+=OrderLots();
               if(!PendingOrders)
                  if(OrderType()==OP_BUY || OrderType()==OP_SELL)
                     lots+=OrderLots();
            }
         }
      }
    return (LotSize);
}

double NormalizeLot(double LotsSize)
  {
//---------------------------------------------------------------------
   if(IsConnected())
     {
      return(MathMin(MathMax((MathRound(LotsSize/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP)),MarketInfo(Symbol(),MODE_MINLOT)),MarketInfo(Symbol(),MODE_MAXLOT)));
     }
   else
     {
      return(LotsSize);
     }
//---------------------------------------------------------------------
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double pos1pre=0;
   double  pos2cur=0;
   int cnt=0;
   int mode=0;
   double openpozprice=0;

   pos1pre = iBullsPower(NULL,0,13,PRICE_WEIGHTED,1);
   pos2cur = iBullsPower(NULL,0,13,PRICE_WEIGHTED,0);
//Comment("??????? ???????  ",pos2cur,"Previous pos", pos1pre );


   if(OrdersTotal() < 1)
     {

      Print("pos1pre = "+pos1pre+"    pos2cur ="+pos2cur);
      if(pos1pre>pos2cur && pos2cur>0)
        {

         int ticket=OrderSend(Symbol(),OP_SELL,NormalizeLot(LotSize),Bid,3,0,Bid-TakeProfit*Point,"",Magic,0,Gold);
         return(0);
        }
      // ????????? ?? ??????????? ?????? ? ??????? ??????? (BUY)

      if(pos2cur<0)
        {
         // print("K = "+K+"   S ="+S);
         ticket=OrderSend(Symbol(),OP_BUY,NormalizeLot(LotSize),Ask,3,0,Ask+TakeProfit*Point,"",Magic,0,Gold);
         return(0);
        }
     }
  }
