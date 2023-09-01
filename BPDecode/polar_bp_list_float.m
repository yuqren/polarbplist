% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name  : polar_bp_list_float
% descr : belief propagation list decoding (reuse a uniform graph)
% refer : Elkelesh, Ahmed, et al. "Belief propagation list decoding of polar codes." 
%         IEEE Communications Letters 22.8 (2018): 1536-1539.

function [dec_bits, dec_iter] = polar_bp_list_float(N, n, llr, list_num, graphs_pos, graphs_inv, froz_bits, link, itera, sim_num, H)

% -------------------------------------------------------------------
% Parameter and memory allocations
% -------------------------------------------------------------------
l2r_msg  = zeros(N, n+1, sim_num); % internal memory
r2l_msg  = zeros(N, n+1, sim_num);

l_init   = llr; % initial LLRs
r_init   = zeros(N, sim_num);

dec_bits = zeros(N, sim_num); % decoded results
dec_iter = zeros(1, sim_num);

info_bits = not(froz_bits);

% -------------------------------------------------------------------
% Decoding
% -------------------------------------------------------------------
r_init(froz_bits, :) = Inf;

for i_frame = 1: sim_num
    for i_graph = 1: list_num
        % codeword permutation (positive)
        l2r_msg(:, n+1, i_frame) = l_init(graphs_pos(:, i_graph)+1, i_frame);
        r2l_msg(:, 1, i_frame)   = r_init(graphs_pos(:, i_graph)+1, i_frame);

        % clean up the buffer and memory
        SA_buf1 = zeros(N, 1); % SA termination (three consecutive identical \hat{u})
        SA_buf2 = zeros(N, 1);

        l2r_msg(:, 1:n, i_frame)   = zeros(N, n);
        r2l_msg(:, 2:n+1, i_frame) = zeros(N, n);

        for i_itera = 1: itera
            for i = 1: n % propagate left messages (u ←-- x)
                for j = 1: N/2
                    l2r_msg(2*j-1, n+1-i, i_frame) = g_type1(l2r_msg(j, n+1-i+1, i_frame), l2r_msg(j+N/2, n+1-i+1, i_frame), r2l_msg(2*j, n+1-i, i_frame), 0);
                    l2r_msg(2*j, n+1-i, i_frame)   = g_type2(l2r_msg(j, n+1-i+1, i_frame), l2r_msg(j+N/2, n+1-i+1, i_frame), r2l_msg(2*j-1, n+1-i, i_frame), 0);
                end
            end

            for i = 1: n % propagate right messages (u --→ x)
                for j = 1: N/2
                    r2l_msg(j, i+1, i_frame)     = g_type1(r2l_msg(2*j-1, i, i_frame), r2l_msg(2*j, i, i_frame), l2r_msg(j+N/2, i+1, i_frame), 0.25);
                    r2l_msg(j+N/2, i+1, i_frame) = g_type2(r2l_msg(2*j-1, i, i_frame), r2l_msg(2*j, i, i_frame), l2r_msg(j, i+1, i_frame), 0.25);
                end
            end

            % termination
            u_esti  = (l2r_msg(:, 1, i_frame) + r2l_msg(:, 1, i_frame)) < 0;
            SA_esti = (l2r_msg(:, 3, i_frame) + r2l_msg(:, 3, i_frame)) < 0;

            if isequal(SA_esti, SA_buf1) && isequal(SA_buf1, SA_buf2)
                break;
            end

            SA_buf2 = SA_buf1;
            SA_buf1 = SA_esti;
        end
        
        % codeword permutation (inverse)
        u_esti = u_esti(graphs_inv(:, i_graph)+1);

        % detection (crc)
        if link == 1
            crc_synchrome = mod(H*[ones(crc_len, 1); u_esti(info_bits)],2);
        else
            crc_synchrome = mod(H*u_esti(info_bits),2);
        end

        if (sum(crc_synchrome) == 0) || (i_itera == itera && i_graph == list_num)
            dec_bits(:, i_frame) = u_esti;
            dec_iter(i_frame)    = (i_graph-1)*itera + i_itera;
            break;
        end
    end
end
end

% -------------------------------------------------------------------
% PE functions (OMS)
% -------------------------------------------------------------------
function msg_o = g_type1(msg1_i, msg2_i, msg3_i, offset)
msg_o = sign(msg1_i)*sign(msg2_i + msg3_i)*max(min(abs(msg1_i), abs(msg2_i + msg3_i)) - offset, 0);
end

function msg_o = g_type2(msg1_i, msg2_i, msg3_i, offset)
msg_o = sign(msg1_i)*sign(msg3_i)*max(min(abs(msg1_i), abs(msg3_i)) - offset, 0) + msg2_i;
end