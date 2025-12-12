%% ===============================================================
%  TVFSS Simulation on Real .bb Baseband Data
%  AM on 180Hz square wave
% ===============================================================
clear; clc;

%% 
in_bb  = './data1/image7_CF_742.500MHz_FS_60.000MSPS_T0.5s.bb';
out_bb = 'bb_tvfss_square.bb';   

Fs = 60e6;    

%% 

g_low_dB  = -30.1;   
g_high_dB = -8.1;    

g_low  = 10^(g_low_dB/20);   
g_high = 10^(g_high_dB/20);  

fprintf("Using REAL TVFSS gains: low=%.4f, high=%.4f (ratio=%.2f)\n", ...
        g_low, g_high, g_high/g_low);

f_refresh = 60;       
f_tv = 3*f_refresh;   
duty = 0.5;            


%%
frameLen = 1024*1024;

reader = comm.BasebandFileReader(in_bb, 'SamplesPerFrame', frameLen);
writer = comm.BasebandFileWriter(out_bb, Fs, 742.5e6);

fprintf("Processing .bb with REAL TVFSS modulation...\n");

%% 
phase_acc = 0;
two_pi = 2*pi;

%% 
while ~isDone(reader)

    x = reader();     
    Ns = length(x);

    t = (0:Ns-1).' / Fs;

    phi = two_pi * f_tv * t + phase_acc;
    phase_acc = mod(phi(end) + two_pi*f_tv/Fs, two_pi);

    sq = double(mod(phi/(2*pi),1) < duty);

    g = g_low + (g_high - g_low) * sq;

    y = g .* x;

    writer(y);
end

release(reader);
release(writer);

fprintf("Done! Saved REAL TVFSS-simulated baseband to %s\n", out_bb);
