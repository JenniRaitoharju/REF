function [bestScore, bestSetting] = set_hyperparams(Vtraindata, Vtestdata, Vtestlabels, variants, active, params, evaluation)
%Cross-validation to select optimal hyperparameters for a variant. 

%Input: 
%Vtraindata --> 'Nfolds x 1' cell containing 'Nfolds' sets of positive 
    %training data to be used for training in hyperparameters setting
%Vtestdata --> 'Nfolds x 1' cell containing 'Nfolds sets of positive and 
    %negative training data to be used for testing in hyperparameters setting
%Vtestlabels --> 'Nfolds x 1' cell containing 'Nfolds sets of positive and 
    %negative training labels to be used for testing in hyperparameters setting
%variants --> A struct containing different variants of REF
%active --> '2 x 1' vector showing which variant is currently used
%params --> A table containing all hyperparameters combos
%evaluation --> The evaluation metric to be used in hyperparameter
    %selection
%
%Output:
%bestScore --> Best evaluation score (average over validation folds) achieved
%bestSetting --> A table containing the best hyperparameter combo

bestScore = -1;

%% Loop over all parameter combos
for combo_i=1:size(params,1) 

    validationfolds = size(Vtraindata,1);
                    
    validation_score = 0;
    %% Loop over validation folds
    for i=1:validationfolds 

        operator = variants.operators{active(1)};
        metric = variants.metrics{active(2)};
        threshold = params.thresholds(combo_i);
        iter = params.iters(combo_i);
        results = apply_REF(operator, metric, iter, threshold, Vtraindata{i}, Vtestdata{i}, Vtestlabels{i});
      
        if strcmp(evaluation,'f1')
           validation_score = validation_score + results.f1;
        else                  
           validation_score = validation_score + results.gmean;
        end
        
    end %validation folds
    validation_score = validation_score/validationfolds;

    if validation_score > bestScore
        bestScore = validation_score;
        bestSetting = params(combo_i,:);
    end
end
 