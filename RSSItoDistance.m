function [ distance ] = RSSItoDistance( rssi, power )
%NoisyRssi Provides noisy RSSI value given distance and transmit power
%   Detailed explanation goes here
%noise = -90; %dBm
r = 1;
n = 10 * r;
distance = 10^((rssi-power)/(-n));
end
