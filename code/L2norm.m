function [ error ] = L2norm( patch1, patch2 )

RGB_error  = (patch1-patch2).^2;  % MXNX3
pixel_error = sum(RGB_error,3);  % MXNX1
error = sqrt(sum(sum(pixel_error)));

end

