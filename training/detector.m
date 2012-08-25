function res = detector(img, cascade)
    % This function returns the detections in the cascade in following
    % format : c r w h
    I = imread(img);
    ii = GetIntegralHoG(I,9);
    ht = size(I, 1);
    wd = size(I, 2);
    scal = 1;
    
    stride = 8; 
    sf = 1.2;
    base_h = 128;
    base_w = 64;
    iter = min(log(ht/base_h)/log(sf), log(wd/base_w)/log(sf));
    iter = floor(iter);
    
    scale = 1;
    count = 1;
    for i=1:iter
        for r=1:stride:ht-base_h*scale
            for c=1:stride:wd-base_w*scale
                if(detectSingleScale(ii, r, c, base_h*scale, base_w*scale, scale, cascade) == 1)
                    res{count} = [c,r,base_w*scal, base_h*scal];
                    count = count+1;
                end
                
            end
        end
        scale = scale*1.2;
    end