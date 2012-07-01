function [test_data, test_class] = ConvertImageToTest(obj, pos, neg, nbins)
    % This function takes the positive and negative samples and returns the
    % nbins*n vector containing the test data and test classification
    n_pos = length(pos);
    n_neg = length(neg);
    
    test_class = zeros(1, n_pos + n_neg);
    test_data = zeros(n_pos+n_neg, 4*nbins);
    for i=1:n_pos
        test_data(i, :) = ComputeHoG(pos{i}, obj.block_r, obj.block_c, obj.block_h, obj.block_w, nbins);
        test_class(i) = 1;
    end
    for i=1:n_neg
        test_data(i + n_pos, :) = ComputeHoG(neg{i}, obj.block_r, obj.block_c, obj.block_h, obj.block_w, nbins);
        test_class(n_pos + i) = 0;
    end
    