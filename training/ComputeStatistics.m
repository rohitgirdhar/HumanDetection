function [fpr, dr] = ComputeStatistics(cascade, pos, neg)
    % Returns the FPR and DR for the given positive negative samples using
    % the given cascade
    n_pos = length(pos);
    n_neg = length(neg);
    actual = zeros(1, n_pos + n_neg);
    actual(1:n_pos) = 1;
    
    detected = zeros(1,n_pos+n_neg);
    for i=1:n_pos
        detected(i) = DetectObject(pos{i}, cascade);
    end
    
    for i=1:n_neg
        detected(i + n_pos) = DetectObject(neg{i}, cascade);
    end
    
    fpr = 0;
    dr = 0;
    for i=1:n_pos+n_neg
        if(actual(i) == 1 && detected(i) == 1)
            dr = dr + 1;
        end
        if(actual(i) == 0 && detected(i) == 1)
            fpr = fpr + 1;
        end
    end
    fpr = fpr/(n_neg);
    dr = dr/(n_pos);  