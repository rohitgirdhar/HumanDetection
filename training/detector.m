function [res, total_win, avg_stg] = detector(img, cascade)
    % This function returns the detections in the cascade in following
    % format : c r w h
    I = imread(img);
    ii = GetIntegralHoG(I,9);
    ht = size(I, 1);
    wd = size(I, 2);
    scal = 1;
    res = {};
    stride = 8; 
    sf = 1.2;
    base_h = 128;
    base_w = 64;
    iter = min(log(ht/base_h)/log(sf), log(wd/base_w)/log(sf));
    iter = floor(iter);
    
    scale = 1;
    count = 1;
    total_win = 0;
    tot_stg = 0;
    for i=1:iter
        for r=1:stride:ht-base_h*scale
            for c=1:stride:wd-base_w*scale
                total_win = total_win + 1;
                [ret, stg] = detectSingleScale(ii, r, c, base_h*scale, base_w*scale, scale, cascade);
                tot_stg = tot_stg + stg;
                if(ret == 1)
                    res{count} = [c,r,base_w*scal, base_h*scal];
                    count = count+1;
                end 
            end
        end
        scale = scale*sf;
    end
    avg_stg = tot_stg/total_win;
