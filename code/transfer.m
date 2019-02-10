function [ output_texture ] = transfer( source_image, target_image, texton, iteration_num )

% read in source and target txture
texture_path = 'sampleTextures/%s.jpg';
source_path = sprintf(texture_path,source_image);
target_path = sprintf(texture_path,target_image);
texture = imread(source_path);
texture = im2double(texture);
target = imread(target_path);
target = im2double(target);
source = rgb2gray(texture);
target = rgb2gray(target);
source_c = imgaussfilt(source,1);
target_c = imgaussfilt(target,1);

% texton, output texture size
%texton = str2double(texton);
overlap_size = floor(texton/6);
%iteration_num = str2double(iteration_num);
[output_M,output_N,r] = size(target);
block_num_i = ceil((output_M-overlap_size)/(texton-overlap_size));
block_num_j = ceil((output_N-overlap_size)/(texton-overlap_size));

% output texture - RGB
output_texture = zeros(output_M,output_N,3);

% texture synthesis initial coordinates
init = ceil(texton/2);
step = init -1;

% border coordinates
last_i = init+(block_num_i-1)*(texton-overlap_size);
last_j = init+(block_num_j-1)*(texton-overlap_size);

alpha = 0.1; % first iteration 

for i = init:texton-overlap_size:last_i-1
    for j = init:texton-overlap_size:last_j-1
        % the first blcok in output texture
        if (i == init) && (j == init)
            patch = output_texture(i-step:i+step,j-step:j+step,:);
            range = [1 1];  % where are all 0s
            coordinate = [i j];
            match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha );
            output_texture(1:texton,1:texton,:) = match(:,:,:);
            figure(1);
            imshow(output_texture);
        else 
            % other blocks
            % first row
            if i == init
                patch = output_texture(i-step:i+step,j-step:j+step,:);
                range = [1 overlap_size+1];  % where are all 0s
                coordinate = [i j];
                match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha ); % search for the match of patch in sample texture
                blend_patch = minimumCut_transfer(patch, range, match);
                output_texture(1:texton,j-step:j+step,:) = blend_patch(:,:,:);
                figure(1);
                imshow(output_texture);
            else
                % first column
                if j == init
                    patch = output_texture(i-step:i+step,j-step:j+step,:);
                    range = [overlap_size+1 1 ];  % where are all 0s
                    coordinate = [i j];
                    match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha ); % search for the match of patch in sample texture
                    blend_patch = minimumCut_transfer(patch, range, match);
                    output_texture(i-step:i+step,1:texton,:) = blend_patch(:,:,:);
                    figure(1);
                    imshow(output_texture);
                else
                    % the other blocks
                    patch(:,:,:) = output_texture(i-step:i+step,j-step:j+step,:);
                    range = [overlap_size+1 overlap_size+1 ];  % where are all 0s
                    coordinate = [i j];
                    match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha ); % search for the match of patch in sample texture
                    blend_patch = minimumCut_transfer(patch, range, match);
                    output_texture(i-step:i+step,j-step:j+step,:) = blend_patch(:,:,:);
                    figure(1);
                    imshow(output_texture);
                end
            end  
        end
    end
end

% last column
j = last_j;
c_s = j-step;
for i = init:texton-overlap_size:last_i-1
    patch = output_texture(i-step:i+step,c_s:output_N,:);
    coordinate = [i,j];
    range = [1 overlap_size+1];
    if mod(size(patch,2),2)==0 % iseven
        c_s = c_s-1;
        range(2) = range(2)+1;
    end
    patch = output_texture(i-step:i+step,c_s:output_N,:);
    match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha ); % search for the match of patch in sample texture
    blend_patch = minimumCut_transfer(patch, range, match);
    output_texture(i-step:i+step,c_s:output_N,:) = blend_patch(:,:,:);
    figure(1);
    imshow(output_texture);
end
%last row
i = last_i;
r_s = i-step;
for j = init:texton-overlap_size:last_j-1
    patch = output_texture(r_s:output_M,j-step:j+step,:);
    coordinate = [i,j];
    range = [overlap_size+1 1];
    if mod(size(patch,1),2)==0 % iseven
        r_s = r_s-1;
        range(1) = range(1)+1;
    end  
    patch = output_texture(r_s:output_M,j-step:j+step,:);
    match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha ); % search for the match of patch in sample texture
    blend_patch = minimumCut_transfer(patch, range, match);
    output_texture(r_s:output_M,j-step:j+step,:) = blend_patch(:,:,:);
    figure(1);
    imshow(output_texture);
end
% lowwer right corner
i = last_i;
j = last_j;
r_s = i-step;
c_s = j-step;
patch = output_texture(r_s:output_M,c_s:output_N,:);
coordinate = [i,j];
range = [overlap_size+1 overlap_size+1];
if mod(size(patch,1),2)==0 % row is even
    r_s = r_s-1;
    range(1) = range(1)+1;
end
if mod(size(patch,2),2)==0 % column is even
    c_s = c_s-1;
    range(2) = range(2)+1;
end
patch = output_texture(r_s:output_M,c_s:output_N,:);
match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha ); % search for the match of patch in sample texture
blend_patch = minimumCut_transfer(patch, range, match);
output_texture(r_s:output_M,c_s:output_N,:) = blend_patch(:,:,:);
figure(1);
imshow(output_texture);

% 2nd-Nth iterations
for i = 2:iteration_num
    alpha = 0.8*(i-1)/(iteration_num-1)+0.1;
    texton = ceil(2*texton/3);
    if mod(texton,2) == 0 % iseven
        texton = texton+1;
    end
    output_texture = transfer_iteration(source_c, target_c, texture, output_texture, texton, alpha);
end

image_path = 'sampleTextures/%s-%s-transfer.jpg';
target_path = sprintf(image_path,source_image,target_image);
imwrite(output_texture,target_path);

end

