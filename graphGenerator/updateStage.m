% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name   : updateStage
% descr  : functions for algorithm 2

function out = updateStage(in,s,e)
    if (in == s)
        out = e;
    elseif (in >= min(s, e) && in <= max(s, e) && s ~= e)
        if (s > e)
            out = in + 1;
        elseif (s < e)
            out = in - 1;
        end
    else
        out = in;
    end
end