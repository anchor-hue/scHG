function [y, cnt, coarsened]= first_nn_merge(As , k_n ,same_nn, seed)
    

    if nargin == 4 %
        use_seed = true;
    end
    if nargin < 4 %
        use_seed = false; 
    end
    
    if use_seed
        % 保存当前随机状态
        original_rng = rng();
        rng(seed, 'twister');
        num_views = numel(As);
        n = size(As{1}, 1);
        
        As2 = cellfun(@(A) spdiags(sparse(n, 1), 0, A), As, 'UniformOutput', false); 
        [~, first_gns] = cellfun(@(A) maxk(A , k_n , 2), As, 'UniformOutput', false);         
        G_first_gns = cellfun(@(first_gn) struct_gn(first_gn, same_nn), ...
              first_gns, 'UniformOutput', false);
       
     
        G_shared_first_gn = sparse(n, n);
        for v = 1:num_views
            G_shared_first_gn = G_shared_first_gn + G_first_gns{v};
        end
        G_shared_first_gn = G_shared_first_gn >= fix(num_views / 2) + 1;
        G_shared_first_gn = G_shared_first_gn + G_shared_first_gn';  
    
    %     [~, y] = graphconncomp(G_shared_first_gn, 'Directed', false);
        
        % 假设 G_shared_first_gn 是一个邻接矩阵
        G_shared_first_gn = graph(G_shared_first_gn); % 转换为无向图对象
        % 调用 conncomp
        y = conncomp(G_shared_first_gn, 'OutputForm', 'vector');
%         y_before = conncomp(G_shared_first_gn, 'OutputForm', 'vector');
    
        
        %%%%%%%%%%
        % 处理每个连通分量中的节点
        unique_labels = unique(y);
        current_max = max(y);
%         super_num = length(unique_labels); %
        
        for i = 1:length(unique_labels)
            c = unique_labels(i);
            nodes = find(y == c); % 当前连通分量的节点索引
            
            if length(nodes) <= 1
                continue; % 跳过单个节点的连通分量
            end
            
            % 提取子图并计算度中心性（基于连通分量内部）
            sub_g = subgraph(G_shared_first_gn, nodes);
    %         s = degree(sub_g); 
            s = centrality(sub_g,'degree');
            
            % 计算移出概率（中心性越低概率越高）
            min_s = min(s);
            max_s = max(s);
            if max_s == min_s
                pro = zeros(size(s));
            else
                pro = 1 - (s - min_s) / (max_s - min_s); % 归一化反转概率
            end
            
%             % ========= 中位数调整 =========
%             median_p = median(p);
%             p(p > median_p) = p(p > median_p) * 2; %可能超过1
%             p(p <= median_p) = p(p <= median_p) * 0.5;
%             % ========================================

            % 对每个节点独立判断是否移出
            for j = 1:length(nodes)
                if rand() < pro(j)
                    current_max = current_max + 1;
                    y(nodes(j)) = current_max; % 移出节点赋予新标签
%                     super_num = super_num + 1; % 超节点数量+1
                end
            end
        end

%         fprintf('supernode_num=%f\n',super_num);

        
        
        % 确保标签是连续整数（可选）
%         [~, ~, y] = unique(y);
%         y = y';
        %%%%%%%%%%%
    
        Y = ind2vec(y);
        cnt = full(sum(Y, 2));  %每一类的数目
        coarsened = cellfun(@(A) Y * A * Y', As, 'UniformOutput', false);
        y = y';
    
         % 恢复原始随机状态
        rng(original_rng);
    

    else
        num_views = numel(As);
        n = size(As{1}, 1);
        
        As2 = cellfun(@(A) spdiags(sparse(n, 1), 0, A), As, 'UniformOutput', false); 
        [~, first_gns] = cellfun(@(A) maxk(A , k_n , 2), As, 'UniformOutput', false);         
        G_first_gns = cellfun(@(first_gn) struct_gn(first_gn, same_nn), ...
              first_gns, 'UniformOutput', false);
       
     
        G_shared_first_gn = sparse(n, n);
        for v = 1:num_views
            G_shared_first_gn = G_shared_first_gn + G_first_gns{v};
        end
        G_shared_first_gn = G_shared_first_gn >= fix(num_views / 2) + 1;
        G_shared_first_gn = G_shared_first_gn + G_shared_first_gn';  
    
    %     [~, y] = graphconncomp(G_shared_first_gn, 'Directed', false);
        
        % 假设 G_shared_first_gn 是一个邻接矩阵
        G_shared_first_gn = graph(G_shared_first_gn); % 转换为无向图对象
        % 调用 conncomp
        y = conncomp(G_shared_first_gn, 'OutputForm', 'vector');

        %%%%%%%%%%
        % 处理每个连通分量中的节点
        unique_labels = unique(y);
        current_max = max(y);
        
        for i = 1:length(unique_labels)
            c = unique_labels(i);
            nodes = find(y == c); % 当前连通分量的节点索引
            
            if length(nodes) <= 1
                continue; % 跳过单个节点的连通分量
            end
            
            % 提取子图并计算度中心性（基于连通分量内部）
            sub_g = subgraph(G_shared_first_gn, nodes);
    %         s = degree(sub_g); 
            s = centrality(sub_g,'betweenness');
            
            % 计算移出概率（中心性越低概率越高）
            min_s = min(s);
            max_s = max(s);
            if max_s == min_s
                pro = zeros(size(s));
            else
                pro = 1 - (s - min_s) / (max_s - min_s); % 归一化反转概率
            end
            
            % 对每个节点独立判断是否移出
            for j = 1:length(nodes)
                if rand() < pro(j)
                    current_max = current_max + 1;
                    y(nodes(j)) = current_max; % 移出节点赋予新标签
                end
            end
        end
        
        % 确保标签是连续整数（可选）
%         [~, ~, y] = unique(y);
%         y = y';
        %%%%%%%%%%%

        Y = ind2vec(y);
        cnt = full(sum(Y, 2));  %每一类的数目
        coarsened = cellfun(@(A) Y * A * Y', As, 'UniformOutput', false);
        y = y';
    end



    
end
