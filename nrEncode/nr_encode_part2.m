% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name  : nrpolar_encode_part2
% descr : finish the rating matching, all interleave operations, and channel transmission

function [info_with_crc, bpskN, noiseN] = nr_encode_part2(N, E, K, crc_len, G, Gn, info_bits, input_IL, sb_IL, IL, IB, simstep)
% source bits generation
info  = rand(K - crc_len, simstep) > 0.5;
if IL == 1
    info_with_crc = mod(G*[ones(crc_len, simstep); info], 2); % initial value is 1 at PDCCH
    info_with_crc = info_with_crc(crc_len+1:end, :); % discard the first crc_len bits
else
    info_with_crc = mod(G*info, 2);
end

% input bits interleave
if IL == 1
    info_with_crc = info_with_crc(input_IL+1,:);
end

% non-systematic codes
u = zeros(N, simstep);
u(info_bits,:) = info_with_crc;
x = mod(Gn*u,2);

% sub-block interleaver
x = x(sb_IL+1, :);

% channel interleave
if IB == 1 % horizontal writing and vertical reading
    T = ceil((sqrt(8*N+1)-1)/2);
    channel_interleaver1 = zeros(T,T,simstep);
    k = 1;
    for i = 1:1:T
        for j = 1:1:T-i+1
            if k <= N
                channel_interleaver1(i,j,:) = x(k,:);
            else
                channel_interleaver1(i,j,:) = NaN;
            end
            k = k+1;
        end
        for j = T-i+2:T
            channel_interleaver1(i,j,:) = NaN;
        end
    end
    k = 1;
    for j = 1:1:T
        for i = 1:1:T
            if ~isnan(channel_interleaver1(i,j,1))
                x(k,:) = channel_interleaver1(i,j,:);
                k = k+1;
            end
        end
    end
end

% rate-matching
xE = nrrate_matching(x, N, E, K, simstep);

% white gaussion noise
noiseE = randn(E, simstep);

% AWGN transmission
bpskE = 1 - 2 * xE;

% rate-recovery
[bpskN, noiseN] = nrrate_recovery(bpskE, noiseE, N, E, K, simstep);

% channel de-interleaver
if IB == 1 % vertical writing and horizontal reading
    k = 1;
    %channel_interleaver1 = zeros(T,T,nrstep);
    channel_interleaver2 = zeros(T,T,simstep);
    for j = 1:1:T
        for i = 1:1:T
            if ~isnan(channel_interleaver1(i,j,1))
                
                channel_interleaver1(i,j,:) = bpskN(k,:);
                channel_interleaver2(i,j,:) = noiseN(k,:);
                k = k+1;
            end
        end
    end
    k = 1;
    for i = 1:1:T
        for j = 1:1:T
            if ~isnan(channel_interleaver1(i,j,1))
                bpskN(k,:) = channel_interleaver1(i,j,:);
                noiseN(k,:) = channel_interleaver2(i,j,:);
                k = k+1;
            end
        end
    end
end

% sub-block de-interleave
bpskN(sb_IL+1,:) = bpskN;
noiseN(sb_IL+1,:) = noiseN;

end