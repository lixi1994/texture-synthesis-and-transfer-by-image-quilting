function [ blend_patch ] = interpolation( patch, range, match )

texton = size(patch,1); % block, M=texton
blend_patch = zeros(size(patch));
row_s = range(1,1);  % where are 0s
column_s = range(1,2);

init = ceil(texton/2);
step = init-1;
overlapsize = floor(texton/6);

for i = 1:texton
    for j = 1:column_s-1
        alpha = j/overlapsize;
        blend_patch(i,j,:) = (1-alpha)*patch(i,j,:)+alpha*match(i,j,:);
    end
end

for i = 1:row_s-1
    for j = 1:column_s-1
        alpha = i/overlapsize;
        tmp(1,1,:) = (1-alpha)*patch(i,j,:)+alpha*match(i,j,:);
        blend_patch(i,j,:) = 1/2*(blend_patch(i,j,:)+tmp(1,1,:));
    end
end

for i = 1:row_s-1
    for j= column_s:texton
        alpha = i/overlapsize;
        blend_patch(i,j,:) = (1-alpha)*patch(i,j,:)+alpha*match(i,j,:);
    end
end

blend_patch(row_s:texton,column_s:texton,:) = match(row_s:texton,column_s:texton,:);

end

