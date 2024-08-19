% This file contains a simple demo for applying Repeated Element-wise 
% Folding One-Class Classifier on preprocessed datasets either with
% optimized or default hyperparameters

addpath('Datasets');
addpath('Functions');

% Datasets to be used
datasets = {'iris', 'seeds','ionosphere', 'sonar', 'bankruptcy', 'happiness'};

% Select if the default settings are used or if the hyperparameters are
% optimized
default = false;

% Number of validation folds to be used in hyperparameter setting
% Note the datasets contains 5 different train/test splits
validationfolds = 5;
     
% The main evaluation metric
hyperparams.evaluation = 'gmean';

%Hyperparameter choices
hyperparams.thresholds = [0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1];  % Thresholds
hyperparams.iters = 100; % Number of iterations

% REF variant
variants.operators = {'abs', 'sqr', 'cosabs', 'cos', 'sin', 'tanh'}; % Folding operators 
variants.metrics = {'L1', 'L2'}; % Distance metric

% Select which combinations of operators and metrics to run (some
% combination can be removed).
REFcombos = [1,1; 2,1; 3,1; 4,1; 5,1; 6,1; 1,2; 2,2; 3,2; 4,2; 5,2; 6,2];

if default
	hyperparams.thresholds = 1.0;
    REFcombos = [1,1];
end


%% Loop over different variants of the classifier    
for variant_i = 1: size(REFcombos,1)    

    active_variant = REFcombos(variant_i,:);

    %% Create a table with all combinations of hyperparameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    activeparams = combinations( hyperparams.thresholds, hyperparams.iters);
    activeparams.Properties.VariableNames = {'thresholds', 'iters'};

%% Loop over datasets
for dataset_i = 1: size(datasets,2)

    dataset = datasets{dataset_i};
    load(dataset);
    
    no_splits = size(fulltraindata,1);
    no_classes = max(fulltrainlabels(1,:));

    full_results = cell(no_classes, no_splits);

    %% Loop over train-test splittings of a dataset
    for split_i = 1:no_splits
        % Load multi-class data
        mctraindata = squeeze(fulltraindata(split_i,:,:));
        mctrainlabels = squeeze(fulltrainlabels(split_i,:));
        mctestdata = squeeze(fulltestdata(split_i,:,:));
        mctestlabels = squeeze(fulltestlabels(split_i,:));

        %% Loop over classes
        for class_i = 1:no_classes % Only class_i data to be used as one-class training data

            % Create one-class labels
            trainlabels = zeros(size(mctrainlabels));
            trainlabels(mctrainlabels~=class_i) = -1;
            trainlabels(mctrainlabels==class_i) = 1;
            testlabels = zeros(size(mctestlabels));
            testlabels(mctestlabels~=class_i) = -1;
            testlabels(mctestlabels==class_i) = 1;

            %Standardize with respect to positive train data
            avr = mean(mctraindata(:, trainlabels==1)')';
            var = std(mctraindata(:, trainlabels==1)')';
            traindata = standardize(mctraindata, avr, var);
            testdata = standardize(mctestdata, avr, var);

            %Divide the training set into 5-fold for validation
            CVO = cvpartition(trainlabels,'KFold',validationfolds);
            Vtraindata=cell(validationfolds,1);
            Vtrainlabels=cell(validationfolds,1);
            Vtestdata=cell(validationfolds,1);
            Vtestlabels=cell(validationfolds,1);
            for  v= 1: validationfolds
                trIdx = CVO.training(v);
                teIdx = CVO.test(v);
                Vtraindatatemp=traindata(:,trIdx);
                Vtrainlabeltemp=trainlabels(trIdx);
                Vtestdatatemp=traindata(:,teIdx);
                
                %For training only postive data is used
                Vtraindatatemp=Vtraindatatemp(:, Vtrainlabeltemp==1);

                Vtraindata{v}=Vtraindatatemp;
                Vtestdata{v}=Vtestdatatemp;
                Vtestlabels{v}=trainlabels(teIdx);
            end
             
            % Optimize hyperparameters if needed
            if ~default
                [bestScore, bestSetting] = set_hyperparams(Vtraindata, Vtestdata, Vtestlabels, variants, active_variant, activeparams, fullparams.evaluation);  
            else
                bestSetting = activeparams;
            end

            % Do the final training and testing with optimized/default
            % hyperparameters
            result = train_and_test(traindata, trainlabels, testdata, testlabels, variants, active_variant, bestSetting);

            full_results{class_i,split_i} = result;

        end
    end
    % Save results
    save_results(variants, active_variant, datasets{dataset_i}, full_results, fullparams.evaluation);
end
end

% Gather all the results together
gather_results(datasets, variants, REFcombos, fullparams.evaluation);
