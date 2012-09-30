function ret = DetectObject(image, cascade)
    % This function returns 1 if the image, when scaled to 128x64 contains
    % the object. Else returns 0
    
    ret = 0;
    stages = size(cascade, 1);
    for stage = 1:stages
        if(cascade(stage).classify(image) ~= 1)
            return;
        end
    end
    ret = 1;
    