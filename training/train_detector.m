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
    n_pos = lim;
    n_pos_val = total_pos - n_pos;
    pos = pos_files(1:lim);
    pos_val = pos_files(lim+1:total_pos);
    
    total_neg = n_neg;
    lim = uint32(train_files_perc*n_neg);
    neg = neg_files(1:lim);
    n_neg = lim;
    n_neg_val = total_neg - n_neg;
    neg_val = neg_files(lim+1:total_neg);
    
    
    
    max_stages = 200; % the max number of stages in the cascade
    max_classifiers = 200; % Max num of classifiers at each stage
    
    cascade(max_stages, max_classifiers) = LinearSVMClassifierHoG();
    
    i = 0;  % current stage
    D = 1.0;    % current detection rate (overall)
    F = 1.0;    % current FP rate (overall)
    
    wts = zeros(1, n_pos_val + n_neg_val);
    wts(1:n_pos_val) = 1.0/(2.0*double(n_pos_val));
    wts(n_pos_val+1:n_pos_val + n_neg_val) = 1.0/(2.0*double(n_neg_val));
    
    while(F > F_target && i < max_stages)
       i = i+1;
       f = double(1.0); % The FP rate at this cascade
       d = double(1.0); % The detection rate at this cascade
       j = 0; % The number of classifier at this stage
       fprintf('Stage %d, current F = %f\n, current D = %f', i, F, D);
       while(f > f_max && j < max_classifiers)
           j = j+1;
           classifiers_list = TrainClassifiers(400, pos, neg, nbins);
           [best_classifier, wts] = GetBestClassifier(classifiers_list, pos_val, neg_val, wts, nbins);
           best_classifier
           cascade(i,j) = best_classifier;  
           % NOTE: Did not implement lowering of thresholds
           % compute the false positive rate and detection rate for the current stage, as
           % far it has been trained
           [f,d] = ComputeStatistics(cascade(i, :), pos, neg)
       end
       F = F*f;
       D = D*d;
       % Now, discard the old neg samples, and use those that were
       % misclassified by the current detector
       if(F > F_target)
           neg = GetDetections(neg_files, cascade(1:i, :));
       end
    end