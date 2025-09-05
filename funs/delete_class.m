function [X_processed,Y_processed] = delete_class(X,Y,r)
    % 假设X是包含多个矩阵的cell数组，Y是类别标签向量
    
    % 1. 统计每个类别的样本数
    [unique_classes, ~, class_labels] = unique(Y);
    class_counts = accumarray(class_labels, 1); % 每个类别的样本数
    
    % 2. 按样本数排序，确定要删除的类别（后20%的类别数目）
    [sorted_counts, sort_idx] = sort(class_counts); % 升序排列
    sorted_classes = unique_classes(sort_idx);       % 对应的类别标签
    num_classes = numel(sorted_counts);              % 总类别数
    num_remove = round(r * num_classes);           % 计算要删除的类别数目
    
    % 3. 确定需要删除的类别
    if num_remove > 0
        classes_to_remove = sorted_classes(1:num_remove); % 样本数最少的num_remove个类别
    else
        classes_to_remove = [];
    end
    
    % 4. 生成逻辑掩码，保留有效样本
    mask = ~ismember(Y, classes_to_remove); % 非待删除类别的样本位置为true
    
    % 5. 处理数据
    Y_processed = Y(mask); % 删除无效样本的类别标签
    X_processed = cellfun(@(x) x(mask, :), X, 'UniformOutput', false); % 删除无效样本的特征
end

