function labels = get_REF_labels(testdata, metric, threshold)
% Get the label predictions corresponding to the transformed data

%Input: 
%testdata --> 'D x Ntest' matrix containing test data
%%metric --> The distance metric as a string
%threshold --> The threshold value
%
%Output:
%labels --> '1 x Ntest' vector containing predicted labels

D = size(testdata,1);
N = size(testdata,2);

% For each item, compute the distance to the origin according to 'metric'
if strcmp( metric, 'L1')
    for i = 1:N
        Mtest(i) = mean(abs(testdata(:,i)));
    end
elseif strcmp( metric, 'L2')
    for i = 1:N
        Mtest(i) = norm(testdata(:,i))/D;
    end
end

% Label items negative if their distance to the origin in larger than
% 'threshold', otherwise positive
labels_temp = Mtest > threshold;
labels = ones(size(labels_temp));
labels(labels_temp==1) = -1;