function [all_xls_data] = import_zdatareduction(current_folder,sample_name_string)
%IMPORT_ZDATAREDUCTION This function imports data from the U-Pb data
%reduction spreadsheet used in the Isotope Geology Laboratory. 
%   The function will read each excel file in the designated folder and
%   treat each file as its own unique sample. The first input is the file
%   path to the current folder (or directory) which contains the files you
%   wish to import. The second input is a string of sample names. This
%   string will only be used to name the fields. 
%
%   The output will be a structure of fields. Each field will be named 
%   using the sample name string and the data for that sample will be 
%   stored in a table for that field.
%
%   *An important note* this function matches sample names to files. The
%   files in your folder will automatically be sorted alphanumerically. If
%   you would like the files to be matched to sample names that are also
%   alphabetic, answer Y to the prompt. If you want sample names to be
%   matched to files in the order you listed them, respond N. 



prompt = 'Do you want the sample names to be matched to the files alphabetically? Y/N'
response=input(prompt, 's');
if response=='Y'
    sample_name_string=sort(sample_name_string)
else
end 
FilePattern = fullfile(current_folder, '*.xls');                            % find all of the excel files in the designated folder
theFiles = dir(FilePattern);                                                % print the directory of files in the folder 
for k = 1 : length(theFiles)                                                % iterate through the files 
    baseFileName = theFiles(k).name;                                        % construct the base file name 
    fullFileName = fullfile(theFiles(k).folder, baseFileName);              % construct the full file name 
    fprintf(1, 'Now reading %s\n', fullFileName);                           % print the name of the file currently being read 
  
[filepath, filename, ext] = fileparts(fullFileName);                        % store information about the file parts 

% Set specific parts of the excel file to specific variables.
opts = spreadsheetImportOptions("NumVariables", 15);                        % import 15 variables from excel 

% Specify sheet and range
opts.Sheet = "U-Pb Data Table Output";                                      % read only a specific sheet in the file 
opts.DataRange = "I8:W20";                                                  % import these cells 

% Specify column names and types
opts.VariableNames = ["Pb208Pb206_ratio", "Pb207Pb206_ratio", "Pb207Pb206_perr" , "Pb207U235_ratio" , "Pb207U235_perr" , "Pb206U238_ratio" , "Pb206U238_perr" , "corr_coeff" , "empty cells" , "Pb207Pb206_age" , "Pb207Pb206_sigma" , "Pb207U235_age", "Pb207U235_sigma", "Pb206U238_age", "Pb206U238_sigma"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Import the data
alldata = readtable(filename, opts, "UseExcel", false);                     % do not use excel headers 
clear opts                                                                  % clear the preferences saved under opts 
fieldname=sample_name_string(1,k);                                          % index through the specified field names saved under "samplestring" above

mystruct.(fieldname)=alldata;                                               % create a new field in a structure with the data from the current excel sheet
clear alldata                                                               % clear the temporary variable "alldata"
end                                                                         % end iteration through the files 

all_xls_data=mystruct
end

