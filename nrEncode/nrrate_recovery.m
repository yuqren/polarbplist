% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name  : nr_rate_recovery
% descr : see also the function nrRateRecoverPolar in MATLAB

function [llrN, noiseN] = nrrate_recovery(llrE, noiseE, N, E, K, nrstep)
% Bit repetition: Some outputs of the polar encoder kernel are repeated in the encoded bit
% sequence two or more times --> Add together LLRs which representent repeated outputs
if E >= N
    llrN = llrE(1:N, :);
    noiseN = noiseE(1:N, :);
    for k = N:E - 1
        llrN(mod(k, N)+1, :) = llrN(mod(k, N)+1, :) + llrE(k+1, :);
        noiseN(mod(k, N)+1, :) = noiseN(mod(k, N)+1, :) + noiseE(k+1, :);
    end
    
% Puncturing: Some of the last outputs of the polar encoder kernel are excluded (excluded bits
%             could have value 0/1) --> Add 0s for punctures at the end as they could be either 0 or 1
else
    if K/E <= 7/16
        llrN = zeros(N, nrstep, class(llrE));
        noiseN = zeros(N, nrstep, class(noiseE));

        llrN(end-E+1:end, :) = llrE;
        noiseN(end-E+1:end, :) = noiseE;
        
% Shortening: Some of the first outputs of the polar encoder kernel are excluded (excluded bits
%             are guaranteed to have value 0) --> Add large values for 0s at the start for LLRs
    else
        llrN = Inf*ones(N, nrstep, class(llrE));
        noiseN = zeros(N, nrstep, class(noiseE));

        llrN(1:E, :) = llrE;
        noiseN(1:E, :) = noiseE;
    end
end