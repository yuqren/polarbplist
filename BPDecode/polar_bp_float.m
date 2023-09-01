% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name  : polar_bp_float
% descr : belief propagation decoding based on a uniform graph
% refer : Pamuk, Alptekin. "An FPGA implementation architecture for decoding of polar codes." 
%         2011 8th International symposium on wireless communication systems. IEEE, 2011.

function [dec_bits, dec_iter] = polar_bp_float(N, n, llr, froz_bits, itera, sim_num)

% -------------------------------------------------------------------
% Parameter and memory allocations
% -------------------------------------------------------------------
l2r_msg  = zeros(N, n+1, sim_num);
r2l_msg  = zeros(N, n+1, sim_num);

dec_bits = zeros(N, sim_num);
dec_iter = zeros(1, sim_num);

% -------------------------------------------------------------------
% Decoding
% -------------------------------------------------------------------
l2r_msg(:, n+1, :)       = llr;
r2l_msg(froz_bits, 1, :) = Inf;

for i_frame = 1: sim_num
    % clean up the buffer
    SA_buf1 = zeros(N, 1); % SA termination (three consecutive identical \hat{u})
    SA_buf2 = zeros(N, 1);

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

        % termination (sign-assisted)
        u_esti  = (l2r_msg(:, 1, i_frame) + r2l_msg(:, 1, i_frame)) < 0;
        SA_esti = (l2r_msg(:, 3, i_frame) + r2l_msg(:, 3, i_frame)) < 0;
        
        if isequal(SA_esti, SA_buf1) && isequal(SA_buf1, SA_buf2)
            break;
        end

        SA_buf2 = SA_buf1;
        SA_buf1 = SA_esti;
    end

    dec_bits(:, i_frame) = u_esti;
    dec_iter(i_frame)    = i_itera;

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