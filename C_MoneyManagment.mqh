//+------------------------------------------------------------------+
//|                                             C_MoneyManagment.mqh |
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
class C_MoneyManagment
  {
private:
   double            account_depo;
   int               safe_percent;
   string            file_name;
   int               max_risk_;
   int               stopLoss_;
   double            GetVolume(double volume_to_check);
   double            OptimalLot(int &max_risk,int &stopLoss);

public:
                     C_MoneyManagment(string,int);
                      void README(){printf("depo: %g, percent: %i",account_depo,safe_percent);};
                    ~C_MoneyManagment();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_MoneyManagment::C_MoneyManagment(string set_file_name,int set_safe_percent):
                                   file_name(set_file_name),safe_percent(set_safe_percent),account_depo(AccountBalance())
  {
   int file_handle;

   if(!FileIsExist(file_name))
     {
      if(safe_percent>100)
        {
         safe_percent=100;
         Print("max safe_percent is 100");
        }
      if(safe_percent<1)
        {
         safe_percent=1;
         Print("min safe percent is 1");
        }

      file_handle=FileOpen(file_name,FILE_WRITE|FILE_CSV);
      if(file_handle!=INVALID_HANDLE)
        {
         FileWrite(file_handle,account_depo,safe_percent);
         FileClose(file_handle);
        }
     }
   else
     {
      file_handle=FileOpen(file_name,FILE_READ|FILE_CSV);
      if(file_handle!=INVALID_HANDLE)
         if(FileSeek(file_handle,0,SEEK_SET))
           {
            account_depo = FileReadNumber(file_handle);
            safe_percent = (int)FileReadNumber(file_handle);
            FileClose(file_handle);
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double C_MoneyManagment::OptimalLot(int &max_risk,int &stopLoss)
  {
   double free_founds=AccountBalance();
   double one_pip_cost= MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)/Point;
   double optimal_lot = free_founds*max_risk/100/stopLoss * one_pip_cost;

   return optimal_lot;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double C_MoneyManagment::GetVolume(double volume_to_check)
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_MoneyManagment::~C_MoneyManagment()
  {
  }
//+------------------------------------------------------------------+
