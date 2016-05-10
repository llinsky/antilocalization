function [ x,y ] = getTransmitterCoordinates( x1, x2, x3, y1, y2, y3, d1, d2, d3)

%getTransmitterCoordinates takes in estimated distances and xy values for 3 
%listening points, then calculates an estimated transmitter position
%
% x_n1 = (d1^2 - d2^2)-(x1^2 - x2^2)-(y1^2 - y2^2)*2*(y3 - y1)
% x_n2 = 2*(y2 - y1)*(d1^2 - d3^2) - (x1^2 - x3^2) - (y1^2 - y3^2)
% x_d = 2*(x2 - x1)*2*(y3 - y1) - 2*(y2 - y1)*2*(x3-x1)
% x = (x_n1 - x_n2)/x_d
% y = 2;
%
x_n11 = (d1^2 - d2^2) - (x1^2 - x2^2) - (y1^2 - y2^2);
x_n21 = (d1^2 - d3^2) - (x1^2 - x3^2) - (y1^2 - y3^2);
x_n12 = 2*(y2-y1);
x_n22 = 2*(y3-y1);
d11 = 2*(x2-x1);
d21 = 2*(x3-x1);
d12 = 2*(y2-y1);
d22 = 2*(y3-y1);
x_n = [x_n11, x_n12; x_n21, x_n22];
d = [d11, d12; d21, d22];
x = x_n/d;
x = det(x);
y_n11 = d11;
y_n21 = d21;
y_n12 = x_n11;
y_n22 = x_n21;
y_n = [y_n11, y_n12; y_n21, y_n22];
y = y_n/d;
y = det(y);
end
