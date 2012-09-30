function ret = detectSingleScale(ii, r, c, ht, wd, scale, cascade)
    % Returns 1 of detected, else 0
    ret = 0;
    stages = size(cascade,1);
    for stage=1:stages
        val = 0;
        for clsr=1:length(cascade(stage).weak_clsr)
            if(isempty(cascade(stage).weak_clsr))
                break;
            end
            cl = cascade(stage).weak_clsr(clsr);    
            hog = ComputeHoG(ii,uint32(r+cl.block_r*scale),uint32(c + cl.block_c*scale),uint32(cl.block_w*scale), uint32(cl.block_w*scale),9);
            for i=1:9
                hog(i) = hog(i)/(scale*scale);
            end
            if(svmclassify(cl.classifier, hog) == 1)
                val = val + cascade(stage).coeff(clsr);
            end
        end
        if(val < cascade(stage).threshold)
            return;
        end
    end
    ret = 1;