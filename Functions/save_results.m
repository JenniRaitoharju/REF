function save_results(variants, active, dataset, full_results, evaluation)
%Save results for the active dataset and REF variant 

%Input: 
%variants --> A struct containing different variants of REF
%active --> '2 x 1' vector showing which variant is currently used
%dataset --> Active dataset as a string
%full_results --> 'Nclasses x Nsplits' cell containing results
%evaluation --> The evaluation metric as a string
   
operator = variants.operators{active(1)};
metric = variants.metrics{active(2)};
folder = sprintf( 'Results_REF_%s_%s', operator, metric);

if ~exist(folder, 'dir')
    mkdir(folder)
end

%Gather results over all classed and train-test splits
for class_i = 1:size(full_results,1)
    eval_mat = [];
    for split_i = 1:size(full_results,2) %Traintest splits 
        results =  full_results{class_i, split_i};
        if strcmp(evaluation, 'gmean')
            eval_mat = [eval_mat results.gmean];
        elseif strcmp(evaluation, 'f1')
            eval_mat = [eval_mat results.f1];
        end
    end
    eval_mean = mean(eval_mat); %Mean over splits
    eval_std = std(eval_mat); 
    save(strcat(folder, '\', dataset,'_targetclass_',num2str(class_i), '.mat'));
end
