function iimg = GetIntegralHoG(image_window, nbins)
    % This function computes the integral image of the HoGs for each pizel
    % Input : image window to compute for, and number of bins for HoG
    % Return Value : A (ht+1) x (wd+1) x nbins integral image, due to 0 pad
    if(size(image_window,1) == 1) 
        image_window = imread(image_window);
    end
    wd = size(image_window,2);
    ht = size(image_window,1);
    max_angle = 180; % from 0 to 180
    bin_size = max_angle/nbins;
    % If the window is not wd x ht, resize it
%    I = imresize(image_window, [ht, wd]);
    I = double(image_window);
    
    % now compute the gradients
    
    % Note: For color images, we calculate gradient for each channel, and
    % take the and take one with highest norm
    
    fil = [-1 0 1];
    dX = imfilter(I, fil);
    dY = imfilter(I, -fil');
    I_gd = mod((atand(dY ./ dX) + 180), 180);
    I_mg = sqrt(dX.*dX + dY.*dY);
    % Now, gd contains angle of each pixel in degrees from 0 to 180 into
    % nbins number of bins.
    
    img = zeros(ht,wd,nbins);
    for row = 1:ht
        for col = 1:wd
            % use the channel with max norm
            max_norm = I_mg(row,col,1);
            ang = I_gd(row,col,1);
            if(isnan(ang)) 
                ang = 0;  % a default value, to handle boundary
            end
            for ch = 2:size(I_gd,3)
                if max_norm < I_mg(row,col,ch)
                    max_norm = I_mg(row,col,ch);
                    ang = I_gd(row,col,ch);
                end
            end
            % find which bin to put this pixel mangnitude into
            if ang == max_angle
                ang = 0;
            end
            reqd_bin = floor(ang/bin_size)+1;
            img(row,col,reqd_bin) = max_norm;
        end
    end
    
    % now convert each of nbins images into integral image, for fast
    % further computation
    
    iimg = zeros(ht+1, wd+1, nbins);
    for bin = 1:nbins
        iimg(:,:,bin) = integralImage(img(:,:,bin));
    end