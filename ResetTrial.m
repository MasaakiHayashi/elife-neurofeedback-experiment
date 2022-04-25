  cnt_sample      = 0;
  precnt_sample   = 0;
  
  RestStopper     = 0;
  ReadyStopper    = 0;   
  TaskStopper     = 0;
  TMS_Stopper     = 0;
  BufferStopper   = 0;
  intervalStopper = 0;
  TMSStopper      = 0;
  cnt_num         = 0;
  cnt_rest        = 0;
  cnt_ready       = 0;
  cnt_task        = 0;
  cnt_raw         = 0;
  
  ERD_c4_stock = zeros(stocksize,1);
  ERD_c3_stock = zeros(stocksize,1);
  ERD_c4_stock_tmp = zeros(stocksize,1);
  ERD_c3_stock_tmp = zeros(stocksize,1);
  
  