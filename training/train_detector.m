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
    neg_files = ReadAllImages(neg_dir, 10, 9);
    n_neg = length(neg_files);
    
    nbins = 9;
    
    % Now divide into training and validation
    train_files_perc = 0.66;
    lim = uint32(train_files_perc*n_pos);
    n_pos = lim;
    pos = pos_files(1:lim);
    pos_val = pos_files(lim+1:n_pos);
    
    lim = uint32(train_files_perc*n_neg);
    neg = neg_files(1:lim);
    n_neg = lim;
    neg_val = neg_files(lim+1:n_neg);
    
    
    
    max_stages = 200; % the max number of stages in the cascade
    max_classifiers = 200; % Max num of classifiers at each stage
    
    cascade(max_stages, max_classifiers) = LinearSVMClassifierHoG();
    
    i = 0;  % current stage
    D = 1.0;    % current detection rate (overall)
    F = 1.0;    % current FP rate (overall)
    wts = zeros(1, n_pos + n_neg);
    wts(1:n_pos) = 1.0/(2.0*double(n_pos));
    wts(n_pos+1:n_pos + n_neg) = 1.0/(2.0*double(n_neg));
    while(F > F_target && i < max_stages)
       i = i+1;
       f = 1.0; % The FP rate at this cascade
       d = 1.0; % The detection rate at this cascade
       j = 0; % The number of classifier at this stage
       disp(['Training stage ', int2str(i), '. Current FPR:', int2str(F)]);
       while(f > f_max && j < max_classifiers)
           j = j+1;
           classifiers_list = TrainClassifiers(250, pos, neg, nbins);
           [best_classifier, wts] = GetBestClassifier(classifiers_list, pos, neg, wts, nbins)
           cascade(i,j) = best_classifier;  
           % NOTE: Did not implement lowering of thresholds
           % compute the false positive rate and detection rate for the current stage, as
           % far it has been trained
           [f,d] = ComputeStatistics(cascade(i, 1:j), pos_val, neg_val, 'FPR', 'DR');
       end
       F = F*f;
       D = D*d;
       % Now, discard the old neg samples, and use those that were
       % misclassified by the current detector
       if(F > F_target)
           misclassed = GetDetections(neg_files, cascade(1:i, :));
           clearvars neg;
       end
       neg = misclassed;
    end