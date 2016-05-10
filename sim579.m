%Simulation Code (Uniform spoofing)

min = 1;
maxpower = 100;

num_steps = 1; % (gradient method)

%Algorithm 1 Trilateration method
min_samples = 100;
max_samples = 1000;
sample_step = 100;

xgridmin = 0;
xgridmax = 100;
ygridmin = 0;
ygridmax = 100;

num_trials = 5;
num_runs = 2000;




movement_rate = 0; %0.4;
node_direction = zeros(2,1);

temp_errors = zeros(num_trials,1);
avg_errors = zeros(((max_samples-min_samples)/sample_step)+1,1);

% %method 1: Simulation of Algorithm 1 in our paper
% counter=1;
% for num_samples=min_samples:sample_step:max_samples
%     for k=1:num_trials
%         loc_node=zeros(1,2);
%         loc_node(1,1) = rand*(xgridmax-xgridmin)+xgridmin;
%         loc_node(1,2) = rand*(ygridmax-ygridmin)+ygridmin;
%         %fprintf('Location of Node: %d,%d\n',loc_node(1,1),loc_node(1,2));
%         max_RSSI=zeros(1,3);
%         max_power=zeros(1,3);
%         locations = zeros(3,2);
%         for i=1:3 %three listening points
%             loc_sniffer= zeros(1,2);
%             loc_sniffer(1,1) = rand*(xgridmax-xgridmin)+xgridmin;
%             loc_sniffer(1,2) = rand*(ygridmax-ygridmin)+ygridmin;
%             %store location for later calculation
%             locations(i,1)=loc_sniffer(1);
%             locations(i,2)=loc_sniffer(2);
%             for j=1:num_samples 
%                 power = rand*(max-min)+min;
%                 rssi = NoisyRssi( norm(loc_sniffer-loc_node), power);
%                 if(rssi>max_RSSI(1,i))
%                     max_RSSI(1,i)=rssi;
%                     max_power(1,i)=power;
%                 end      
%             end
%         end
%         %extract coordinates -unnecessary intermediate step :)
%         x1=locations(1,1);
%         x2=locations(2,1);
%         x3=locations(3,1);
%         y1=locations(1,2);
%         y2=locations(2,2);
%         y3=locations(3,2);
%         %fprintf('Max powers: %d %d %d\n',max_power(1,1),max_power(1,2),max_power(1,3));
%         d1=RSSItoDistance(max_RSSI(1,1),max);
%         d2=RSSItoDistance(max_RSSI(1,2),max);
%         d3=RSSItoDistance(max_RSSI(1,3),max);
%         estimate=zeros(1,2);
%         [estimate(1,1),estimate(1,2) ]= getTransmitterCoordinates( x1, x2, x3, y1, y2, y3, d1, d2, d3);
%         error = norm(estimate-loc_node);
%         %fprintf('Estimate: %d,%d\n',estimate(1),estimate(2));
%         %fprintf('Error: %d\n',error);
%         temp_errors(k,1) = norm(estimate-loc_node);
%     end
%     avg_errors(counter,1) = sum(temp_errors)/num_trials;
%     counter=counter+1;
% end
% %Algorithm 1 Plot
% figure(1);
% plot(min_samples:sample_step:max_samples,avg_errors)
% xlabel('Samples Collected at Each Sniffing Point (n)');
% ylabel('Average Localization Error');
% 



%Triangulation using the fingerprinting technique
%fingerprint database also uses known, constant power levels, so this method is not
%useful here
%we can make a modification of the algorithm that takes a fingerprint of
%many power levels and many sniffer configurations, however






% Triangulation using gradient heuristic (vs both uniform disribution and
% ascending)
% this one is most intuitive to implement (no math)
% the algorithm is as follows: the node knows its current and last RSSI
% measurement, and last movement direction. If the RSSI strength is
% increasing, it takes another random number of steps in the current
% direction. If not, it changes directions randomly and starts over. 
% This will only converge within error of number of steps, but
% the error should approach zero as the mean of the distribution of number
% of steps approaches zero.
loc_sniffer = zeros(2,1);
loc_node = zeros(2,1);
direction = zeros(2,1);

