# scHG: a supercell framework with high-order graph learning enables hyper-fast multi-omics analysis

Here, we introduce the supercell paradigm, in which expression-coherent cells are compressed into candidate units for rare cell population analysis. Supercells are constructed using angle-aware similarity metrics and second-order co-occurrence neighbors, with impurity cells pruned by degree centrality. To address scalability challenges, we implement sparse matrix optimization and iterative high-order graph updates, enabling efficient integration of large-scale multi-omics datasets. Building on this framework, we develop scHG—a high-order graph learning approach guided by an omics-weighted optimizer that adaptively balances contributions from gene expression, surface proteins, and chromatin accessibility.

The Python version of scHG can be downloaded via the link: https://github.com/anchor-hue/scHG_Python.

## Project Structure

```
scHG/
├── 📄 README.md                    # Project documentation
├── 📄 demo.m                      # Complete workflow demonstration
├── 📁 data6/                      # Example datasets (5 .mat files)
│   ├── data_mESC_my.mat          
│   ├── data_sim_new.mat          
│   ├── pbmc_10x.mat             
│   ├── pbmc_8185.mat             
│   └── pbmc_inhouse_new.mat      
├── 📁 finchpp/                   # FINCH initialization module
│   ├── finchpp.m                 # Public interface
│   └── private/                  # Internal implementation (5 files)
├── 📁 funs/                      # Utility functions (6 files)
│   ├── ClusteringMeasure_new.m   # Performance evaluation
│   ├── constructW_PKN.m          # Similarity matrix construction
│   ├── delete_class.m            # Class balance adjustment
│   ├── same_edge_precision.m     # Precision utility
│   ├── select_k_columns_by_var.m # Feature selection
│   └── struct_gn.m               # Graph structure utility
└── 📁 scHG/                      # Core algorithm module
    ├── run_scHG.m                # Main wrapper function
    ├── scHG.m                    # Core iterative algorithm
    └── private/                  # Auxiliary functions (7 files)
        ├── calc_laps.m           # Graph Laplacian calculation
        ├── calc_view_objs.m      # View objective calculation
        ├── first_nn_merge.m      # Supercell Graph coarsening
        ├── graph_avg.m           # Graph averaging
        ├── solve_Y.m             # Cluster assignment update
        ├── struct_nn.m           # Neural network structure
        └── weighted_sum.m        # Weighted graph combination
```
For the BMCITE dataset, it can be downloaded via the link: http://mialab.ruc.edu.cn/scHG_code/zip
## Quick Start

### Prerequisites

Before using scHG, ensure the following environment is configured:

- **MATLAB** - The algorithm is fully implemented in MATLAB
- Data Format
  - Input data should include:
    - Cell sample labels
    - Multi-omics expression matrices

### Project Setup

First, clone or download the repository and configure your MATLAB environment.

To configure your MATLAB environment, add the required paths to your workspace:

```MATLAB
addpath('scHG');      % Core scHG algorithm
addpath('finchpp');    % FINCH initialization
addpath('funs');       % Utility functions
```

### Step-by-Step Tutorial

Follow these steps to run scHG on your own dataset:

#### Step 1: Load and Preprocess Data

Load your multi-omics data, where each omics view represents distinct expression features:

```MATLAB
% Load dataset (e.g., single-cell data with multiple omics)
load('./data6/data_sim_new.mat');
 
n = size(X{1}, 1);        % Number of samples
Y = true_label;           % Ground truth labels
c = numel(unique(Y));     % Number of clusters
```

Normalize each omics view using z-score standardization to ensure comparability:

```MATLAB
X = cellfun(@(x) zscore(x, 0, 2), X, 'uni', 0);
```

#### Step 2: Construct Similarity Matrices

Build similarity matrices for each omics view using Probabilistic K-Nearest Neighbors (PKN):

```MATLAB
As = cellfun(@(x) constructW_PKN(x, 10), X, 'uni', 0);
```

The PKN method creates sparse similarity matrices where each sample is connected to its k (tunable) nearest neighbors. Similarity weights are calculated based on local distance distributions, ensuring parameter-free and distance-consistent similarity measurement.

#### Step 3: Configure Parameters

Set key parameters for the clustering algorithm:

| Parameter      | Description                                      | Default Value |
| -------------- | ------------------------------------------------ | ------------- |
| `p`            | Global balance parameter for clustering control  | 0             |
| `k_n`          | Supercell construction hyperparameter $$\alpha$$ | 5             |
| `same_nn`      | Supercell construction hyperparameter $$\beta$$  | 2             |
| `current_seed` | Random seed for reproducibility                  | 142           |

```MATLAB
global p  % Define global parameter for balanced clustering
p = 0;           % Balanced parameter (0 = no balance constraint)
k_n = 5;         % Supercell construction hyperparameter α
same_nn = 2;     % Supercell construction hyperparameter β
current_seed = 142;  % Random seed for reproducibility
```

#### Step 4: Run Clustering Algorithm

Execute the main scHG clustering pipeline with configured parameters:

```MATLAB
[y_pred, obj, coeff, n_g, y_coar, evaltime] = run_scHG(As, c, true, k_n, same_nn, current_seed);
```

This function returns multiple outputs:

- `y_pred`: Predicted cluster labels for all samples
- `obj`: Objective function values across iterations
- `coeff`: View importance weights (higher value = more important view)
- `n_g`: Number of supercells
- `y_coar`: Cell-to-supercell mapping labels
- `evaltime`: Total execution time

#### Step 5: Evaluate Results

Assess clustering quality using standard metrics:

```MATLAB
result = ClusteringMeasure_new(Y, y_pred);
fprintf('time=%f\n', evaltime);
disp(result);
```


The evaluation includes multiple metrics such as Accuracy (ACC), Normalized Mutual Information (NMI), Purity, F-score (F), Precision (P), Recall (R), Rand Index (RI), and Adjusted Rand Index (ARI).
