//+------------------------------------------------------------------+
//|                                                 RSI-stop-5000.mq5 |
//|                                                         traderka |
//|                                             https://www.mql5.com |
// TO DO:
// - Dodanie Bollinger Bands
//+------------------------------------------------------------------+
#property copyright "traderka"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <Trade/Trade.mqh>
CTrade trade;

input int MagicNumber = 65262;
input int Slippage = 10;

double tpoint, ask, bid, tradenow, buyStopLoss, sellStopLoss, buyTakeProfit, sellTakeProfit, High[], Low[], Close[], Open[];

int OnInit()
  {
//---


   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(Slippage);
   trade.SetAsyncMode(false);
   
   

//---
   return(INIT_SUCCEEDED);
  }
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
   double LotSize = 1;

   int RSIdef = iRSI(Symbol(),PERIOD_CURRENT,14,PRICE_CLOSE);
   int CCIdef = iCCI(Symbol(),PERIOD_CURRENT,14,PRICE_CLOSE);
   int STOCHdef = iStochastic(Symbol(),PERIOD_CURRENT,5,3,3,MODE_SMA,STO_CLOSECLOSE);
   int LowBBanddef = iBands(Symbol(), PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
   int UpBBanddef = iBands(Symbol(), PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
      
   double RSIarray[];
   double CCIarray[];
   double STOCHarray[];
   double upbbands[];
   double dnbbands[];
   double fiveRecentCandleClose, fourRecentCandleClose, threeRecentCandleClose, twoRecentCandleClose, oneRecentCandleClose, currentCandleClose;
   double fiveRecentCandleOpen, fourRecentCandleOpen, threeRecentCandleOpen, twoRecentCandleOpen, oneRecentCandleOpen, currentCandleOpen;
   long oneRecentCandleVolume;
   
   bool fiveRecentCandleBearish, fourRecentCandleBearish, threeRecentCandleBearish, twoRecentCandleBearish, oneRecentCandleBearish, currentCandleBearish;
   
   ArraySetAsSeries(RSIarray, true);
   ArraySetAsSeries(CCIarray, true);
   ArraySetAsSeries(STOCHarray, true);
   ArraySetAsSeries(upbbands,true);
   ArraySetAsSeries(dnbbands,true);
   
   CopyBuffer(RSIdef,0,0,3,RSIarray);
   CopyBuffer(CCIdef,0,0,3,CCIarray);
   CopyBuffer(STOCHdef,0,0,3,STOCHarray);
   CopyBuffer(UpBBanddef,1,0,2,upbbands);
   CopyBuffer(LowBBanddef,2,0,2,dnbbands);

   double RSIvalue = NormalizeDouble(RSIarray[0],2);
   double CCIvalue = NormalizeDouble(CCIarray[0],2);
   double STOCHvalue = NormalizeDouble(STOCHarray[0],2);
   double UPBBANDvalue = upbbands[0];
   double DNBBANDvalue = dnbbands[0];
   
   oneRecentCandleVolume = iVolume(Symbol(),0,1);
   
   currentCandleClose = iClose(Symbol(),0,0);
   oneRecentCandleClose = iClose(Symbol(),0,1);
   twoRecentCandleClose = iClose(Symbol(),0,2);
   threeRecentCandleClose = iClose(Symbol(),0,3); 
   fourRecentCandleClose = iClose(Symbol(),0,4); 
   fiveRecentCandleClose = iClose(Symbol(),0,5); 
   
   currentCandleOpen = iOpen(Symbol(),0,0);
   oneRecentCandleOpen = iOpen(Symbol(),0,1);
   twoRecentCandleOpen = iOpen(Symbol(),0,2);
   threeRecentCandleOpen = iOpen(Symbol(),0,3); 
   fourRecentCandleOpen = iOpen(Symbol(),0,4); 
   fiveRecentCandleOpen = iOpen(Symbol(),0,5); 
   
   currentCandleBearish = currentCandleClose<currentCandleOpen;
   oneRecentCandleBearish = oneRecentCandleClose<oneRecentCandleOpen;
   twoRecentCandleBearish = twoRecentCandleClose<twoRecentCandleOpen;
   threeRecentCandleBearish = threeRecentCandleClose<threeRecentCandleOpen;
   fourRecentCandleBearish = fourRecentCandleClose<fourRecentCandleOpen;
   fiveRecentCandleBearish = fiveRecentCandleClose<fiveRecentCandleOpen;
   
   MqlDateTime dateTimeNowUtc;
   TimeGMT(dateTimeNowUtc);
   
   if(IsNewCandle()){
      tradenow=1;
   }
  
   ask=SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   bid=SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   if(PositionsTotal()<1 && oneRecentCandleVolume>250 && dateTimeNowUtc.hour>=9 && dateTimeNowUtc.hour<=17) {
   
      if(tradenow==1 &&
      
         RSIvalue<=40 && 
         CCIvalue<=-100 && 
         STOCHvalue<=20 && 
         
         (oneRecentCandleBearish==true) &&
         (twoRecentCandleBearish==true) &&
         
         (threeRecentCandleClose<DNBBANDvalue) ||
         (twoRecentCandleClose<DNBBANDvalue) ||
         (oneRecentCandleClose<DNBBANDvalue) &&
         
         (DNBBANDvalue-currentCandleOpen>10)
         
         ){
         
         trade.Buy(LotSize, NULL,ask,ask-20,NULL);
         tradenow=0;  
      }
      
      if(tradenow==1 &&
      
         RSIvalue>=60 && 
         CCIvalue>=100 && 
         STOCHvalue>=80 && 
         
         (oneRecentCandleBearish==false) &&
         (twoRecentCandleBearish==false) &&

         (oneRecentCandleClose>UPBBANDvalue) ||
         (twoRecentCandleClose>UPBBANDvalue) ||
         (threeRecentCandleClose>UPBBANDvalue) &&
         
         (UPBBANDvalue-currentCandleOpen>10)
         
         
         ){
         
         trade.Sell(LotSize, NULL,bid,bid+20,0,NULL);
         tradenow=0;
      }
   }
   
   if(PositionsTotal()<=1) {
      
      string symbol=PositionGetSymbol(0);
      double CurrentPrice=PositionGetDouble(POSITION_PRICE_CURRENT);
      CheckTrailingStop(CurrentPrice,twoRecentCandleBearish);
      
   }

  }
//+------------------------------------------------------------------+


//+----------------------+ //insuring its a new candle function //+-------------------------------------+ 
bool IsNewCandle() { 
static int BarsOnChart=0; 
if (Bars(_Symbol,PERIOD_CURRENT) == BarsOnChart) return (false); 
BarsOnChart = Bars(_Symbol,PERIOD_CURRENT); return(true); 
}
     
void CheckTrailingStop(double CurrentPrice, bool twoRecentCandleBearish) {
   double TrailingStopAsk = NormalizeDouble(CurrentPrice-2000*_Point, _Digits);
   double TrailingStopBid = NormalizeDouble(CurrentPrice+2000*_Point, _Digits);
   
   double TrailingStopSmallAsk = NormalizeDouble(CurrentPrice-100*_Point, _Digits);
   double TrailingStopSmallBid = NormalizeDouble(CurrentPrice+100*_Point, _Digits);
   
     for(int i=PositionsTotal(); i>=0; i--) {
        string symbol=PositionGetSymbol(i);
        
        if (_Symbol==symbol) {
            ulong PositionTicket=PositionGetInteger(POSITION_TICKET);
            
            double CurrentStopLoss=PositionGetDouble(POSITION_SL);
            
            long TransactionType=PositionGetInteger(POSITION_TYPE);
            
            if(trade.RequestType()==0) {
               if(CurrentStopLoss<TrailingStopAsk) {
                  trade.PositionModify(PositionTicket,TrailingStopAsk,0);
                  
                  if(twoRecentCandleBearish==true) {
                     trade.PositionModify(PositionTicket,TrailingStopSmallAsk,0);
                  }
               }
            }    
        
            if(TransactionType==1.0) {
               if(CurrentStopLoss>TrailingStopBid) {
                  trade.PositionModify(PositionTicket,TrailingStopBid,0);
                  
                  if(twoRecentCandleBearish==false) {
                     trade.PositionModify(PositionTicket,TrailingStopSmallBid,0);
                  }
               }
            }
         }
     }
}
