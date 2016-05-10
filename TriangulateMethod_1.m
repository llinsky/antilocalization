function [ estimate ] = TriangulateMethod_1( posNode, posA, rssiA, posB, rssiB, posC, rssiC )

%TriangulateMethod_1 Simple euclidean triangulation method 

distanceA = c*10^(rssiA);
distanceB = c*10^(rssiB);
distanceC = c*10^(rssiC);

%Now solve for c such that there is a point X where norm(X-posA)=distanceA, 
% norm(X-posB)=distanceB, and norm(X-posC)=distanceC


%Options: iterative trial and error, intelligent search, math (6 equations,
% 6 unknowns -- X counts as two unknowns in 2-D), etc.

estimate = 0; %(posA*rssiA + posB*rssiB + posC*rssiC)/(rssiA+rssiB+rssiC);


end

