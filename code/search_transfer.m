function [ match] = search_transfer( patch, range, sample_texture, texton, source_c, target_c, coordinate, alpha )

[height, width, r] = size(patch);
row_s = range(1,1);  % where are 0s
column_s = range(1,2);
x = coordinate(1,1);  % where are you in the target image
y = coordinate(1,2);
M = size(sample_texture,1);
N = size(sample_texture,2);
%match = zeros(size(patch));
[H, W] = size(target_c);

init_i = ceil(height/2);
init_j = ceil(width/2);
step_i = init_i-1;
step_j = init_j-1;
step = ceil(texton/2)-1;
error_n = zeros(M-2*step_i,N-2*step_j);
error_c = zeros(M-2*step_i,N-2*step_j);

if row_s == 1 && column_s == 1  % first block in first iteration
    % only compute correspondence map error
    target_block = target_c(1:texton,1:texton,:);
    for i = init_i:(M-step_i)
        for j = init_j:(N-step_j)
            source_block = source_c(i-step_i:i+step_i,j-step_j:j+step_j);
            error_c(i-step_i,j-step_j) = L2norm(source_block,target_block);
        end
    end
    tolerance = 1.1*min(error_c(:));
    indexs = find(error_c<=tolerance);  % all blocks match patch within tolerance
    random = randi(length(indexs)); % randomly choose one block
    index = indexs(random);
    [pos_i,pos_j] = ind2sub(size(error_c),index);
    match = sample_texture(pos_i:pos_i+2*step_i,pos_j:pos_j+2*step_j,:);
else
    % other blocks
    % 1. neghborhood error
    for i = init_i:(M-step_i)
        for j = init_j:(N-step_j)
            texture = sample_texture(i-step_i:i+step_i,j-step_j:j+step_j,:);
            texture(row_s:height,column_s:width,:) = 0;
            error_n(i-step_i,j-step_j) = L2norm(patch, texture);
        end
    end
    % 2. correspondence error
    target_block = target_c(x-step:min(x+step,H),y-step:min(y+step,W));
    r_s = x-step;
    c_s = y-step;
    if mod(size(target_block,1),2)==0 %iseven
        r_s = r_s-1;
    end
    if mod(size(target_block,2),2)==0 %iseven
        c_s = c_s-1;
    end
    target_block = target_c(r_s:min(x+step,H),c_s:min(y+step,W));
    for i = init_i:(M-step_i)
        for j = init_j:(N-step_j)
            source_block = source_c(i-step_i:i+step_i,j-step_j:j+step_j);
            error_c(i-step_i,j-step_j) = L2norm(source_block,target_block);
        end
    end
    % combine error_n and error_c
    errors = alpha*error_n+(1-alpha)*error_c;
    tolerance = 1.1*min(errors(:));
    indexs = find(errors<=tolerance);  % all blocks match patch within tolerance
    random = randi(length(indexs)); % randomly choose one block
    index = indexs(random);
    [pos_i,pos_j] = ind2sub(size(errors),index);
    match = sample_texture(pos_i:pos_i+2*step_i,pos_j:pos_j+2*step_j,:); 

end

end

