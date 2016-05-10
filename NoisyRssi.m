function [ rssi ] = NoisyRssi( distance, power )
%NoisyRssi Provides noisy RSSI value given distance and transmit power
%   Detailed explanation goes here
%noise = -90; %dBm
r = 1;%rand/50 + 0.98;
n = 10 * r;

rssi = -n*log10(distance) + power;


end
