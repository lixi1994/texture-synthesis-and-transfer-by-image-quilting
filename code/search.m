function [ match, pos_i, pos_j ] = search( patch, range, sample_texture )

texton = size(patch,1); % block, M=texton
row_s = range(1,1);  % where are 0s
column_s = range(1,2);
M = size(sample_texture,1);
N = size(sample_texture,2);
match = zeros(size(patch));

init = ceil(texton/2);
step = init-1;
error = zeros(M-2*step,N-2*step);

for i = init:(M-step)
    for j = init:(N-step)
        texture = sample_texture(i-step:i+step,j-step:j+step,:);
        texture(row_s:texton,column_s:texton,:) = 0;
        err = L2norm(patch, texture);
        error(i-step,j-step) = err;
    end
end

tolerance = 1.1*min(error(:));
%tolerance = min(error(:))+0.5;
indexs = find(error<=tolerance);  % all blocks match patch within tolerance
random = randi(length(indexs)); % randomly choose one block
index = indexs(random);
[pos_i,pos_j] = ind2sub(size(error),index);
match(:,:,:) = sample_texture(pos_i:pos_i+2*step,pos_j:pos_j+2*step,:);

end

