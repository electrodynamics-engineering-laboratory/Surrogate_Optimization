function Data=datainput_nvs09_I
%from the MINLPLib http://www.gamsworld.org/minlp/minlplib/nvs09.htm 
%%References:
%Tawarmalani, M, and Sahinidis, N, Exact Algorithms for Global Optimization 
%of Mixed-Integer Nonlinear Programs. In Pardalos, P M, and Romeijn, E, Eds,
%Handbook of Global Optimization - Volume 2: Heuristic Approaches. Kluwer Academic Publishers, 2001.
%Gupta, O K, and Ravindran, A, Branch and Bound Experiments in Convex Nonlinear 
%Integer Programming. Management Science 13 (1985), 1533-1546. 

%--------------------------------------------------------------------------
%Copyright (c) 2012 by Juliane Mueller
%
% This file is part of the surrogate model module toolbox.
%
%--------------------------------------------------------------------------
%Author information
%Juliane Mueller
%Tampere University of Technology, Finland
%juliane.mueller2901@gmail.com
%--------------------------------------------------------------------------
%
%objective function
Data.objfunction=@(i) -(-((log(i(:,1) - 2)).^2 + (log(10 - i(:,1))).^2 + (log(i(:,2) - 2)).^2 +...
    (log(10 - i(:,2))).^2 + (log(i(:,3) - 2)).^2 + (log(10 - i(:,3))).^2 + (log(i(:,4) - 2)).^2 +...
    (log(10 - i(:,4))).^2 + (log(i(:,5) - 2)).^2 + (log(10 - i(:,5))).^2 + (log(i(:,6) - 2)).^2 +...
    (log(10 - i(:,6))).^2 + (log(i(:,7) - 2)).^2 + (log(10 - i(:,7))).^2 + (log(i(:,8) - 2)).^2 +...
    (log(10 - i(:,8))).^2 + (log(i(:,9) - 2)).^2 + (log(10 - i(:,9))).^2 + (log(i(:,10) - 2)).^2 +...
    (log(10 - i(:,10))).^2 - (i(:,1).*i(:,2).*i(:,3).*i(:,4).*i(:,5).*i(:,6).*i(:,7).*i(:,8).*i(:,9).*i(:,10))^0.2)); 
%no constraints
Data.xlow=3*ones(1,10); %variable lower bounds
Data.xup=9*ones(1,10); %variable upper bounds
Data.integer =(1:10); %indices of integer variables
Data.continuous=[]; %indices of continuous variables
Data.dim = 10; %problem dimension
end %function