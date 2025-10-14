strDir = 'W:\2411\LXL\XSJ\Rnd1';
strFile_RegExp = 'tbStats_GnExs_Pool_Z7.mat$';

clFns = FindFiles_RegExp(strFile_RegExp,strDir,true)';
nFC=length(clFns);
clTables = cell(nFC,2);
for nF=1:nFC
    strFn = clFns{nF};
    tbGE = load(strFn);
    clTables{nF,1}=tbGE.tbStats_GnExs_Pool;
    clTables{nF,2}=tbGE.tbStats_GnExs_Pool_S;
end

tbStats_GnExs_Pool_Rnd = vertcat(clTables{:,1});
tbStats_GnExs_Pool_S_Rnd = vertcat(clTables{:,2});
%%
save([strDir '\tbStats_GnExs_Rnd_Z7.mat'],'tbStats_GnExs_Pool_Rnd','tbStats_GnExs_Pool_S_Rnd','-v7.3');
