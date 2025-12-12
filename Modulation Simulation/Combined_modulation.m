%% ===============================================================
%  TVFSS Simulation on Real .bb Baseband Data
%  AM + Phase Scrambling (AM then PM)
%  1) Apply real TVFSS amplitude modulation 
%  2) Then apply phase scrambling 
% ===============================================================

clear; clc;
%% 
in_bb  = './data1/image7_CF_742.500MHz_FS_60.000MSPS_T0.5s.bb';
out_bb = 'bb_tvfss_am_pm.bb';

Fs = 60e6;    
Fc = 742.5e6; 

%% 
g_low_dB  = -30.1;   
g_high_dB = -8.1;    

g_low  = 10^(g_low_dB/20);
g_high = 10^(g_high_dB/20);

fprintf("Using REAL TVFSS gains: low=%.4f, high=%.4f (ratio=%.2f)\n", ...
        g_low, g_high, g_high/g_low);

f_refresh = 60;
f_tv = 3*f_refresh;   % 180 Hz
duty = 0.5;

%% 
f_phi1 = 150e3;   % 150 kHz
A_phi1 = 100;     % phi1 = 100*sin(...)
A_phi2 = 0.3;     % phi2 = 0.3*randn

%%
frameLen = 1024*1024;

reader = comm.BasebandFileReader(in_bb, 'SamplesPerFrame', frameLen);
writer = comm.BasebandFileWriter(out_bb, Fs, Fc);

fprintf("Processing .bb with AM then PM...\n");

phase_acc = 0;
two_pi = 2*pi;

pm_phase_acc = 0;   

while ~isDone(reader)

    x = reader();         
    Ns = length(x);

    t = (0:Ns-1).' / Fs;

    phi_am = two_pi * f_tv * t + phase_acc;
    phase_acc = mod(phi_am(end) + two_pi*f_tv/Fs, two_pi);

    sq = double(mod(phi_am/(2*pi), 1) < duty);  % 0/1
    g  = g_low + (g_high - g_low) * sq;

    x_am = g .* x;

    n_local = (0:Ns-1).';
    theta = 2*pi*f_phi1*n_local/Fs + pm_phase_acc;
    pm_phase_acc = mod(theta(end) + 2*pi*f_phi1/Fs, 2*pi);

    phi1 = A_phi1 * sin(theta);
    phi2 = A_phi2 * randn(Ns,1);

    phi = 2*pi*(phi1 + phi2);

    y = x_am .* exp(1j * phi);

    writer(y);
end

release(reader);
release(writer);

fprintf("Done! Saved AM+PM baseband to %s\n", out_bb);
