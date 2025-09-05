% 定义辅助函数
function mat_out = select_k_columns_by_var(mat_in, k)
    variances = var(mat_in); % 计算各列的方差（样本方差，使用n-1归一化）
    [~, sorted_idx] = sort(variances, 'descend'); % 按方差降序排序，获取索引
    top_k_idx = sorted_idx(1:min(k, end)); % 防止k超过列数
    mat_out = mat_in(:, top_k_idx); % 提取方差最大的前k列
end