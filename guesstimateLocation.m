function [ bestx, besty, bestpower ] = guesstimateLocation( s1, s2, s3, rssi1, rssi2, rssi3 )
%guesstimateLocation Attempts to trilaterate location of node with noisy
%signal


best = Inf;
bestx = 0;
besty = 0;

transmit_min = 1;
transmit_max = 100;

xmin = 0;
xmax = 20;
ymin = 0;
ymax = 20;
p = 0;

for p = transmit_min:transmit_max
    
    %it would be more efficient to do least squares or something to find a
    %smaller area to search but i'm just going to brute force it
    
    d1 = RSSItoDistance(rssi1, p);
    d2 = RSSItoDistance(rssi2, p);
    d3 = RSSItoDistance(rssi3, p);
    
    for x = xmin:xmax
        for y = ymin:ymax
            coord = [x; y];
            error = sqrt( (norm(coord-s1,2)-d1)^2 + (norm(coord-s2,2)-d2)^2 + (norm(coord-s3,2)-d3)^2 );
            
            if (error < best)
                best = error;
                bestx = x;
                besty = y;
                bestpower = p;
            end
            
        end
    end
    
    
end



end

