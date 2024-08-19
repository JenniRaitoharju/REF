function results = train_and_test(traindata, trainlabels, testdata, testlabels, variants, active, bestSetting)
%Train and test with pre-defined params

%Input: 
%traindata --> 'D x Ntrain' matrix containing training data
%trainlabels --> '1 x Ntrain' vector containing training labels
%testdata --> 'D x Ntest' matrix containing test data
%testlabels --> '1 x Ntest' vector containing test labels
%variants --> A struct containing different variants of REF
%active --> '2 x 1 vector' showing which variant is currently used
%bestSetting --> A table containing the best hyperparameter combo
%
%Output:
%results --> A struct containing accuracy, tp_rate, Precision, F-Measure, G-mean

%Selecting only the target data for training...
posdata = traindata(:, trainlabels==1);
          
Ntraindata = posdata;
Ntestdata = testdata; % Test with both positives and negatives

operator = variants.operators{active(1)};
metric = variants.metrics{active(2)};
iter = bestSetting.iters;
threshold = bestSetting.thresholds;
results = apply_REF(operator, metric, iter, threshold, Ntraindata, Ntestdata, testlabels);   

