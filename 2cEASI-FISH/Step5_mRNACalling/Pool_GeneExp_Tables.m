strDir = 'Y:\Users\XSJ\WK_XSJ\Batch5\Repeat\Batch5_R1Resplit';
strFile_RegExp = '\\Spots_Codes_Z7\\\S*tbStats_GnExs-Z7.mat$';

clFns = FindFiles_RegExp(strFile_RegExp,strDir,true)';
nFC=length(clFns);
clTables = cell(nFC,1);
for nF=1:nFC
    strFn = clFns{nF};
    tbGE = load(strFn);
    clTables{nF}=tbGE.tbStats_GnExs;
end

tbStats_GnExs_Pool = vertcat(clTables{:});
%%
tbStats_GnExs_Pool_S = tbStats_GnExs_Pool;%simple version
clVars = tbStats_GnExs_Pool.Properties.VariableNames;
for n=7:12
    strVar = clVars{n};
    tbStats_GnExs_Pool_S.(strVar)= [tbStats_GnExs_Pool.(strVar).Count]';
end
%%
save([strDir '\tbStats_GnExs_Pool_Z7.mat'],'tbStats_GnExs_Pool','tbStats_GnExs_Pool_S','-v7.3');
