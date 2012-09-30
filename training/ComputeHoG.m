function block_hist = ComputeHoG(ii, r, c, h, w, nbins)
    % Returns the 1x(nbins*4) vector of HoG for the given block in given integral
    % image (zero padded)
    
    block_hist = zeros(1,nbins*4);
    % first divide the block into 2x2 cells, compute the 9D histogram
    % for each, and concat to get 36D vector
    mid_r = uint32(r+h/2);
    mid_c = uint32(c+w/2);
    cell_hist = zeros(1,nbins);
    cell_hist(:) = getHistogram(ii, r, c, mid_r-1, mid_c-1);
    block_hist(1:nbins) = cell_hist(:);
    cell_hist(:) = getHistogram(ii, mid_r, c, r+h-1, mid_c-1);
    block_hist(nbins+1:2*nbins) = cell_hist(:);
    cell_hist(:) = getHistogram(ii, mid_r, mid_c, r+h-1, c+w-1);
    block_hist(2*nbins+1:3*nbins) = cell_hist(:);
    cell_hist(:) = getHistogram(ii, r, mid_c-1, mid_r-1, c+w-1);
    block_hist(3*nbins+1:4*nbins) = cell_hist(:);
    
    function hist = getHistogram(ii, sx, sy, ex, ey)
        % returns a 1*nbins vector with the histogram for that cell
        sx = sx+1;sy = sy+1; ex = ex+1;ey = ey+1;
        nbins = size(ii,3);
        hist = zeros(1,nbins);
        for bin=1:nbins    
            hist(1, bin) = ii(ex, ey, bin) + ii(sx-1, sy-1, bin) - ii(sx-1, ey, bin) - ii(ex, sy-1, bin);
        end

    
