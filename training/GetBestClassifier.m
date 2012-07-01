function [best, wts] = GetBestClassifier(lst, pos, neg, wts, nbins)
    % This runs all the classifiers in lst on pos and neg samples,
    % calculate the error and returns the best classifier, with new weights
    
    n_clsr = length(lst);
    min_err = 99999999;
    best = 0;
    error_val = zeros(n_clsr, 1);
    error_occ = zeros(n_clsr, length(pos) + length(neg));
    for i = 1:n_clsr
        [test_data, test_class] = ConvertImageToTest(lst(i), pos, neg, nbins);
        output = svmclassify(lst(i).classifier, test_data);
        % calculte error
        err = 0;
        
        for j=1:length(output)
            e = double(wts(j))*double(abs(output(j)-test_class(j)));
            err = err + e;
            error_occ(i, j) = abs(output(j)-test_class(j));
            if(err < min_err)
                min_err = err;
                best = i;
            end
        end
        error_val(j,1) = err;
    end
    ep = double(err(best,1));
    beta = ep/(1-ep);
    for j=1:length(output)
        if(~error_occ(best, j) == 1)
            wts(j) = wts(j)*beta;
        end
    end
    
    best = lst(best);
