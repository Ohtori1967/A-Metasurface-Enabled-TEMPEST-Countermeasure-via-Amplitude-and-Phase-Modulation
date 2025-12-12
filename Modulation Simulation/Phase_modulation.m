%% ===============================================================
%  TVFSS Simulation on Real .bb Baseband Data
%  PM
% ===============================================================

clear; clc;

%% 
in_bb  = './data1/image7_CF_742.500MHz_FS_60.000MSPS_T0.5s.bb';
out_bb = 'bb_tvfss_phase.bb';

frmLen = 1024*1024;   

%% 
reader = comm.BasebandFileReader(in_bb, 'SamplesPerFrame', frmLen);

Fs = reader.SampleRate;
Fc = reader.CenterFrequency;

fprintf('[Reader] Fs=%.3f MHz, Fc=%.3f MHz\n', Fs/1e6, Fc/1e6);

x = single([]);   

tic;
while ~isDone(reader)
    x = [x; reader()];
end
release(reader);

N = length(x);
n = (0:N-1).';

fprintf('[Reader] Loaded %.2f M samples.\n', N/1e6);

%% 
phi1 = 100 * sin(2*pi*150e3*n/Fs);
phi2 = 0.3 * randn(N,1);

phi = 2*pi*(phi1 + phi2);

y = x .* exp(1j * phi);

%% 
writer = comm.BasebandFileWriter(out_bb, Fs, Fc);

k = 1;
frame = frmLen;
while k <= N
    idx = min(k+frame-1, N);
    writer(y(k:idx));
    k = idx+1;
end
release(writer);

fprintf('[Writer] Saved %s\n', out_bb);
