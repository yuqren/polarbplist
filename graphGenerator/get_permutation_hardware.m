% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name   : get_permutation_hardware
% descr  : generate codeword permutations (routings) in a low-complexity matrix decomposition fashion for hardware
% refer  : Y. Ren, et al, 'High-Throughput Flexible Belief Propagation List Decoder for Polar Codes', 
%          arXiv preprint arXiv:2210.13887, 2022

function [graphs_pos, graphs_inv, s_vec] = get_permutation_hardware(PFG, list_num, N, n)

% parameters
graphs_pos = zeros(N, list_num);
graphs_inv = zeros(N, list_num);
s_vec      = zeros(n, list_num);

% initialization
data = load('Vset_4096.mat');
Vset = data.Vset_4096(1:N, 1:n-1); % initial set (we use the recursive property)
OFG  = 1:1:n;                      % original factor graph               

% algorithm 2: generation of permutations by a matrix decomposition
for p = 1:1:list_num
    bit_order = 0:1:N-1;

    % phase 1: generate Vπ
    for i = 1:1:n
        s = PFG(p,i); % current column
        e = OFG(1,i);     % aimed column
        % update PFG by Vs,e
        for j = i+1:1:n
            PFG(p,j) = updateStage(PFG(p,j),s,e);
        end
        s_vec(i, p) = s;
    end

    % phase 2: execute Vπ
    for i = 1:1:n
        [bit_order] = subRouting(bit_order, Vset, PFG(p,i), OFG(1,i));
    end

    graphs_pos(:, p) = bit_order';
end

% inverse operation
for p = 1:1:list_num
    bit_order = 0:1:N-1;

    for i = n:-1:1
        [bit_order] = subRouting(bit_order, Vset, OFG(1,i), PFG(p,i));
    end

    graphs_inv(:, p) = bit_order';
end

end
