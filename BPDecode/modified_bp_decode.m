% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name   : modified_bp_decode
% descr  : perform a series of bp decoding

function [decode_bits, decode_itera] = modified_bp_decode(TxRx, N, n, H, llr, froz_bits, graphs_pos, graphs_inv)

% reshaping
llr        = reshape(llr, 1, N*TxRx.sim_step);
froz_bits  = double(froz_bits');
graphs_pos = reshape(graphs_pos, 1, N*TxRx.list_vec(end));
graphs_inv = reshape(graphs_inv, 1, N*TxRx.list_vec(end));
H          = reshape(H, 1, length(H(:)));

% run C.exe to accelerate speed 
% refer to matlab code: polar_bp_float.m, polar_bp_list_float.m
if TxRx.list_vec(end) == 1
    % [decode_bits, decode_itera] = polar_bp_float(N, n, llr, froz_bits, TxRx.itera, TxRx.sim_step);
    [decode_bits, decode_itera] = polar_bp_float_mex(N, n, llr, froz_bits, TxRx.itera, TxRx.sim_step);
else
    % [decode_bits, decode_itera] = polar_bp_list_float(N, n, llr, TxRx.list_vec(end), graphs_pos, graphs_inv, froz_bits, TxRx.link_mode, TxRx.itera, TxRx.sim_step, H);
    [decode_bits, decode_itera] = polar_bp_list_float_mex(N, n, llr, TxRx.list_vec(end), TxRx.crc, graphs_pos, graphs_inv, froz_bits, TxRx.link_mode, TxRx.itera, TxRx.sim_step, H);
end

% reshaping
decode_bits = reshape(decode_bits, N, TxRx.sim_step);

end
