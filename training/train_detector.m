function cascade = train_detector(F_target, f_max, d_min, pos_dir, neg_dir)
    % This function takes the positive and negative trainging image
    % directories and constructs the adaBoost cascade
    
    % F_target : The target False Positive rate overall
    % f_max : Max false positive per stage (cascade level)
    % d_min : Min acceptable detection rate per cascade level (not used)
    % pos_dir : directory with positive images
    % neg_dir : directory with negative images
    
    % Read all the image files into a 64x128 windows
    pos_files = ReadAllImages(pos_dir, 1, 9);
    n_pos = length(pos_files);
    neg_files = ReadAllImages(neg_dir, 7, 9);
    n_neg = length(neg_files);
    
    nbins = 9;
    
    % Now divide into training and validation
    train_files_perc = 0.5;
    total_pos = n_pos;
    lim = uint32(train_files_perc*n_pos);
    pos = pos_files(1:lim);
    pos_val = pos_files(lim+1:total_pos);
    
    total_neg = n_neg;
    lim = uint32(train_files_perc*n_neg);
    neg = neg_files(1:lim);
    neg_val = neg_files(lim+1:total_neg);
    
    
    
    max_stages = 10; % the max number of stages in the cascade
    
    
    cascade(max_stages, 1) = StrongClassifier();
    
    i = 0;  % current stage
    D = 1.0;    % current detection rate (overall)
    F = 1.0;    % current FP rate (overall)
    
    
    
    while(F > F_target && i < max_stages)
       i = i+1;
       if(i > max_stages)
           break;
       end
       
       fprintf('Stage %d, current F = %f\n, current D = %f', i, F, D);
       
       [f,d] = cascade(i,1).learn(pos, neg, pos_val, neg_val, f_max, d_min);
       
       F = F*f;
       D = D*d;
       % Now, discard the old neg samples, and use those that were
       % misclassified by the current detector
       max_neg_samples = 700;
       clear neg;
       if(F > F_target)
           neg = getFalsePositives(neg_dir, max_neg_samples, cascade(1:i));
       end
       disp('Now neg size = ') ; size(neg)
       F = min(1.0, size(neg,2)/max_neg_samples*1.0);
    end
    cascade = cascade(1:i);
    
    function [res] = getFalsePositives(neg_dir, max_elts, cascade) 
        % Run the classifier on images in neg_dir directory, and get
        % subwindows that give false positives into res, at max max_elts
        res = {};
        r_i = 0;
        im_list = dir(neg_dir);
        n_im = length(im_list);
        for i=1:n_im
            if(size(res,2) > max_elts)
                break;
            end
            if(~im_list(i).isdir())
                cur_file = fullfile(neg_dir, im_list(i).name);
                cur_image = imread(cur_file);
                dets = detector(cur_file, cascade);
                for j=1:size(dets, 2)
                    d = dets{j};
                    r_i = r_i + 1;
                    res{r_i} = GetIntegralHoG(imcrop(cur_image, [d(1), d(2), d(3), d(4)]), 9);
                end
            end
        end