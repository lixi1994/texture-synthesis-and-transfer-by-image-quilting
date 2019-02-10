function [ blend_patch ] = minimumCut( patch, range, match )

texton = size(patch,1); % block, M=texton
blend_patch = zeros(size(patch));
row_s = range(1,1);  % where are 0s
column_s = range(1,2);

overlapsize = floor(texton/6);

% pixel errors
error_space_left = (patch(1:texton,1:column_s-1,:)-match(1:texton,1:column_s-1,:)).^2; 
error_space_left = sum(error_space_left,3);
error_space_above = (patch(1:row_s-1,1:texton,:)-match(1:row_s-1,1:texton,:)).^2;
error_space_above = sum(error_space_above,3)';  % make them the same size

error_left = NaN(texton,overlapsize+2);  % pad NaN, easy to get min
error_above = NaN(texton,overlapsize+2);
[M,N] = size(error_left);

% cumulative errors
if ~isempty(error_space_left)
    error_left(1:M,2:N-1) = error_space_left(:,:);
    for i = 2:M % first row can't be processed
        for j = 2:N-1
            error_left(i,j) = error_left(i,j)+min(error_left(i-1,j-1:j+1));
        end
    end
end
if ~isempty(error_space_above)
    error_above(1:M, 2:N-1) = error_space_above(:,:);
    for i = 2:M % first row can't be processed
        for j = 2:N-1
            error_above(i,j) = error_above(i,j)+min(error_above(i-1,j-1:j+1));
        end
    end
end

% dynamic algorithm to find min cost path
path_left = zeros(texton,1); % store j
path_above = zeros(texton,1); % store i

if ~isempty(error_space_left)
    [minimum, start_j] = min(error_left(texton,:));  % left path starts from the minimum in the last row
    path_left(texton) = start_j-1;  % the first is NaN
    for i = texton-1:-1:1
        [minimum, j] = min(error_left(i,start_j-1:start_j+1)); % j = 1, 2, 3
        j = j-2;
        start_j = start_j+j;
        path_left(i) = start_j-1;
    end
end
if ~isempty(error_space_above)
    [minimum, start_i] = min(error_above(texton,:));
    path_above(texton) = start_i-1;  % the first is NaN
    for j = texton-1:-1:1
        [minimum, i] = min(error_above(j,start_i-1:start_i+1)); % i = 1, 2, 3
        i = i-2;
        start_i = start_i+i;
        path_above(j) = start_i-1;
    end
end

% minimum error boundary cut
% left cut
for i = row_s:texton
    for j = 1:column_s-1
        if j < path_left(i)
            blend_patch(i,j,:) = patch(i,j,:);
        else
            blend_patch(i,j,:) = match(i,j,:);
        end
    end
end
% above cut
for j = column_s:texton
    for i = 1:row_s-1
        if i < path_above(j)
            blend_patch(i,j,:) = patch(i,j,:);
        else
            blend_patch(i,j,:) = match(i,j,:);
        end
    end
end
% upper left coner cut
for i = 1:row_s-1
    for j = 1:column_s-1
        if i < path_above(j) || j < path_left(i)
            blend_patch(i,j,:) = patch(i,j,:);
        else
            blend_patch(i,j,:) = match(i,j,:);
        end
    end
end

blend_patch(row_s:texton, column_s:texton, :) = match(row_s:texton, column_s:texton, :);

end

