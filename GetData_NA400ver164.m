%
% @ author Shoichiro Takeda
% @ data   2015/07/09
% @ updata 2015/07/15 for Endian
% @ update 2015/07/22 for quickly, quit function
%
%% Caution (Please Read below at First)
%
% I made this code for NetStation NA400 ver1.6.4
%
% You must read "GetData_Parameter.m" before this program runs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In New NetStation Version,                                                       %
% We Can Change the Sampling Rate for realtime feedback                            %
% Sampling Rate (fs) is fixed 1000 Hz,                                             %
% However, if you set the Sampling Rate is 250Hz, "last 4 sample data are same"    %
% (if 500Hz, 2 sample data are same)                                               %
%                                                                                  %
% If you do online feedback with your expected sampling rate,                      %
% You have to change the sampling rate in "NetStation Aquisition" software in iMac %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% In Matlab, tcpip() function is basically set Endian to "Big Endian"
% Header is flowed in "Big Endian"
% However, Samples are flowed in "Little Endian"
%
%% Packet construction
%
% One packet is consisted of 16 byte Header and 1264 byte (one sample) * sample number
% All data type are defined u8 or u16 or u32 or u64
%   * uX means "unsined int X bit"
% 
% [Header] + [sample1] + [sample2] + ... + [sampleN]
%     [16] +    [1264] +    [1264] + ... +    [1264]
%           |---------------------------------------|
%                    the nuber of sample(N)
%
% Header construction (16 byte , Network Byte Order, Big Endian)
%   { 
%     u64 AmpID         : 8 byte (= 64 bit)
%     u64 Size of Data  : 8 byte (= 64 bit)
%   }
% 
% In TCP/IP protcol, Header have to be set 'Big Endian' all over the World.
% However, other packet data is free to set (NetStation Samples data are send "Little Endian")
%
% Last 8 byte in Header is used to check how many samples(N) come now.
%   * sample_Num = Header(9:16,:) .* coef_header / PacketSize; (=> All byte / 1 sample byte)  
%   * Please check coef_header in "GetData_Parameter.m"
%
%
% sample construction (1264 byte, Network Byte Order, Little Endian)
%   { 
%    uXX Some Data      : 80 byte 
%       * These are not important.
%         if you want to check it, please read the NetStation manuals.
%
%    u32 EEGData[256]   : 1024 byte (4 byte * 256 Channels) 
%   
%    uXX Some Data      : 32 byte
%
%    u32 EMGData1[16]   : 64 byte (4 byte * 16 Channels) 
%    u32 EMGData2[16]   : 64 byte (4 byte * 16 Channels) 
%   }
%
% EEGData     = sample(81:596)      : 4 byte * 129 channels (516 byte)
% EMGData1_8  = sample(1137:1168)   : 4 byte * 8   channels (32 byte)
% EMGData9_16 = sample(1169:1200)   : 4 byte * 8   channels (32 byte)
% 
%% Main 

Header         = fread(ti2,16);
Header_decimal = Header(9:16,:) .* coef_header;
Header_Output  = Header_decimal(1,1) + Header_decimal(2,1) + Header_decimal(3,1) + ...
                 Header_decimal(4,1) + Header_decimal(5,1) + Header_decimal(6,1) + ...
                 Header_decimal(7,1) + Header_decimal(8,1);

sample_Num     = Header_Output / PacketSize;

if sample_Num > 50 % if coefficient size is over, set enough size to calculate
    coef_EEG   = repmat([2^0 2^8 2^16 2^24],[sample_Num,129]);        % u32, Little Endian
    coef_EMG   = repmat([2^0 2^8 2^16 2^24],[sample_Num,8]);          % u32, Little Endian
end

rowSamples     = fread(ti2,PacketSize*sample_Num)'; 

%%% unsigned %%%
% Samples        = rowSamples(bsxfun(@plus, PacketSize*(0:sample_Num-1)',(1:PacketSize)));

%%% signed %%%
Samples1   =   1:PacketSize;
Samples2   =   ones(sample_Num,PacketSize);
Samples2(1,:)   =   Samples1;
for i = 2:sample_Num
    Samples2(i,:) = Samples1 + PacketSize*(i-1);
end
Samples   =   rowSamples(Samples2);

EEG_decimal = Samples(:,81:596)    .* coef_EEG(1:sample_Num,:);
EMG_decimal = Samples(:,1137:1168) .* coef_EMG(1:sample_Num,:);

s           = 1:1:sample_Num;
EEG_Output  = EEG_decimal(s,EEGi) + EEG_decimal(s,EEGi+1) + EEG_decimal(s,EEGi+2) + EEG_decimal(s,EEGi+3);
EMG_Output  = EMG_decimal(s,EMGi) + EMG_decimal(s,EMGi+1) + EMG_decimal(s,EMGi+2) + EMG_decimal(s,EMGi+3);

%%% signed %%% 
EEG_Output(EEG_Output >= 2^31)   =   EEG_Output(EEG_Output >= 2^31)-(2^32);

new_EEGData    =  0.00009313225 .* EEG_Output;
new_EMGData1_8 = -0.00111758708 .* EMG_Output;

cnt_sample   = cnt_sample + sample_Num;

%% Update Buffer 
% Buffer have to be defined as [Buffer_FreshRate+(enough size), Channels(129+16)]
% Buffer = [RawData(1:Buffer_FreshRate),0,0,0,...,0,0,0];
% Please take care of calculating raw data in Buffer,
% because all Buffer data are not raw data

% 1. add last data
% Buffer(Buffer_FreshRate+1:Buffer_FreshRate+sample_Num,:) = [new_EEGData,new_EMGData1_8];
Buffer(Buffer_FreshRate+1:Buffer_FreshRate+sample_Num,:) = new_EEGData;

% 2. shift forward & delete old data
Buffer(1:Buffer_FreshRate,:) = Buffer(1+sample_Num:(Buffer_FreshRate+sample_Num),:);

