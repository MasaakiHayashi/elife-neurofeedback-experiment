%% Parameter for GetData_NA400ver164

Sampling_Rate = 1000;  % Sampling Rate = Date flow rate, "DON'T CHANGE"
cnt_sample    = 0;     % it should be "0" by each trial
sample_Num    = 0;
PacketSize    = 1264;

EEGi          = 1:4:516; % calculate EEG data each 4 byte
EMGi          = 1:4:32;  % calculate EMG data each 4 byte


%% Buffer

% Buffer have to be defined as [Buffer_FreshRate+1*fs, Channels(129+16)]
% Buffer = [RawData(1:Buffer_FreshRate),0,0,0,...,0,0,0];
% Please take care of calculating raw data in Buffer,
% because all Buffer data are not raw data

% Buffer_FreshRate = 2 * Sampling_Rate;   % You can change this for realtime feedback 
Buffer_FreshRate = 1 * Sampling_Rate;     % You can change this for realtime feedback 
% Buffer           = zeros(Buffer_FreshRate + Sampling_Rate , 137);
Buffer           = zeros(Buffer_FreshRate + Sampling_Rate , 129);


%% Coefficient to change binary data to decimal data

% Data, which are set in uX data type, have to be changed to decimal number
%   * uX means "unsined int X bit"
%
% [ex.Big Endian (Header)]
%
%   u64 (64 bit (8 byte)) : [0,0,0,0,0,0,49,96]  (described each 1 byte in Matlab)  
%       => 2^56*0 + 2^48*0 + 2^40*0 + 2^32*0 + 2^24*0 + 2^16*0 + 2^8*49 + 2^0*96 = 12640 (output decimal number)
%
%
% [ex.Little Endian : reversal data sequence compared with 'Big Endian' (EEG and EMG and other Sample data)]
%
%   u16 (16 bit (2 byte)) : [128,1]     (described each 1 byte in Matlab)    
%       => 2^0*128 + 2^8*1 = 136 (output decimal number)
%
%   u32 (32 bit (4 byte)) : [128,1,0,0] (described each 1 byte in Matlab)   
%       => 2^0*128 + 2^8*1 + 2^16*0 + 2^24*0 = 136 (output decimal number)
%
% (ex)
%   A       = EEG_Data .* coef_EEG  (EEG_Data == [516(byte),sample_Num])
%   size(A) = (129,sample_Num);     (calculating decimal data by each 4 byte data (u32)) 
%

coef_header = [2^56; 2^48; 2^40; 2^32; 2^24; 2^16; 2^8; 2^0;]; % u64, Big Endian
coef_EEG    = repmat([2^0 2^8 2^16 2^24],[50,129]);            % u32, Little Endian
coef_EMG    = repmat([2^0 2^8 2^16 2^24],[50,8]);              % u32, Little Endian
