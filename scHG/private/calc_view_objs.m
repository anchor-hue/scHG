function objs = calc_view_objs(Ls, Y, grid_cnt)
     
    global p                   
      
    if isempty(grid_cnt)
        n = size(Y, 1);
        n_grid = full(sum(Y)');
    else
        n = sum(grid_cnt);
        n_grid = Y' * grid_cnt;
    end
    

        yyn = 1 ./ ( n_grid .^p);                         

    

%     disp('Checking L:');
%     disp(any(isnan(Ls))); % 检查 L 是否包含 NaN
%     disp(any(isinf(Ls))); % 检查 L 是否包含 Inf
    
%     disp('Checking Y:');
%     disp(any(isnan(Y))); % 检查 Y 是否包含 NaN
%     disp(any(isinf(Y))); % 检查 Y 是否包含 Inf
    
%     disp('Checking L * Y:');
%     result = full(L * Y);
%     disp(any(isnan(result))); % 检查 L * Y 是否包含 NaN
%     disp(any(isinf(result))); % 检查 L * Y 是否包含 Inf
    
%     disp('Checking yyn:');
%     disp(isnan(yyn)); % 检查 yyn 是否为 NaN
%     disp(yyn == 0);   % 检查 yyn 是否为 0


    objs = cellfun(@(L) vecnorm(full(L * Y), 1) * yyn, Ls);
    objs = sqrt(objs)';
end
