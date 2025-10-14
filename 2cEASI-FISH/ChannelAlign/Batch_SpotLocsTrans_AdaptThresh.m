strDir_P = 'Y:\Users\GLQ\Data\ProbeInterCleaved\airLoc';
clDirs = FindSubDirs_RegExp('0403', strDir_P, true)';
strFn_Exp_SpLocs ='_ch(\d)\_Z3.txt$';
nDC = length(clDirs);
for nD=1:nDC
    strDir = clDirs{nD};
    clFns = FindFiles_RegExp(strFn_Exp_SpLocs, strDir, true)';
    [clFns,vtCounter] = SortFnByCounter(clFns,strFn_Exp_SpLocs);
    nFC = length(clFns);
    vtThresh = [1000 1000];%[26000 10000];
    for nF=1:nFC
        strFn_SpLocs = clFns{nF};
        disp(['Processing file: ' strFn_SpLocs]);
        strDir_P = fileparts(strFn_SpLocs);
        strFn_Exp_Mat=['_ch' num2str(vtCounter(nF)) '0GenericAffine.mat$'];
        clFns_Mat = FindFiles_RegExp(strFn_Exp_Mat, strDir_P, false)';
        bHasMat = ~isempty(clFns_Mat);
        if(bHasMat)
            strFn_antsMat=clFns_Mat{1};
        else
            strFn_antsMat =[];
        end

        tbSpLocs = readtable(strFn_SpLocs);
        lgSel = tbSpLocs.integratedIntensity >vtThresh(nF);
        tbSpLocs_Sel = tbSpLocs(lgSel,:);
        nSC = size(tbSpLocs_Sel,1);
        matSpLocs = [tbSpLocs_Sel{:,[2 1 3]} ones(nSC,1)];
        if(bHasMat)
            imgMat = antsMat4_4(strFn_antsMat);
            matSpLocs = (imgMat\matSpLocs')'; %please ref to the manual of antsApplyTransformsToPoints command
        end

        tbSpLocs_t = array2table([matSpLocs(:,[1:3 4 4]) tbSpLocs_Sel{:,4}],'VariableNames',{'x','y','z','t','c','intensity'});
        strFn_SpLocs_Sav = [strFn_SpLocs(1:end-4) '_AlignCh.csv'];
        writetable(tbSpLocs_t,strFn_SpLocs_Sav);
    end
end
