function [ output_texture ] = synthesis( source_image, texton, block_num, method )

% read in sample txture
texture_path = 'sampleTextures/%s.jpg';
texture_file = sprintf(texture_path,source_image);
texture = imread(texture_file);
texture = im2double(texture);
M = size(texture,1);
N = size(texture,2);

% texton, output texture size
%texton = str2double(texton);
%block_num = str2double(block_num);
overlap_size = floor(texton/6);
output_size = texton+(block_num-1)*(texton-overlap_size);

if nargin == 3   % if the number of inputs equals 3
  method='minimumcut'; % then method is set to minimumcut by default.
end

% output texture - RGB
output_texture = zeros(output_size,output_size,3);
figure(1);
imshow(output_texture);

% texture synthesis
init = ceil(texton/2);
step = init -1;

for i = init:(texton-overlap_size):(output_size-step+1)
    for j = init:(texton-overlap_size):(output_size-step+1)
        % the first blcok in output texture
        if (i == init) && (j == init)
            pos_i = randi([init M-step],1,1);
            pos_j = randi([init N-step],1,1);
            output_texture(1:texton, 1:texton, :) = texture(pos_i-step:pos_i+step, pos_j-step:pos_j+step, :);
            figure(1);
            imshow(output_texture);
        else
            % first row
            if i == init
                patch(:,:,:) = output_texture(i-step:i+step,j-step:j+step,:);
                range = [1 overlap_size+1];  % where are all 0s
                [match, pos_i, pos_j] = search( patch, range, texture ); % search for the match of patch in sample texture
                if strcmp(method,'minimumcut')
                    blend_patch = minimumCut(patch, range, match); % blend patches by minimun cut
                else
                    blend_patch = interpolation(patch, range, match); % blend patches by interpolation
                end
                output_texture(1:texton,j-step:j+step,:) = blend_patch(:,:,:);
                figure(1);
                imshow(output_texture);
            else
                % first column
                if j == init
                    patch(:,:,:) = output_texture(i-step:i+step,j-step:j+step,:);
                    range = [overlap_size+1 1 ];  % where are all 0s
                    [match, pos_i, pos_j] = search( patch, range, texture ); % search for the match of patch in sample texture
                    if strcmp(method,'minimumcut')
                        blend_patch = minimumCut(patch, range, match); % blend patches by minimun cut
                    else
                        blend_patch = interpolation(patch, range, match); % blend patches by interpolation
                    end
                    output_texture(i-step:i+step,1:texton,:) = blend_patch(:,:,:);
                    figure(1);
                    imshow(output_texture);
                else
                    % the other blocks
                    patch(:,:,:) = output_texture(i-step:i+step,j-step:j+step,:);
                    range = [overlap_size+1 overlap_size+1 ];  % where are all 0s
                    [match, pos_i, pos_j] = search( patch, range, texture ); % search for the match of patch in sample texture
                    if strcmp(method,'minimumcut')
                        blend_patch = minimumCut(patch, range, match); % blend patches by minimun cut
                    else
                        blend_patch = interpolation(patch, range, match); % blend patches by interpolation
                    end
                    output_texture(i-step:i+step,j-step:j+step,:) = blend_patch(:,:,:);
                    figure(1);
                    imshow(output_texture);
                end
            end
        end
        
        pos = [pos_j pos_i texton texton];
        figure(2);
        imshow(texture);
        hold on;
        rectangle('Position',pos,'EdgeColor','w','LineWidth',2);
        
    end
end

image_path = 'sampleTextures/%s-%s.jpg';
target_path = sprintf(image_path,source_image,method);
imwrite(output_texture,target_path);

end

