function gather_results(datasets, variants, REFcombos, evaluation)
% Gather results to a table and create a latex table

%Input: 
%dataset --> '1 x 6' cell containing dataset names
%variants --> A struct containing different variants of REF
%REFcombos --> A tables showing which combinations of operators and metrics were used
%evaluation --> The evaluation metric 

columnindex = 0;
isfile = 0;

table_eval = [];
table_std = [];

%% Loop over variants
for variant = 1:size(REFcombos,1)

    rowindex = 1;
    columnindex = columnindex+1;

    folder = "";

    operator = variants.operators{REFcombos(variant,1)};
    metric = variants.metrics{REFcombos(variant,2)};
    folder = sprintf( 'Results_REF_%s_%s', operator, metric);

    if ~exist(folder, 'dir') 
        columnindex = columnindex-1;
        isfile = false;
        continue;
    end
    isfile = true;

    sum = 0;
    stdsum = 0;
    files = 0;

    %% Loop over datasets
    for dataset_i = 1: size(datasets,2)

        dataset = datasets{dataset_i};
        targetclass = 1;
        filename_root = sprintf( '%s\\%s_targetclass', folder, dataset);
        filename = sprintf( '%s_%d.mat', filename_root, targetclass );

        %Go through all the classes as target classes
        while exist(filename, 'file') 

            load(filename, 'eval_mean', 'eval_std');
            table_eval(rowindex, columnindex) = eval_mean;
            sum = sum + eval_mean;
            files = files + 1;
            table_std(rowindex, columnindex) = eval_std;
            stdsum = stdsum + eval_std;
            targetclass = targetclass + 1;
            filename = sprintf( '%s_%d.mat', filename_root, targetclass );
            rowindex = rowindex+1;
        end

    end

    if isfile
        aver = sum/files;
        stdaver = stdsum/files;
        table_eval(rowindex, columnindex) =  aver;
        table_std(rowindex, columnindex) =  stdaver;
        rowindex = rowindex +2;
    end
end

resultfile = sprintf( 'Results.mat');
save( resultfile, 'table_eval', 'table_std', 'evaluation');

latexfile = sprintf( 'Latex.txt');
table_eval = table_eval *100;
table_std = table_std *100;

max_values = table_eval' == max(table_eval');
max_values = max_values';

% Save the results as a latex table
fileID = fopen(latexfile,'w');
for i = 1:size(table_eval, 1)
    for j = 1:size(table_eval, 2)
        latexprint(fileID, table_eval(i,j), table_std(i,j), max_values(i,j));
    end 
    fprintf( fileID, '\\\\ \n');
end
fclose(fileID);

end

function latexprint(fileID, eval, std, best)
    if best
        fprintf( fileID, sprintf( '& bf{%.1f$pm$%.1f}', eval, std));
    else
        fprintf( fileID, sprintf( '& %.1f$pm$%.1f', eval, std));
    end
end