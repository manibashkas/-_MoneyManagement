//+------------------------------------------------------------------+
//|                                            C_MoneyManagement.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_MoneyManagement
  {
private:
   double account_depo;
   int safe_percent;
   string file_name;
   int max_risk_;
   int stopLoss_;
   double GetVolume(double volume_to_check);
   double OptimalLot(int &max_risk,int &stopLoss);
public:
                     C_MoneyManagement(string, int);
                     void README(){printf("depo: %g, percent: %i", account_depo, safe_percent);};
                     double AccountDepo();
                    ~C_MoneyManagement();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_MoneyManagement::C_MoneyManagement(string set_file_name, int set_safe_percent):file_name(set_file_name), safe_percent(set_safe_percent), account_depo(AccountDepo())
  {
   int file_handle;
      
       if(!FileIsExist(file_name))
         {
         if(safe_percent > 100)
         {
            safe_percent = 100;
            Print("max safe_percent is 100");
         }
         if(safe_percent < 1)
         {
            safe_percent = 1;
            Print("min safe percent is 1");
         }
         
            file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV);
            if(file_handle!=INVALID_HANDLE)
            {
               FileWrite(file_handle, account_depo, safe_percent);
               FileClose(file_handle); 
            }
         }
       else 
         {
            file_handle = FileOpen(file_name, FILE_READ |FILE_CSV );    
            if(file_handle!=INVALID_HANDLE)
               if(FileSeek(file_handle, 0, SEEK_SET))
               {
                  account_depo = FileReadNumber(file_handle);
                  safe_percent = (int)FileReadNumber(file_handle);
                  FileClose(file_handle);
               }
         }      
  }
double C_MoneyManagement::OptimalLot(int &max_risk,int &stopLoss)
  {
   double free_founds=AccountBalance();
   double one_pip_cost= MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)/Point;
   double optimal_lot = free_founds*max_risk/100/stopLoss * one_pip_cost;

   return optimal_lot;
  }
  
double C_MoneyManagement::GetVolume(double volume_to_check)
  {
   volume_to_check=OptimalLot(max_risk_,stopLoss_);
   double correct_volume=MarketInfo(Symbol(),MODE_MINLOT);
   double volume_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   do
      correct_volume+=volume_step;
   while(correct_volume<volume_to_check);

   correct_volume-=volume_step;
   return correct_volume;
  }
  
double C_MoneyManagement::AccountDepo(void)
  {
   int orders_total = OrdersTotal();
   double orders_open_PL = 0;

   for(int i = 0; i < orders_total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderProfit() > 0)
            orders_open_PL += OrderProfit();
      else
        {
         if(OrderType() == OP_BUY)
            orders_open_PL += NormalizeDouble(OrderOpenPrice()-Bid,Digits);
         if(OrderType() == OP_SELL)
            orders_open_PL += NormalizeDouble(Ask-OrderOpenPrice(),Digits);
         orders_open_PL ++;
        }
     }
   account_depo = AccountBalance() + orders_open_PL;

   return account_depo;
   }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_MoneyManagement::~C_MoneyManagement()
  {
  }
//+------------------------------------------------------------------+
