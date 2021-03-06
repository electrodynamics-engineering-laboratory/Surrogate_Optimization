function SurrogateModelToolboxTest(data_file, Num_Iterations, SBOModels, Samp_Tech, Init_Design, Num_Start_Pnts, Start_Point)
%{
Inputs:
    Matlab Surrogate Model Module Test
    data_file: File name of function that establishes upper and lower
            limits, object function to be used by model, indices of integer
            variables, indices of continuous variables, and the problem dimension.
            See datainput_SOBModelProject.m for firmer example of syntax required.
    Num_Iterations: Number of iterations to be used by
                    SurrogateModelModule_v1.m
    SBOModels: Array of strings indicating the models to be tested with given
                inputs.
    Samp_Tech: String indicating the sampling technique to be used by model
    Init_Design: String indicating the initial design to be used by model
    Num_Start_Pnts: Integer indicating the number of starting points to be
                    used by the model
    Start_Point: An MxD matrix of points to be used by the model as initial
                    points where D is the dimension and M is an integer
                    greater than or equal to one.
Outputs:
  ResultOutput: An array of structures containing data output by each
                individual model

Joe Haun
Dr. Mohamed Salem
3-20-19

%}

%%
%If not arguments are given, load the necessary values from a previous run

if nargin == 0
    data_file = ["datainput_SBOModel1" "datainput_SBOModel2", "datainput_Branin", "datainput_Shubert"];
    SBOModels = ["KRIGexp0" "KRIGexp1" "KRIGexp2" "KRIGgexp0" "KRIGgexp1" "KRIGgexp2" "KRIGgauss0" "KRIGgauss1" "KRIGgauss2" ...
        "KRIGlin0" "KRIGlin1" "KRIGlin2" "KRIGspline0" "KRIGspline1" "KRIGspline2" "KRIGsphere0" "KRIGsphere1" "KRIGsphere2" ...
        "KRIGcub0" "KRIGcub1" "KRIGcub2"];
    Samp_Tech = ["CAND", "SURFmin", "EImax", "SCOREmin"];
    Init_Design = ["LHS", "SLHD", "SPACEFIL"];
    Num_Iterations = 200;
    
end

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

%Variables to allow choice of model, design, and sampling technique to be
%used for testing purposes

MinDesignChoice = 1;
MaxDesignChoice = max(size(Init_Design)); 

MinSamplingTechnique = 1;
MaxSamplingTechnique = max(size(Samp_Tech));

MinSBOModels = 1;
MaxSBOModels = max(size(SBOModels));

MinFileChoice = 1;
MaxFileChoice = max(size(data_file));

%Initialize ResultsOutput structure array and ErrorLog array

TestScalingFactor = 1;
StructureLengths = TestScalingFactor*(MaxDesignChoice - MinDesignChoice + 1)*(MaxSamplingTechnique - MinSamplingTechnique + 1)*(MaxSBOModels - MinSBOModels + 1);
ResultOutput = struct();
ErrorLog = struct();

%Expand ResultOutput array to prevent excessive slowdown when running tests
if exist('Start_Point', 'var') %If there is a starting point given, populate the dummy structure with a StartingPoint field to match output structure
    BlankStruct = struct('xlow',[],'xup',[],'objfunction',[],'integer',[],'continuous',[], 'dim',[], ...
    'S', [], 'Y', [], 'fevaltime', [], 'fbest', [], 'xbest', [],'Ymed',[],'Problem',[],'SurrogateModel', ...
    [],'SamplingTechnique', [], 'InitialDesign',[],'NumberStartPoints',[],'StartingPoint',[], 'TotalTime', []);
else %If no starting point given, remove the StartingPoint field to match output structure
    BlankStruct = struct('xlow',[],'xup',[],'objfunction',[],'integer',[],'continuous',[], 'dim',[], ...
    'S', [], 'Y', [], 'fevaltime', [], 'fbest', [], 'xbest', [],'Ymed',[],'Problem',[],'SurrogateModel', ...
    [],'SamplingTechnique', [], 'InitialDesign',[],'NumberStartPoints',[], 'TotalTime', []);
end

for j = MinFileChoice:MaxFileChoice
    eval(strcat("ResultOutput.",data_file(j),"= BlankStruct;"))
    eval(strcat("ErrorLog.",data_file(j)," = [];")); %Create blank arrays in ErrorLog fields for each particular data file
end
%%

for ITERATIONS = 1:TestScalingFactor
    for k = MinSamplingTechnique:MaxSamplingTechnique
        for j = MinDesignChoice:MaxDesignChoice
            for i = MinSBOModels:MaxSBOModels
                for fileChoice = MinFileChoice:MaxFileChoice
                    InternalErrorStringFront = strcat(string(Samp_Tech(k)), ":", string(Init_Design(j)), ":", string(SBOModels(i)), ":");
                    try %Enter try catch loop to prevent tests that fail from ending run of the program
                        SurrogateModelModule_v1(char(data_file(fileChoice)), Num_Iterations, char(SBOModels(i)), char(Samp_Tech(k)), char(Init_Design(j)), Num_Start_Pnts, Start_Point);
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
%%
OutputLocation = "TestingOutputs/";
TestName = "NOSTRT_";
DateString = char(datetime);
DateString(DateString == ' ') = '_';
DateString(DateString == ':') = '-';
OutFile = strcat(OutputLocation,TestName,DateString,'_','ToolboxTestResults.mat');
save(OutFile, 'ResultOutput', 'ErrorLog' );
if ispc
    pause(60);
    system('shutdown -s');
end

end