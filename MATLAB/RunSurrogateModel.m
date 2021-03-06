function [ResultOutput, ErrorLog] = RunSurrogateModel(data_file, SBOModel, Samp_Tech, Init_Design, Num_Iterations, Num_Start_Pnts, Start_Point)
%{
    This function is used by the Electrodynamics Engineering Laboratory GUI
    to run the Surrogate Optimization Module given the parameters specified
    in the GUI. Any secondary parameters that are not necessary will be
    taken care of by the Surrogate Optimization Module functions if the
    user decides not to supply them. 
    
Inputs:
    data_file - File name of function that establishes upper and lower
            limits, object function to be used by model, indices of integer
            variables, indices of continuous variables, and the problem dimension.
            See datainput_SBOModel1.m for firmer example of syntax required.

    Num_Iterations - Number of iterations to be used by
                    SurrogateModelModule_v1.m

    SBOModels - Array of strings indicating the models to be tested with given
                inputs.

    Samp_Tech - String indicating the sampling technique to be used by model
   
    Init_Design - String indicating the initial design to be used by model
    
    Num_Start_Pnts - Integer indicating the number of starting points to be
                    used by the model
     
    Start_Point - An MxD matrix of points to be used by the model as initial
                    points where D is the dimension and M is an integer
                    greater than or equal to one.
Outputs:
    ResultOutput - An array of structures containing data output by each
                individual model (Please use fieldnames function to
                determine specific fields as they can change depending on
                inputs given)

Author: Joe Haun
        Dr. Mohamed Salem
Date:   June 25, 2019
    
%}

%%
% Check given arguments for accuracy or existence. If not existent, assume
% default values
if ~exist('data_file', 'var')
   data_file = "datainput_Branin"; 
end

if ~exist('SBOModel','var')
   SBOModel = "KRIGexp0";
end

if ~exist('Samp_Tech','var')
    Samp_Tech = "CAND";
end

if ~exist('Init_Design', 'var')
    Init_Design = "LHS";
end

if ~exist('Num_Iterations','var')
    Num_Iterations = [];
end

if ~exist('Start_Point', 'var')
    Num_Start_Pnts = 0;
    Start_Point = [];
end

%%
% Prepare output variables
ResultOutput = struct(); %Declare blank structs to be expanded
ErrorLog = struct();
if exist('Start_Point', 'var') %If there is a starting point given, populate the dummy structure with a StartingPoint field to match output structure
    BlankStruct = struct('xlow',[],'xup',[],'objfunction',[],'integer',[],'continuous',[], 'dim',[], ...
    'S', [], 'Y', [], 'fevaltime', [], 'fbest', [], 'xbest', [],'Ymed',[],'Problem',[],'SurrogateModel', ...
    [],'SamplingTechnique', [], 'InitialDesign',[],'NumberStartPoints',[],'StartingPoint',[], 'TotalTime', []);
else %If no starting point given, remove the StartingPoint field to match output structure
    BlankStruct = struct('xlow',[],'xup',[],'objfunction',[],'integer',[],'continuous',[], 'dim',[], ...
    'S', [], 'Y', [], 'fevaltime', [], 'fbest', [], 'xbest', [],'Ymed',[],'Problem',[],'SurrogateModel', ...
    [],'SamplingTechnique', [], 'InitialDesign',[],'NumberStartPoints',[], 'TotalTime', []);
end

for j = 1:max(size(data_file))  
    eval(strcat("ResultOutput.",data_file(j),"= BlankStruct;")) %For all data files given, populate with BlankStruct variable to prepare for expansion by Module
    eval(strcat("ErrorLog.",data_file(j)," = [];")); %Create blank arrays in ErrorLog fields for each particular data file
end

%%
% 
for k = 1:max(size(Samp_Tech))
        for j = 1:max(size(Init_Design))
            for i = 1:max(size(SBOModel))
                for fileChoice = 1:max(size(data_file))
                    InternalErrorStringFront = strcat(string(Samp_Tech(k)), ":", string(Init_Design(j)), ":", string(SBOModel(i)), ":");
                    try %Enter try catch loop to prevent tests that fail from ending run of the program
                        SurrogateModelModule_v1(char(data_file(fileChoice)), Num_Iterations, char(SBOModel(i)), char(Samp_Tech(k)), char(Init_Design(j)), Num_Start_Pnts, Start_Point);
                        TempRes = load("Results.mat"); %Load Results file from SurrogateModelModule_v1 
                        eval(strcat("ResultOutput.",data_file(fileChoice),"= [ResultOutput.", data_file(fileChoice)," TempRes.Data];")) %Save Results.mat data to ResultOutput array of structs      
                        InternalSuccessString = strcat(InternalErrorStringFront, "OK"); %Create error log success string and append to error log
                        eval(strcat("ErrorLog.",data_file(fileChoice),"=[","ErrorLog.",data_file(fileChoice)," ", "InternalSuccessString" ,"];"));
                        delete("Results.mat")
                    catch ME
                        InternalFailString = strcat(InternalErrorStringFront,string(ME.message)); %Create error log message and append to log
                        eval(strcat("ErrorLog.",data_file(fileChoice),"=[","ErrorLog.",data_file(fileChoice)," ", "InternalFailString" ,"];"));
                        if exist("Results.mat")
                            delete("Results.mat")
                        end
                    end
                end
            end
        end
end
    
end