debugdist = zeros(num_runs,1);

rssi_last = 0;

max_history = 128;

avg_distances_constant = zeros(max_history/2,1);
xx = zeros(max_history/2,1);


for k=2:1:max_history
    distances = zeros(num_trials,1);
    
    for i=1:num_trials
        last_rssi = zeros(k,1);
        wait = 0;

        
        loc_node = zeros(2,1);
        loc_node(1,1) = rand*(xgridmax-xgridmin)+xgridmin;
        loc_node(2,1) = rand*(ygridmax-ygridmin)+ygridmin;
        
        loc_sniffer = zeros(2,1);
        loc_sniffer(1,1) = rand*(xgridmax-xgridmin)+xgridmin;
        loc_sniffer(2,1) = rand*(ygridmax-ygridmin)+ygridmin;
        
        direction(1,1) = rand-0.5;
        direction(2,1) = rand-0.5;
        direction = direction/norm(direction,2);
        
        gradient = 1;

        for j=1:num_runs
            %Method 3 -- basic triangulation with gradient heuristic --
            %static power
            if (j==num_runs)
                distances(i,1) = norm(loc_sniffer-loc_node);
            end
            
            power = rand*(maxpower-min)+min;
            
            for h=1:k
                power = rand*(maxpower-min)+min;
                last_rssi(h,1) = NoisyRssi( norm(loc_sniffer-loc_node), power, 1);
            end
            
            rssi = max(last_rssi); %sum(last_rssi)/k;

            gradient = rssi - rssi_last;
            
            rssi_last = rssi;
            
            if (gradient > 0)
                %Great, keep following the gradient
                loc_sniffer = loc_sniffer+(direction*k*rand);
                %numGood=numGood+1;
            else
                %change directions and restart sequence -- Might get rid of
                %sequence
                %sequence = 1;
                direction(1,1) = rand-0.5;
                direction(2,1) = rand-0.5;
                direction = direction/norm(direction,2);
                loc_sniffer = loc_sniffer+(direction*k*rand);
                %numBad=numBad+1;
            end
            
            rssi_last = rssi;
            
            if (j==num_runs)
                distances(i,1) = norm(loc_sniffer-loc_node);
            end
        end
        %fprintf('Good directions: %d \t Bad Directions: %d \n',numGood,numBad);
    end
    xx(round(k/2),1) = k;
    avg_distances_constant(round(k/2),1) = sum(distances)/num_trials;
end


