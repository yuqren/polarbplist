% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name  : nr_rate_matching
% descr : see also the function nrRateMatchPolar in MATLAB

function outE = nrrate_matching(in, N, E, K, nrstep)
outE = zeros(E, nrstep, class(in));

% Bit repetition: Some outputs of the polar encoder kernel are repeated 
%                 in the encoded bit sequence two or more times
if E >= N
    for k = 0 : E - 1
        outE(k+1,:) = in(mod(k, N)+1, :);
    end
else
% Puncturing: Some of the last outputs of the polar encoder kernel 
%             are excluded (excluded bits could have value 0/1)
    if K/E <= 7/16
        outE = in(end-E+1:end, :);
    else
% Shortening: Some of the first outputs of the polar encoder kernel 
%             are excluded (excluded bits are guaranteed to have value 0)
        outE = in(1:E, :);
    end
end
