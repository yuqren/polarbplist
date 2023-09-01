% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name   : subRouting
% descr  : functions for algorithm 2

function V = subRouting(V, Vset, s, e)
    if s < e
        for i = s:1:e-1
            V = V(1, Vset(:, i));
        end
    else
        for i = s-1:-1:e
            V = V(1, Vset(:, i));
        end
    end  
end