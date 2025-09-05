clear; clc;

addpath('scHG');
addpath('finchpp');
addpath('funs');
global p  %balanced

p= 0;%5
k_n=5;%4
same_nn=2;%2


% load dataset
load('./data6/data_sim_new.mat');


n = size(X{1}, 1);
Y = true_label;
c = numel(unique(Y));


% 处理每个矩阵，保留方差最大的前k列
% X = cellfun(@(mat) select_k_columns_by_var(mat, 500), X, 'UniformOutput', false);

% 删除比例为 r 的样本，它们对应的聚类样本数在后r*100%
% [X, Y] = delete_class(X,Y,0.5);
% c = numel(unique(Y));


X = cellfun(@(x) zscore(x, 0, 2), X, 'uni', 0);

As = cellfun(@(x) constructW_PKN(x, 10), X, 'uni', 0); %10



% 固定基础种子（例如 42）
current_seed = 142;

[y_pred, obj, coeff, n_g, y_coar, evaltime] = run_EBMGC_GNF(As, c, true, k_n, same_nn, current_seed);


result = ClusteringMeasure_new(Y, y_pred);
fprintf('time=%f\n', evaltime);
disp(result);


