function metrics = evaluate(true_labels,predicted_labels)
%Compute performance metrics
%
%Input: 
%true_labels --> '1 x Ntest' vector containing ground-truth labels
%predicted_labels --> '1 x Ntest' vector containing predicted labels
%
%Output:
%metrics --> A struct containing accuracy, tp_rate, Precision, F-Measure, G-mean

N = length(true_labels);
idx = (true_labels==1); 
p = sum(idx); %Number of positives
n = N - p; %Number of negatives

tp = sum(true_labels(idx)==predicted_labels(idx)); %Number of true positives
tn = sum(true_labels(~idx)==predicted_labels(~idx)); %Number of true negatives
fp = n-tn; %Number of false positives

tp_rate = tp/p;
tn_rate = tn/n;
metrics.accuracy = (tp+tn)/N;
metrics.precision = tp/(tp+fp);
metrics.precision(isnan(metrics.precision))=0;
metrics.recall = tp_rate;
metrics.f_measure = 2*((metrics.precision*metrics.recall)/(metrics.precision + metrics.recall));
metrics.f_measure(isnan(metrics.f_measure))=0;
metrics.gmean = sqrt(tp_rate*tn_rate);

