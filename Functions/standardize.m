function sdata = standardize(data, avr, var)
%Standardize data using given mean and variance

%Input: 
%data --> 'D x N' vector containing data
%avr --> 'D x 1' mean vector
%var --> 'D x 1' variance vector
%
%Output:
%metrics --> 'D x N' vector containing standardized data

if min(var) < 0.001
    var(var < 0.001) = 0.001;
end
sdata = (data - avr)./var;

if min(var) == 0
    %Remove any NaN-rows cause by zero variance
    [nan_rows, ~] = find(isnan(sdata));
    sdata(unique(nan_rows),:) = [];
    [inf_rows, ~] = find(isinf(sdata));
    sdata(unique(inf_rows),:) = [];
end
