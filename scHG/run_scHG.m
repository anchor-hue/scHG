function [y_pred, obj, coeff, n, y_coar, evaltime] = run_scHG(As, num_clusters, use_grid, k_n, same_nn, current_seed)
    
    if nargin == 6 %
        use_seed = true;
    end
    if nargin < 6
        use_grid = true;
        use_seed = false; %
    end

    if use_grid && use_seed  %
        tic;                                                        %%tic,toc搭配记录时间
        [y_coar, coar_grid_cnt, As_coar] = first_nn_merge(As, k_n ,same_nn, current_seed);%
        evaltime = toc;
        n = size(As_coar{1}, 1);

        Y_init_coar = finchpp(graph_avg(As_coar), num_clusters);

        tic;
        [y_pred, obj, coeff] = scHG(As_coar, Y_init_coar, coar_grid_cnt);
        evaltime = evaltime + toc;
        y_pred = vec2ind(y_pred')';
        y_pred = y_pred(y_coar);
    elseif use_grid
        tic;                                                        %%tic,toc搭配记录时间
        [y_coar, coar_grid_cnt, As_coar] = first_nn_merge(As, k_n ,same_nn);%
        evaltime = toc;
        n = size(As_coar{1}, 1);

        Y_init_coar = finchpp(graph_avg(As_coar), num_clusters);

        tic;
        [y_pred, obj, coeff] = scHG(As_coar, Y_init_coar, coar_grid_cnt);
        evaltime = evaltime + toc;
        y_pred = vec2ind(y_pred')';
        y_pred = y_pred(y_coar);
    else
        y_coar = [];
        n = size(As{1}, 1);
        Y_init = finchpp(graph_avg(As), num_clusters);
        tic;
        [y_pred, obj, coeff] = scHG(As, Y_init);
        evaltime = toc;
        y_pred = vec2ind(y_pred')';
    end
end
