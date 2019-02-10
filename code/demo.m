%% 1. texture synthesis 
% -- inputs: sample texture, texton size, number of textons needed,
%            quilting method (minimumcut by default, interpolation if declared)
% -- output: synthesised texture 
% the size of synthesised texture is determined by texton and its number.
% If texton = 45, number of texton = 13, width of overlap is texton/6,
% output texture size = 13 * texton * 5/6 +texton/6 = 501

% 1. minimum cut
texture1 = synthesis ( 'tomatoes', 45, 13 ); % or synthesis ( 'tomatoes', 45, 13, 'minimumcut' )

% 2. interpolation
texture2 = synthesis( 'tomatoes', 45, 13, 'interpolation' );

%% 2. texture transfer
% -- inputs: sample texture, target image, texton size, iteration times
%            (Here we use minimumcut only.)
% -- output: transfered image, the same size as target image
texture3 = transfer( 'source','target', 15, 1 );

% Here the source and target images are the same as those shown in image
% quilting paper. I also include another image, scenery.jpg, as target.