% avg_distances_dynamic = zeros(super_trials,1);
% 
% for k=1:super_trials
%     distances = zeros(num_trials,1);
%     for i=1:num_trials
%         rssi_last = 0;
%         
%         loc_node = zeros(2,1);
%         loc_node(1,1) = rand*(xgridmax-xgridmin)+xgridmin;
%         loc_node(2,1) = rand*(ygridmax-ygridmin)+ygridmin;
%         
%         loc_sniffer = zeros(2,1);
%         loc_sniffer(1,1) = rand*(xgridmax-xgridmin)+xgridmin;
%         loc_sniffer(2,1) = rand*(ygridmax-ygridmin)+ygridmin;
%         
%         direction(1,1) = rand-0.5;
%         direction(2,1) = rand-0.5;
%         direction = direction/norm(direction,2);
% 
%         for j=1:num_runs
%             %Method 3 -- basic triangulation with gradient heuristic --
%             %uniformly distributed power
%             
%             power = rand*(max-min)+min;
%             
%             rssi = NoisyRssi( norm(loc_sniffer-loc_node), power);
%             
%             gradient = rssi - rssi_last;
%             
%             if (gradient > 0)
%                 %Great, keep following the gradient
%                 loc_sniffer = loc_sniffer+(direction*num_steps*rand);
%                 %numGood=numGood+1;
%             else
%                 %change directions and restart sequence -- Might get rid of
%                 %sequence
%                 %sequence = 1;
%                 direction(1,1) = rand-0.5;
%                 direction(2,1) = rand-0.5;
%                 direction = direction/norm(direction,2);
%                 loc_sniffer = loc_sniffer+(direction*num_steps*rand);
%                 %numBad=numBad+1;
%             end
%             
%             debugdist(j,1)=norm(loc_sniffer-loc_node);
%             rssi_last = rssi;
%             
%             if (j==num_runs)
%                 distances(i,1) = norm(loc_sniffer-loc_node);
%             end
%         end
%         %fprintf('Good directions: %d \t Bad Directions: %d \n',numGood,numBad);
%     end
%     avg_distances_dynamic(k,1) = sum(distances)/num_trials;
% end
% 
% sequence = 1;
% avg_distances_ascending = zeros(super_trials,1);
% 
% for k=1:super_trials
%     distances = zeros(num_trials,1);
%     for i=1:num_trials
%         rssi_last = 0;
%         
%         loc_node = zeros(2,1);
%         loc_node(1,1) = rand*(xgridmax-xgridmin)+xgridmin;
%         loc_node(2,1) = rand*(ygridmax-ygridmin)+ygridmin;
%         
%         loc_sniffer = zeros(2,1);
%         loc_sniffer(1,1) = rand*(xgridmax-xgridmin)+xgridmin;
%         loc_sniffer(2,1) = rand*(ygridmax-ygridmin)+ygridmin;
%         
%         direction(1,1) = rand-0.5;
%         direction(2,1) = rand-0.5;
%         direction = direction/norm(direction,2);
%         
%         lastpower = 0;
%         sequence = 1;
% 
%         for j=1:num_runs
%             %Method 3 -- basic triangulation with gradient heuristic --
%             %ascending power
%             
%             power = SpoofedPowerAscending(sequence, lastpower, min, max);
%             lastpower = power;
%             sequence = sequence + 1;
%             if (sequence > 4)
%                 sequence = 1;
%             end
%             
%             rssi = NoisyRssi( norm(loc_sniffer-loc_node), power);
%             
%             gradient = rssi - rssi_last;
%             
%             if (gradient > 0)
%                 %Great, keep following the gradient
%                 loc_sniffer = loc_sniffer+(direction*num_steps*rand);
%                 %numGood=numGood+1;
%             else
%                 %change directions and restart sequence -- Might get rid of
%                 %sequence
%                 %sequence = 1;
%                 direction(1,1) = rand-0.5;
%                 direction(2,1) = rand-0.5;
%                 direction = direction/norm(direction,2);
%                 loc_sniffer = loc_sniffer+(direction*num_steps*rand);
%                 %numBad=numBad+1;
%             end
%             
%             debugdist(j,1)=norm(loc_sniffer-loc_node);
%             rssi_last = rssi;
%             
%             if (j==num_runs)
%                 distances(i,1) = norm(loc_sniffer-loc_node);
%             end
%         end
%         %fprintf('Good directions: %d \t Bad Directions: %d \n',numGood,numBad);
%     end
%     avg_distances_ascending(k,1) = sum(distances)/num_trials;
% end

%gradient method
figure(2);
%x = [1:super_trials]';
plot(xx,avg_distances_constant)% x,avg_distances_dynamic, x,avg_distances_ascending);
xlabel('Gradient History');
yaxislabel = sprintf('Average distance after %d runs', num_runs);
ylabel(yaxislabel);
title('Convergence of Sniffer upon Noisy Dynamic Node Using Gradient Algorithm');
%legend('Static Power', 'Uniform Random Power', 'Ascending Random Power');

%currently the data does not converge very well... need to clean up this
%algorithm
