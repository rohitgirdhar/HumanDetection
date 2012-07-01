function output = GetDetections(images, cascade)
    % This function returns all those images that are marked true by the
    % casade
    n = length(images);
    i = 1;
    for image = 1:n
        if(DetectObject(images{image}, cascade) == 1)
            output{i} = images{image};
            i = i + 1;
        end
    end
    
            