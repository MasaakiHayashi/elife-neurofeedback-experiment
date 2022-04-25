function [ eSample,count_sample ] = GetData(eSample,count_sample,ti2,Fs,ch)

    data731                     = fread(ti2, 16); 
    dataSize                    = 2^56*data731(9) +2^48*data731(10)+2^40*data731(11)+ ...
                                  2^32*data731(12)+2^24*data731(13)+2^16*data731(14)+ ...
                                  2^8*data731(15) +2^0*data731(16); 
    sampleNum                   = dataSize/1152;        
    Data                        = fread(ti2,288*sampleNum,'float'); 
    data                        = Data(bsxfun(@plus, 288*(0:sampleNum-1)',ch+8));
    temp(:,1:length(ch))        = eSample(:,ch);
    temp(end+1:end+sampleNum,:) = data*0.0238;
    eSample(:,ch)               = temp(end-2*Fs+1:end,:);
    count_sample                = count_sample + sampleNum;

end