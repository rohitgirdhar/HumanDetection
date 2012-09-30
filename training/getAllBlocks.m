function [R] = getAllBlocks()
    % Returns a list of all possible blocks in 64x128 image
    
    HT = 128;
    WD = 64;
    cnt = 1;
    R = zeros(100000,4);
    for stride = 4:2:8
        for r = 1:stride:HT-4
            for c=1:stride:WD-4
                for wid = 4:4:WD-c
                    for rat = [0.5 1 2]
                        ht = wid*rat;
                        if(r+ht <= HT && c+wid <= WD)
                            R(cnt,:) = [r c ht wid];
                            cnt = cnt+1;
                        end
                    end
                end
            end
        end
    end
    R = R(1:cnt-1,:);
    