% Origibnal filename: Search_nearest.mat
% created 18/08/09

function [value,number] = Search_nearest(data,buffer)

buf_size = size(buffer,2);  % default: 201

% buf_search = [1 ceil(buf_size/8*1) ceil(buf_size/8*2) ceil(buf_size/8*3) ceil(buf_size/8*4)...
%     ceil(buf_size/8*5) ceil(buf_size/8*6) ceil(buf_size/8*7) buf_size];

number = buf_size;
value = buffer(1,buf_size);

search_resolution = 2;

for bi = 1:search_resolution:buf_size
    if data < buffer(1,bi)
        number = bi;
        value = buffer(1,bi);
        break;
    end
end

number = number - ceil(buf_size/2); % resccalling to [-100~100]%

end

