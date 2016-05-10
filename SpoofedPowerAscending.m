function [ output_power ] = SpoofedPowerAscending( sequence, last, min, max )
%SpoofedPowerAscending Provides a spoofed power using a technique that
%creates ascending power levels to misdirect lone sniffers

%sequence number goes from 1 to 4, then starts over with a uniform 
%distribution (no longer ascending)

if (sequence == 1)
    output_power = rand*(max-min)+min;
    return;
else
    range = max - min;
    ascend_range = max-last;
    new_max = min + range - ascend_range + ascend_range*4;
    
    power = rand*(new_max-min)+min;
    if (power > last)
        output_power = (power - last)/4 + last;
        return;
    else
        output_power = power;
        return;
    end
end


end

