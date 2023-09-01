% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name  : polar_platform
% descr : code for paper 'High-Throughput Flexible Belief Propagation List Decoder for Polar Codes', 
%         arXiv preprint arXiv:2210.13887, 2022

rng(10); % set the fixed random seed to reproduce the simulation

% Configuration
TxRx.snr        = 1;            % input('select the format: SNR is 0, EbN0 is 1: ');
TxRx.crc        = 11;           % input('input the CRC length: ');
TxRx.PFG        = 'SG';         % input('PFG strategy: SG or ref');

TxRx.E          = 1024;         % input('input the E: ');
TxRx.K          = 512;          % input('input the K: ');
TxRx.snr_start  = 1.5;          % input('input the snr start: ');
TxRx.snr_end    = 2.75;         % input('input the snr end: ');
TxRx.snr_step   = 0.25;         % input('input the snr step: ');
TxRx.link_mode  = 0;            % input('select the link mode: uplink is 0, downlink is 1: ');
TxRx.list_vec   = [1 8 32 128]; % input('input the lists of BPL decoding: '); note that the running time is only decided by the last one
TxRx.itera      = 50;           % input('input the number of iterations: ');
TxRx.countItera = 1;            % input('whether to count the average number of iterations')

if TxRx.snr == 0                % EbN0/SNR
    TxRx.R = 1/2;
else
    TxRx.R = TxRx.K/TxRx.E;
end
TxRx.K = TxRx.K + TxRx.crc;

TxRx.max_run    = 1e+9;
TxRx.max_err    = 200;
TxRx.resolution = 1e+3; % the results are shown per max_runs/resolution
TxRx.sim_step   = 1e+3;
TxRx.crc_poly   = get_crc_polynomial(TxRx.crc, 1);
TxRx.snr_vec    = TxRx.snr_start : TxRx.snr_step : TxRx.snr_end; % row vec

tic
[fer, iter] = simulation_based_bp(TxRx);
toc