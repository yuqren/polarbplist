% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name   : graph_select
% descr  : permuted factor graph selection

function graphs = graph_select(N, K, list_num, method)

switch method
    case 'SG'
        if N == 1024 && K == 512
            SGload = load('5G_NR_1024_512_SG_Graphs.mat');
            graphs = SGload.all_graphs(1:list_num, :);

        elseif N == 1024 && K == 256
            SGload = load('5G_NR_1024_256_SG_Graphs.mat');
            graphs = SGload.all_graphs(1:list_num, :);

        elseif N == 1024 && K == 768
            SGload = load('5G_NR_1024_768_SG_Graphs.mat');
            graphs = SGload.all_graphs(1:list_num, :);

        else
            error('None SG graphs for the current code configuration');
        end

    case 'ref'
        all_graphs = perms(log2(N):-1:1);
        graphs     = all_graphs(1:list_num, :);

    otherwise
        error('An undefined PFG selection strategy.');
end