function [total_tp, total_fp, total_fn] = tester(pos_lst, pos_ann_lst, neg_lst, cascade)
    % For every image, compute FP, FN, TP. 
    addpath('PAScode');
    addpath('../training');
    
    
    Fpos = fopen(pos_lst);
    Fann = fopen(pos_ann_lst);
    fname = fgetl(Fpos);
    total_fp = 0.0;
    total_fn = 0.0;
    total_tp = 0.0;
    num_try = 0;
    while(fname ~= -1)
        num_try = num_try + 1
        fname_ann = fgetl(Fann);
        if(exist(fname, 'file') && exist(fname_ann, 'file'))
            A = PASreadrecord(fname_ann);
            num_obj = size(A.objects,2);
            [D, tot_win] = detector(fname, cascade);
            [TP, FP, FN] = count_stat(A, D);
            total_tp = total_tp + TP*1.0/num_obj
            total_fn = total_fn + FN*1.0/num_obj
            total_fp = total_fp + FP*1.0/tot_win
            fname = fgetl(Fpos);
        end
    end 
    Fneg = fopen(neg_lst);
    fname = fgetl(Fneg);
    num_neg = 0;
    while(fname ~= -1)
        num_neg = num_neg+1
        [D,tot_win] = detector(fname, cascade);
        total_fp = total_fp + size(D,2)/tot_win;
        fname = fgetl(Fneg);
    end
    total_tp = total_tp/num_try; % hit rate
    total_fn = total_fn/num_try; % miss rate
    total_fp = total_fp/(num_try+num_neg); % FPPW
    
    
    function [TP,FP,FN] = count_stat(ann, det)
        TP = 0;
        FP = 0;
        FN = 0;
        
        rec = zeros(1,size(det,2));
        for i=1:size(ann.objects,2)
            found = 0;
            for j=1:size(det,2)
                if(compute_overlap(ann.objects(i).bbox, det{j}) >= 0.5)
                    found = 1;
                    rec(j) = 1;
                    break;
                end
            end
            if(found == 1)
                TP = TP+1;
            else
                FN = FN+1;
            end
        end
        FP = size(rec,2) - sum(rec(:));
        
    function ar = compute_overlap(a,b)
        ar = rectint([a(1,1), a(1,2), a(1,3)-a(1,1), a(1,4)-a(1,2)], b);
        ar = ar/(b(1,3)*b(1,4));