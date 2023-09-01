% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name   : simulation_based_bp
% descr  : decoding with bp series algorithms

function [fer, iter] = simulation_based_bp(TxRx)

% codeword generation 1
% (we have an acceleration to divide the 5G NR encode into two parts)
[N, froz_bits, info_bits, input_IL, sb_IL, IL, IB] = nr_encode_part1(TxRx.E, TxRx.K, TxRx.link_mode);

% crc matrix 
% (note that crc registers are initilized as 1 for PDCCH)
if (TxRx.link_mode == 1)
    [G, H] = CRC_Matrix(TxRx.K, TxRx.crc_poly);
    H = H(:,[(1:TxRx.crc)'; input_IL+TxRx.crc+1]); % bit-interleaving for DL 
else
    [G, H] = CRC_Matrix(TxRx.K-TxRx.crc, TxRx.crc_poly);
end

% non-systematic codes
Gn = Fn(N)';

% list selection and generation
graphs = graph_select(N, TxRx.K-TxRx.crc, TxRx.list_vec(end), TxRx.PFG);
[graphs_pos, graphs_inv, s_vec] = get_permutation_hardware(graphs, TxRx.list_vec(end), N, log2(N));

% latency of recovering
recover_delay = zeros(1, TxRx.list_vec(end));
for i_list = 1 : TxRx.list_vec(end)
    for i_stage = 1 : log2(N)
        recover_delay(i_list) = recover_delay(i_list) + abs(s_vec(i_stage, i_list) - i_stage);
    end
end

% results stored
fer      = zeros(length(TxRx.snr_vec), length(TxRx.list_vec));
iter     = zeros(length(TxRx.snr_vec), length(TxRx.list_vec));
num_runs = zeros(length(TxRx.snr_vec), length(TxRx.list_vec));

% decoding loop starts
for i_run = 1 : TxRx.sim_step: TxRx.max_run
    % codeword generation 2
    % (we have an acceleration to divide the 5G NR encode into two parts)
    [info_with_crc, bpsk, noise] = nr_encode_part2(N, TxRx.E, TxRx.K, TxRx.crc, G, Gn, info_bits, input_IL, sb_IL, IL, IB, TxRx.sim_step);

    %*************simulation acceleration******************
    if all(fer(:,end) >= TxRx.max_err)
        break;
    end
    if  mod(i_run, TxRx.resolution) == 1
        disp(' ');
        disp(['Sim iteration running = ' num2str(i_run)]);
        disp(['N = ' num2str(N) ' K = ' num2str(TxRx.K) ' CRC = ' num2str(TxRx.crc)]);
        disp(['EbN0 or SNR : ' num2str(TxRx.snr) ', BP based ' ', Iter = ' num2str(TxRx.itera)]);
        disp(['List size = ' num2str(TxRx.list_vec)]);
        disp('Current block error performance');
        disp(num2str([TxRx.snr_vec'  fer./num_runs fer(:, 1) fer(:, end)]));
        disp(' ');
    end

    for i_snr = 1 : length(TxRx.snr_vec)
        %*******************Simulaion Accelaration*******************
        if fer(i_snr, end) >= TxRx.max_err
            continue;
        end

        sigma = 1/sqrt(2 * TxRx.R) * 10^(-TxRx.snr_vec(i_snr)/20);
        y     = bpsk + sigma * noise;
        llr   = 2/sigma^2*y;
        num_runs(i_snr, :) = num_runs(i_snr, :) + TxRx.sim_step;

        % list decoding
        [rxcbs, actualiters] = modified_bp_decode(TxRx, N, log2(N), H, llr, froz_bits, graphs_pos, graphs_inv);
        rxcbsi               = rxcbs(info_bits, :);          % extract the information bits
        actuallist           = ceil(actualiters/TxRx.itera); % number of used lists

        % compare the sent data with the decoded one
        for i_frame = 1: TxRx.sim_step
            if ~isequal(rxcbsi(:, i_frame), info_with_crc(:, i_frame))
                fer(i_snr, :)   = fer(i_snr, :) + 1;
            else
                fer(i_snr, :)   = fer(i_snr, :) + 1;
                for i_list = 1: length(TxRx.list_vec)
                    if actuallist(i_frame) <= TxRx.list_vec(i_list)
                        fer(i_snr, i_list:end) = fer(i_snr, i_list:end) - 1;
                        break;
                    end
                end
            end
            
            if (TxRx.countItera == 1)
                for i_list = 1: length(TxRx.list_vec)
                    if actuallist(i_frame) > TxRx.list_vec(i_list)
                        iter(i_snr, i_list) = iter(i_snr, i_list) + TxRx.list_vec(i_list)*TxRx.itera;
                    else
                        iter(i_snr, i_list) = iter(i_snr, i_list) + actualiters(i_frame);
                    end
                end
            end
        end
    end
end

disp(' ');
disp(['Sim iteration running = ' num2str(i_run)]);
disp(['N = ' num2str(N) ' K = ' num2str(TxRx.K) ' CRC = ' num2str(TxRx.crc)]);
disp(['EbN0 or SNR : ' num2str(TxRx.snr) ', BP based ' ', Iter = ' num2str(TxRx.itera)]);
disp(['List size = ' num2str(TxRx.list_vec)]);
disp('Current block error performance');
disp(num2str([TxRx.snr_vec'  fer./num_runs fer(:, 1) fer(:, end)]));
disp(' ');

fer   = fer./num_runs;
iter  = iter./num_runs;

end

