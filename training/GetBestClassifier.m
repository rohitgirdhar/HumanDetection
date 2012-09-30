function [best, wts, alpha] = GetBestClassifier(lst, pos, neg, wts, nbins)
    % This runs all the classifiers in lst on pos and neg samples,
    % calculate the error and returns the best classifier, with new weights
    
    n_clsr = length(lst);
    min_err = 99999999;
    best = 1;
    wts = double(wts);
    error_val = zeros(n_clsr, 1);
    error_occ = zeros(n_clsr, length(pos) + length(neg));
    for i = 1:n_clsr
        [test_data, test_class] = ConvertImageToTest(lst(i), pos, neg, nbins);
        output = svmclassify(lst(i).classifier, test_data);
        % calculte error
        err = 0.0;
        
        for j=1:length(output)
            e = double(wts(j))*double(abs(output(j)-test_class(j)));
            err = err + e;
            error_occ(i, j) = abs(output(j)-test_class(j));
            
        end
        error_val(j,1) = double(err);
        if(err < min_err)
            min_err = err;
            best = i;
        end
    end
    
    ep = double(min_err);
    beta = ep/(1-ep);
    for j=1:length(output)
        if(error_occ(best, j) == 0)
            wts(j) = wts(j)*beta;
        end
    end
    
    best = lst(best);
    alpha = log(1.0/beta);
