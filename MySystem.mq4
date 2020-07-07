//+------------------------------------------------------------------+
extern double TakeProfit = 7;
extern double Lots = 0.1;
extern double TrailingStop = 5;
extern double StopLoss = 30;
extern int Magic = 123; // Magic Number

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

   if(pos1pre >pos2cur)
     {
      //????????? ??????? ???????

      for(cnt=1; cnt<OrdersTotal(); cnt++)

        {

         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY)


           {
            if(Bid>(OrderOpenPrice()+TrailingStop*Point))
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,5,Violet);
               return(0);
              }
           }
        }
     }


   if(pos2cur<0)
      //????????? ???????? ???????

     {

      for(cnt=1; cnt<OrdersTotal(); cnt++)
        {


         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL)
           {

            if(Ask< (OrderOpenPrice()-TrailingStop*Point))
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,5,Violet);
               return(0);
              }
           }
        }
     }


   if(OrdersTotal() < 1)
     {

      Print("pos1pre = "+pos1pre+"    pos2cur ="+pos2cur);
      if(pos1pre>pos2cur && pos2cur>0)
        {

         int ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,Bid-TakeProfit*Point,"",Magic,0,Gold);
         return(0);
        }
      // ????????? ?? ??????????? ?????? ? ??????? ??????? (BUY)

      if(pos2cur<0)
        {
         // print("K = "+K+"   S ="+S);
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,Ask+TakeProfit*Point,"",Magic,0,Gold);
         return(0);
        }
     }

  } 
//+------------------------------------------------------------------+
