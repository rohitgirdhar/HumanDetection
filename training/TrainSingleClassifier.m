function clsr = TrainSingleClassifier(r, c, h, w, pos, neg, nbins)
    % Returns a SVMStruct after training for a specific
    % block given by r,c,w,h on pos, neg samples
    n_pos = length(pos);
    n_neg = length(neg);
    train_data = zeros(n_pos+n_neg, nbins*4);
    train_class = zeros(n_pos+n_neg, 1);
    for img = 1:n_pos
        train_data(img, :) = ComputeHoG(pos{img},r,c,h,w, nbins);
        train_class(img, 1) = 1;
    end
    
    for img = 1:n_neg
        train_data(n_pos+img, :) = ComputeHoG(neg{img},r,c,h,w, nbins);
        train_class(n_pos+img, 1) = 0;
    end
    
    clsr = svmtrain(train_data, train_class, 'method', 'LS');