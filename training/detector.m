function res = detector(img, cascade)
    % This function returns the detections in the cascade in following
    % format : c r w h
    I = imread(img);
    ht = size(I, 1);
    wd = size(I, 2);
    scal = 1;

    ht = size(I,1)
    wd = size(I,2)
    slide_r = 4;
    slide_c = 4;
    slide_h = 8;
    count = 1;
    % Now check at all positions, at all scales
    
    for r=2:slide_r:ht
        for c=2:slide_c:wd
            for h = 8:slide_h:ht-r
                tester = imcrop(I, [c,r,h/2,h]);
                tester = imresize(tester, [128 64]);
                ii = GetIntegralHoG(tester,9);
                if(DetectObject(ii, cascade) == 1)
                    res{count} = [c*scal, r*scal, h*scal/2, h*scal];
                    count = count+1;
                end
            end
        end
    end