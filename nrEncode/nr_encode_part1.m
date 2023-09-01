% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name  : nrpolar_encode_part1
% descr : generate the nrpolar construction and necessary information

function [N, F, I, input_IL, sb_IL, IL, IB] = nr_encode_part1(E, K, link_mode)
% -----------------------------------------------------------------------------------------------------------
% generate N
% -----------------------------------------------------------------------------------------------------------
if link_mode == 1
    nMax = 9;
else
    nMax = 10;
end
N = nr5g.internal.polar.getN(K, E, nMax);

% -----------------------------------------------------------------------------------------------------------
% generate IL and IB
% -----------------------------------------------------------------------------------------------------------
if link_mode == 1
    IL = 1; IB = 0;
else
    IL = 0; IB = 1;
end

% -----------------------------------------------------------------------------------------------------------
% generate the pc bits
% -----------------------------------------------------------------------------------------------------------
if (K >= 18 && K <= 25) % for PC-Polar, Section 6.3.1.3.1
    nPC = 3;
else
    nPC = 0;
end

% -----------------------------------------------------------------------------------------------------------
% input information interleave for downlink
% -----------------------------------------------------------------------------------------------------------
input_IL = nr5g.internal.polar.interleaveMap(K); % note that index starts from 0

% -----------------------------------------------------------------------------------------------------------
% sub block interleave
% -----------------------------------------------------------------------------------------------------------
sb_IL = nr5g.internal.polar.subblockInterleaveMap(N); % note that index starts from 0

% -----------------------------------------------------------------------------------------------------------
% subchannel allocation
% -----------------------------------------------------------------------------------------------------------
subchannel_allocation = nr5g.internal.polar.sequence;
qSeq = subchannel_allocation(subchannel_allocation < N); % note that index starts from 0

% -----------------------------------------------------------------------------------------------------------
% generate the frozen set qF and information set qI
% -----------------------------------------------------------------------------------------------------------
qFtmp = [];
if E < N
    % puncturing [low code rate, extra frozen bits at the beginning]
    if K/E <= 7/16
        for i = 0:(N-E-1)
            qFtmp = [qFtmp; sb_IL(i+1)];
        end
        if E >= 3*N/4
            uLim  = ceil(3*N/4-E/2);
            qFtmp = [qFtmp; (0:uLim-1).'];
        else
            uLim  = ceil(9*N/16-E/4);
            qFtmp = [qFtmp; (0:uLim-1).'];
        end
        qFtmp = unique(qFtmp);
        % shortening [high code rate, extra frozen bits at the end]
    else
        for i = E:N-1
            qFtmp = [qFtmp; sb_IL(i+1)];
        end
    end
end
% get qI from qFtmp and qSeq
qI = zeros(K + nPC,1);
j = 0;
for i = 1:N
    idx = qSeq(N - i + 1);      % flip for most reliable
    if any(idx == qFtmp)
        continue;
    end
    j = j + 1;
    qI(j) = idx;
    if j == (K + nPC)
        break;
    end
end
% generate F and I
qF = setdiff(qSeq,qI);
F = false(N,1);
F(qF + 1) = ones(length(qF), 1); % 1 shows the frozen bit locations
I = not(F);
end