function images = GetDetections(images, cascade)
    % This function returns all images classes
    n = length(images);
    todelete = zeros(1,n);
    t = 1;
    for image = 1:n
        if(DetectObject(images{image}, cascade) == 0) % These are negative images
            todelete(1, t) = image;
            t = t+1;
        end
    end
    sub = 0;
    for e = 1:t-1
        images(todelete(1,e)-sub) = [];
        sub = sub+1;
    end
    
    
            