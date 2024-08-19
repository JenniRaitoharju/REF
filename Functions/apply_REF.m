function results = apply_REF(operator, metric, iters, threshold, traindata, testdata, testlabels)
% Run REF with given params

%Input: 
%operators --> The folding operator as a string
%metric --> The distance metric as a string
%iters --> The number of iterations
%threshold --> The threshold value
%traindata --> 'D x Ntrain' matrix containing training data
%testdata --> 'D x Ntest' matrix containing test data
%testlabels --> '1 x Ntest' vector containing test labels
%
%Output:
%results --> A struct containing accuracy, tp_rate, Precision, F-Measure, G-mean

% Standardize first
avr = mean(traindata')';
var = std(traindata')';
traindata = standardize(traindata,avr,var);
testdata = standardize(testdata,avr,var);

% Repeated Element-wise Folding and standardization
iter = 0;
while iter < iters    
    iter = iter + 1;
    if strcmp( operator, 'abs')
        traindata = abs(traindata);
        testdata = abs(testdata);
    elseif strcmp( operator, 'sqr')
        traindata = traindata.^2;
        testdata = testdata.^2;
    elseif strcmp( operator, 'cosabs')
        train_abs = abs(traindata);
        traindata( train_abs > 1) = train_abs( train_abs > 1);
        test_abs = abs(testdata);
        testdata( test_abs > 1) = test_abs( test_abs > 1);
        train_cos = cos(traindata);
        traindata( train_abs < 1) = train_cos( train_abs < 1);
        test_cos = cos(testdata);
        testdata( test_abs < 1) = test_cos( test_abs < 1);
    elseif strcmp( operator, 'cos')
        traindata = cos(traindata);
        testdata = cos(testdata);
    elseif strcmp( operator, 'sin')
        traindata = sin(traindata);
        testdata = sin(testdata);
    elseif strcmp( operator, 'tanh')
        traindata = tanh(traindata);
        testdata = tanh(testdata);
    end
      
    avr = mean(traindata')';
    var = std(traindata')';
    traindata = standardize(traindata,avr,var);
    testdata = standardize(testdata,avr,var);

end

% Get the label predictions
labels = get_REF_labels(testdata, metric, threshold);

% Compute the results
results = evaluate(testlabels,labels);
