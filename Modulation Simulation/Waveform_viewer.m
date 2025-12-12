%% =====================================================
%  A(t)*cos(phi(t)) Time-Domain Viewer (time in ms)
% =====================================================
clear; clc; close all;

set(groot, 'defaultTextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

%% 
bb_file = './bb_tvfss_am_pm.bb';

frameLen = 1024*1024;     
N_show   = 900000;         

%% 
r = comm.BasebandFileReader(bb_file, 'SamplesPerFrame', frameLen);

x = complex([]);
while length(x) < N_show && ~isDone(r)
    x = [x; r()];
end
release(r);

x = x(1:min(N_show, length(x)));

%% 
Fs = r.SampleRate;    
dt = 1/Fs;             
t_ms = (0:length(x)-1) * dt * 1000;   

A   = abs(x); 
phi = angle(x);

Acos = A .* cos(phi);

%% 
figure('Color','w');
plot(t_ms, Acos, 'LineWidth', 1.2);
grid on;

xlabel('Time (ms)', 'FontSize', 26);
ylabel('$A(t)\,\cos\phi(t)$', 'FontSize', 26);
set(gca, 'FontSize', 22);   % 或 14/18，自行选择


