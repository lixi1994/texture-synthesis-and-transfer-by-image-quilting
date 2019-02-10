function [ output_texture ] = transfer_iteration( source_c, target_c, texture, output_texture, texton, alpha )

% texton, output texture size
overlap_size = floor(texton/6);
[output_M,output_N,r] = size(output_texture);
block_num_i = ceil((output_M-overlap_size)/(texton-overlap_size));
block_num_j = ceil((output_N-overlap_size)/(texton-overlap_size));

% texture synthesis initial coordinates
init = ceil(texton/2);
step = init -1;

% border coordinates
last_i = init+(block_num_i-1)*(texton-overlap_size);
last_j = init+(block_num_j-1)*(texton-overlap_size);

for i = init:texton-overlap_size:last_i-1
    for j = init:texton-overlap_size:last_j-1
        
        coordinate = [i j];
        % first block, no minimumCut
        if (i == init) && (j == init)
            patch = output_texture(i-step:i+step,j-step:j+step,:);
            % no 0s in iterations
            range = [size(patch,1)+1 size(patch,2)+1];
            match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha );
            output_texture(1:texton,1:texton,:) = match(:,:,:);
        else
            % other blocks
            patch = output_texture(i-step:i+step,j-step:j+step,:);
            % no 0s in iterations
            range = [size(patch,1)+1 size(patch,2)+1];
            match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha );
            blend_patch = minimumCut_transfer(patch, range, match);
            output_texture(i-step:i+step,j-step:j+step,:) = blend_patch(:,:,:);
        end
        
    end
end

% last column
j = last_j;
c_s = j-step;
for i = init:texton-overlap_size:last_i-1
    patch = output_texture(i-step:i+step,c_s:output_N,:);
    coordinate = [i,j];
    range = [size(patch,1)+1 size(patch,2)+1];
    if mod(size(patch,2),2)==0 % iseven
        c_s = c_s-1;
        range(2) = range(2)+1;
    end
    patch = output_texture(i-step:i+step,c_s:output_N,:);
    match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha ); % search for the match of patch in sample texture
    blend_patch = minimumCut_transfer(patch, range, match);
    output_texture(i-step:i+step,c_s:output_N,:) = blend_patch(:,:,:);
end
%last row
i = last_i;
r_s = i-step;
for j = init:texton-overlap_size:last_j-1
    patch = output_texture(r_s:output_M,j-step:j+step,:);
    coordinate = [i,j];
    range = [size(patch,1)+1 size(patch,2)+1];
    if mod(size(patch,1),2)==0 % iseven
        r_s = r_s-1;
        range(1) = range(1)+1;
    end  
    patch = output_texture(r_s:output_M,j-step:j+step,:);
    match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha ); % search for the match of patch in sample texture
    blend_patch = minimumCut_transfer(patch, range, match);
    output_texture(r_s:output_M,j-step:j+step,:) = blend_patch(:,:,:);
end
% lowwer right corner
i = last_i;
j = last_j;
r_s = i-step;
c_s = j-step;
patch = output_texture(r_s:output_M,c_s:output_N,:);
coordinate = [i,j];
range = [size(patch,1)+1 size(patch,2)+1];
if mod(size(patch,1),2)==0 % row is even
    r_s = r_s-1;
    range(1) = range(1)+1;
end
if mod(size(patch,2),2)==0 % column is even
    c_s = c_s-1;
    range(2) = range(2)+1;
end
patch = output_texture(r_s:output_M,c_s:output_N,:);
match = search_transfer( patch, range, texture, texton, source_c, target_c, coordinate, alpha, 1 ); % search for the match of patch in sample texture
blend_patch = minimumCut_transfer(patch, range, match);
output_texture(r_s:output_M,c_s:output_N,:) = blend_patch(:,:,:);

end
