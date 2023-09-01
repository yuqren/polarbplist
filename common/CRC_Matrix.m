% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name  : CRC_Matrix
% descr : generate the gen matrix and check matrix

function [G, H] = CRC_Matrix(K, poly)
K        = gather(K);
glen     = size(poly, 2);
P_matrix = zeros(K, glen-1);

for i = 1:1:K
    data      = zeros(1,K-i+glen);
    data(1,1) = 1;
    cr = data(1:glen-1);
    for p = glen:length(data)
        cr(glen) = data(p); % recursive
        if cr(1)
            cr = xor(cr(2:glen), poly(2:glen)); %xor
        else
            cr = cr(2:glen);
        end
    end
    P_matrix(i,:) = cr;
end

G = [eye(K, K) P_matrix]';
P_matrix_tran = P_matrix';
H = [P_matrix_tran eye(glen-1,glen-1)];
end

