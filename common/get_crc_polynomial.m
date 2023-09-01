% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name  : get_crc_polynomial
% descr : select the CRC polynomial

function crcpoly = get_crc_polynomial(crc_length, nrflag)
if nrflag == 1
    switch crc_length
        case 6
            crcpoly = [1 1 0 0 0 0 1];
        case 11
            crcpoly = [1 1 1 0 0 0 1 0 0 0 0 1];
        case 24
            crcpoly = [1 1 0 1 1 0 0 1 0 1 0 1 1 0 0 0 1 0 0 0 1 0 1 1 1];
        otherwise
            error('Unsupported CRC length. Program terminates');
    end
end