function ret = DetectObject(image, cascade)
    % This function returns 1 if the image, when scaled to 128x64 contains
    % the object. Else returns 0
    
    ret = 0;
    stages = size(cascade, 1);
    for stage = 1:stages
        for clsr = 1:length(cascade(stage))
            if(cascade(stage, clsr).block_r == -1)
                break;
            end
            if(ClassifyHoG(image, cascade(stage, clsr)) == 0)
                return;
            end
        end
    end
    ret = 1;
    