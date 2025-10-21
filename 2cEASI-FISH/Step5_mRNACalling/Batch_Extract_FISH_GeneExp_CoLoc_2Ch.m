strDir = 'Y:\Users\GLQ\Data\ProbeInterCleaved\airLoc\0403\Spots_Mix\3Ch_2_4_4L\Spots_Codes_Z7_110000';
strFn_Exp_Mask ='_smoothmask.tif$';
strFn_Exp_Code = '\\\S*_lbCode_All.tif';
% clGenes={'C2', 'C4', 'C24'};
clGenes={'C2', 'C4','C4L', 'C24','C24L','C44L','C244L'};
vtVoxelSz = [0.09 0.09 0.4]; %50x
% Res_xyz = [0.12 0.12 0.36]; 40x

clFns_Mask = FindFiles_RegExp(strFn_Exp_Mask, strDir, false)';
nMC = length(clFns_Mask);
for nM=1:nMC
    Extract_FISH_GeneExp_1File_Helper(clFns_Mask{nM},strFn_Exp_Code,strFn_Exp_Mask,clGenes,vtVoxelSz)
end

function Extract_FISH_GeneExp_1File_Helper(strFn_Mask,strFn_Exp_Code,strFn_Exp_Mask,clGenes,vtVoxelSz)
[strDir_P,strFn] = fileparts(strFn_Mask);
strCellID = strFn(1:end-length(strFn_Exp_Mask)+1);
clFns_Code = FindFiles_RegExp(strFn_Exp_Code, strDir_P, true)';
nFC = length(clFns_Code);
for nF=1:nFC
    strFn_Code = clFns_Code{nF};
    Extract_FISH_GeneExp_CoLoc_2Ch(strFn_Mask,strFn_Code,clGenes,strCellID,vtVoxelSz,[40 -40]);
end
end