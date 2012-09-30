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
    neg_files = ReadAllImages(neg_dir, 5, 9);
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
    
    
    
    max_stages = 50; % the max number of stages in the cascade
    
    
    cascade(max_stages, 1) = StrongClassifier();
    
    i = 0;  % current stage
    D = 1.0;    % current detection rate (overall)
    F = 1.0;    % current FP rate (overall)
    
    
    
    while(F > F_target && i < max_stages)
       i = i+1;
       if(i > max_stages)
           break;
       end
       d = double(1.0); % The detection rate at this cascade
       
       fprintf('Stage %d, current F = %f\n, current D = %f', i, F, D);
       
       [f,d] = cascade(i,1).learn(pos, neg, pos_val, neg_val, f_max);
       
       F = F*f;
       D = D*d;
       % Now, discard the old neg samples, and use those that were
       % misclassified by the current detector
       %if(F > F_target)
       %    neg = GetDetections(neg_files, cascade(1:i, :));
       %end
    end
    cascade = cascade(1:i);