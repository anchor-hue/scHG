% construct similarity matrix with probabilistic k-nearest neighbors. It is a parameter free, distance consistent similarity.
function W = constructW_PKN(X, k, issymmetric)
% X: each column...x...row is a data point
% k: number of neighbors
% issymmetric: set W = (W+W')/2 if issymmetric=1
% W: similarity matrix

if nargin < 3
    issymmetric = 1;
end
if nargin < 2
    k = 5;
end

% n = size(X, 1);
% D = squareform(pdist(X, 'squaredeuclidean'));
% 
% W = sparse(n, n);
% 
% [D, idx] = mink(D, k + 2, 2);
% D = D(:, 2:end);
% idx = idx(:, 2:end);
% 
% row = repmat(1:n, 1, k);
% col = reshape(idx(:, 1:k), 1, []);
% ind = sub2ind(size(W), row, col);
% 
% % W(ind) = (D(:, k + 1) - D(:, 1:k)) ./ (k * D(:, k + 1) - sum(D(:, 1:k), 2));
% W(ind) = (D(:, k + 1) - D(:, 1:k)) ./ (k * D(:, k + 1) - sum(D(:, 1:k), 2) + eps);
% 
% if issymmetric == 1
%     W = (W+W')/2;



n = size(X, 1);
% 计算PCC矩阵并转换为线性感知度量
PCC_matrix = corr(X', 'type', 'Pearson');
D = 1 - PCC_matrix; % 新的度量L=1-PCC

% 处理可能的NaN值（例如方差为零的情况）
D(isnan(D)) = 1; % 假设无线性关系

W = sparse(n, n);

% 寻找每个点的k+2个最近邻（包含自身）
[D_sorted, idx] = mink(D, k + 2, 2);
D_sorted = D_sorted(:, 2:end); % 排除自身
idx = idx(:, 2:end);

% 构建稀疏矩阵索引
row = repmat((1:n)', 1, k);
col = idx(:, 1:k);
linear_ind = sub2ind([n, n], row(:), col(:));

% 计算权重（基于局部距离分布）
k_neighbor_dist = D_sorted(:, 1:k);
sigma = D_sorted(:, k+1); % 第k+1近邻的距离
numerator = sigma - k_neighbor_dist;
denominator = k * sigma - sum(k_neighbor_dist, 2) + eps;
weights = numerator ./ denominator;

W(linear_ind) = weights(:);

% 对称化处理
if issymmetric
    W = (W + W') / 2;


end
