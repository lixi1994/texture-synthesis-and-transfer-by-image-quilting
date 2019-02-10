function [ blend_patch ] = minimumCut_transfer( patch, range, match)

%texton = size(patch,1); % block, M=texton
[height, width, r] = size(patch);
blend_patch = zeros(size(patch));
row_s = range(1,1);  % where are 0s
column_s = range(1,2);

%overlapsize = floor(texton/6);
overlapsize_l = column_s-1;
overlapsize_a = row_s-1;

% pixel errors
error_space_left = (patch(1:height,1:column_s-1,:)-match(1:height,1:column_s-1,:)).^2; 
error_space_left = sum(error_space_left,3);
error_space_above = (patch(1:row_s-1,1:width,:)-match(1:row_s-1,1:width,:)).^2;
error_space_above = sum(error_space_above,3)';  % make them the same size

error_left = NaN(height,overlapsize_l+2);  % pad NaN, easy to get min
error_above = NaN(width,overlapsize_a+2);
[M_l,N_l] = size(error_left);
[M_a,N_a] = size(error_above);

% cumulative errors
if ~isempty(error_space_left)
    error_left(1:M_l,2:N_l-1) = error_space_left(:,:);
    for i = 2:M_l % first row can't be processed
        for j = 2:N_l-1
            error_left(i,j) = error_left(i,j)+min(error_left(i-1,j-1:j+1));
        end
    end
end
if ~isempty(error_space_above)
    error_above(1:M_a, 2:N_a-1) = error_space_above(:,:);
    for i = 2:M_a % first row can't be processed
        for j = 2:N_a-1
            error_above(i,j) = error_above(i,j)+min(error_above(i-1,j-1:j+1));
        end
    end
end

% dynamic algorithm to find min cost path
path_left = zeros(height,1); % store j
path_above = zeros(width,1); % store i

if ~isempty(error_space_left)
    [minimum, start_j] = min(error_left(height,:));  % left path starts from the minimum in the last row
    path_left(height) = start_j-1;  % the first is NaN
    for i = height-1:-1:1
        [minimum, j] = min(error_left(i,start_j-1:start_j+1)); % j = 1, 2, 3
        j = j-2;
        start_j = start_j+j;
        path_left(i) = start_j-1;
    end
end
if ~isempty(error_space_above)
    [minimum, start_i] = min(error_above(width,:));
    path_above(width) = start_i-1;  % the first is NaN
    for j = width-1:-1:1
        [minimum, i] = min(error_above(j,start_i-1:start_i+1)); % i = 1, 2, 3
        i = i-2;
        start_i = start_i+i;
        path_above(j) = start_i-1;
    end
end

% minimum error boundary cut
% left cut
for i = row_s:height
    for j = 1:column_s-1
        if j < path_left(i)
            blend_patch(i,j,:) = patch(i,j,:);
        else
            blend_patch(i,j,:) = match(i,j,:);
        end
    end
end
% above cut
for j = column_s:width
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

blend_patch(row_s:height, column_s:width, :) = match(row_s:height, column_s:width, :);

end