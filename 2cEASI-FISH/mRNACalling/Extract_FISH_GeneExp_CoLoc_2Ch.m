function Extract_FISH_GeneExp_CoLoc_2Ch(strFn_CellMasks,strFn_lbCodes,clGenes,strCellID,vtVoxelSz,vtBd)
if(nargin==0)
    strFn_CellMasks = 'Y:\Users\XSJ\Reg_WK\Reg2g\16bit\Splots_Codes\20240812_zstack_192-3-R1-neuron39_2024_08_13__09_31_06_630_filtermask.tif';
    strFn_lbCodes = 'Y:\Users\XSJ\Reg_WK\Reg2g\16bit\Splots_Codes\20240812_zstack_192-3-R1-neuron39_2024_08_13__09_31_06_630_C2_lbCode_All.tif';
    clGenes={'Cux2','Satb2','Eef2','Vglut1','Fezf2','Gad1'};
    strCellID = [];
    vtVoxelSz = [0.09 0.09 0.36];%in um
    vtBd = [10 -10];
end

nGC=length(clGenes);

imgCellMasks = readTiffStack(strFn_CellMasks);
[nH,nW,nZ] = size(imgCellMasks);
idxH = vtBd(1):(nH+vtBd(2));
idxW = vtBd(1):(nW+vtBd(2));
idxZ = vtBd(1):(nZ+vtBd(2));
imgCellMasks = imgCellMasks(idxH,idxW,idxZ);

imgCodes = readTiffStack(strFn_lbCodes);
imgCodes = imgCodes(idxH,idxW,idxZ);
%imgCellMasks(imgCellMasks>0)=1;%specific for WK's project, one cell mask per file
tbStatsCell = regionprops3(imgCellMasks,"Volume","Centroid","VoxelIdxList","SurfaceArea");
nCC = size(tbStatsCell,1);
clStatsCell = cell(nGC+2,1);
clStatsCell{1} = table(string(strCellID),vtVoxelSz,'VariableNames',{'CID','VoxSz'});
clStatsCell{2}=tbStatsCell;
for nG = 1:nGC
    bwCode = imgCodes==nG;
    lbSpots = bwlabeln(bwCode);
    tbStatsCode = regionprops3(lbSpots,"Centroid");
    clGnExs = cell(nCC,1);
    for nC=1:nCC
        voxIdx = tbStatsCell.VoxelIdxList{nC};
        lbSpots_C = lbSpots(voxIdx);
        idxSpots = unique(lbSpots_C(lbSpots_C>0));
        stGnEx.Count = length(idxSpots);
        stGnEx.Locs = tbStatsCode.Centroid(idxSpots,:);
        clGnExs{nC} = stGnEx;
    end
    tbGnExs = cell2table(clGnExs,'VariableNames',clGenes(nG));
    clStatsCell{nG+2}=tbGnExs;
end
tbStats_GnExs = horzcat(clStatsCell{2:end});
%%
% [H,W,Z]=size(imgCellMasks);
% SE = strel('sphere',4);
% for nC=1:nCC
%     codeImg_Cell = zeros(H,W,Z,'uint8');
%     for nG=1:nGC
%         stGnExp = tbStats_GnExs.(clGenes{nG});
%         matLocs = round(stGnExp.Locs);
%         vtLocs = sub2ind([H,W,Z],matLocs(:,2),matLocs(:,1),matLocs(:,3));
%         codeImg_Cell(vtLocs) = nG;
%     end
%     codeImg_Cell = imdilate(codeImg_Cell,SE);
%     strFn_Sav=[strFn_CellMasks(1:end-4) '_Cell_' num2str(nC) '.tif'];
%     writeTiffStack_UInt8(uint8(codeImg_Cell),strFn_Sav);
% end
%%
save([fileparts(strFn_lbCodes) '\' strCellID '-tbStats_GnExs-Zs.mat'],'tbStats_GnExs','-v7.3');