function ret = detectSingleScale(ii, r, c, ht, wd, scale, cascade)
    % Returns 1 of detected, else 0
    ret = 0;
    stages = size(cascade,1);
    for stage=1:stages
        for clsr=1:length(cascade(stage))
            if(cascade(stage, clsr).block_r == -1)
                break;
            end
            cl = cascade(stage, clsr);
            hog = ComputeHoG(ii,r+cl.block_r*scale,c + cl.block_c*scale,cl.block_w*scale, cl.block_w*scale,9);
            for i=1:9
                hog(i) = hog(i)/(scale*scale);
            end
            ret = svmclassify(cl.classifier, hog);
            if(ret == 0)
                return;
            end
        end
    end
    ret = 1;