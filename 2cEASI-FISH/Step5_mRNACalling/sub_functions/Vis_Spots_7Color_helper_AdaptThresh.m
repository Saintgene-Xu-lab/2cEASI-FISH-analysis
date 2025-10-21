function Vis_Spots_7Color_helper_AdaptThresh(clChans,stackSize,clFn_Locs,strFn_Img_Prefix,SE,bB0,vtThresh)
if(nargin<6)
    bB0=true;
end

nCC=length(clChans);
clLabels = cell(nCC,1);
clStats = cell(nCC,1);
for nC=1:nCC
    mask_img = false(stackSize([2 1 3]));
    label_img = zeros(stackSize([2 1 3]));
    tbLocs = readtable(clFn_Locs{nC});
    lgS = tbLocs{:,end}>vtThresh(nC);
    tbLocs = tbLocs(lgS,:);
    if(bB0)
        tbLocs{:,1:3}=tbLocs{:,1:3}+1;
    end
    matLocs = min(round(tbLocs{:,1:3}),repmat(stackSize,[size(tbLocs,1) 1]));
    matLocs = max(matLocs,1);
    vtLocs = sub2ind(size(mask_img),matLocs(:,2),matLocs(:,1),matLocs(:,3));
    nSC = length(vtLocs);
    label_img(vtLocs) = 1:nSC;
    label_img_D = imdilate(uint32(label_img),SE);%uint32(label_img);%
    clLabels{nC} = label_img_D;
    clStats{nC} = regionprops3(label_img_D,"VoxelIdxList","VoxelList");
    strFn_Sav=[strFn_Img_Prefix '_labelD_' clChans{nC} '.tif'];
    if(nSC<intmax("uint16"))
        writeTiffStack_UInt16(label_img_D,strFn_Sav);
    else
        writeTiffStack_UInt32(label_img_D,strFn_Sav);
    end
end

%%
matMatchPairs1_2 = IntersectSpots_v2(clLabels{1},clLabels{2},clStats{1},clStats{2});
matMatchPairs1_3 = IntersectSpots_v2(clLabels{1},clLabels{3},clStats{1},clStats{3});
matMatchPairs2_3 = IntersectSpots_v2(clLabels{2},clLabels{3},clStats{2},clStats{3});

%%autofluorescence
[Rm1,idxRm1_12,idxRm1_13] = intersect(matMatchPairs1_2(:,1),matMatchPairs1_3(:,1));
[Rm2,idxRm2_12,idxRm2_23] = intersect(matMatchPairs1_2(:,2),matMatchPairs2_3(:,1));
[Rm3,idxRm3_13,idxRm3_23] = intersect(matMatchPairs1_3(:,2),matMatchPairs2_3(:,2));
%%
Rm1_f = unique([Rm1;matMatchPairs1_2(idxRm2_12,1);matMatchPairs1_3(idxRm3_13,1)]);
Rm2_f = unique([Rm2;matMatchPairs1_2(idxRm1_12,2);matMatchPairs2_3(idxRm3_23,1)]);
Rm3_f = unique([Rm3;matMatchPairs1_3(idxRm1_13,2);matMatchPairs2_3(idxRm2_23,2)]);

%%
matMatchPairs1_2_f = cleanPairs(matMatchPairs1_2,Rm1_f,Rm2_f);
matMatchPairs1_3_f = cleanPairs(matMatchPairs1_3,Rm1_f,Rm3_f);
matMatchPairs2_3_f = cleanPairs(matMatchPairs2_3,Rm2_f,Rm3_f);

clIdx = cell(7,1);
idx = setdiff(1:size(clStats{1},1),unique([Rm1_f;matMatchPairs1_2_f(:,1);matMatchPairs1_3_f(:,1)]));
clIdx{1} = cell2mat(clStats{1}.VoxelIdxList(idx));
idx = setdiff(1:size(clStats{2},1),unique([Rm2_f;matMatchPairs1_2_f(:,2);matMatchPairs2_3_f(:,1)]));
clIdx{2} = cell2mat(clStats{2}.VoxelIdxList(idx));
idx = setdiff(1:size(clStats{3},1),unique([Rm3_f;matMatchPairs1_3_f(:,2);matMatchPairs2_3_f(:,2)]));
clIdx{3} = cell2mat(clStats{3}.VoxelIdxList(idx));
idx = matMatchPairs1_2_f(:,2);
clIdx{4} = cell2mat(clStats{2}.VoxelIdxList(idx));
idx = matMatchPairs1_3_f(:,2);
clIdx{5} = cell2mat(clStats{3}.VoxelIdxList(idx));
idx = matMatchPairs2_3_f(:,1);
clIdx{6} = cell2mat(clStats{2}.VoxelIdxList(idx));
clIdx{7} = unique([cell2mat(clStats{1}.VoxelIdxList(Rm1_f));cell2mat(clStats{2}.VoxelIdxList(Rm2_f));cell2mat(clStats{3}.VoxelIdxList(Rm3_f))]);
%%
imgLabel_f = zeros(stackSize([2 1 3]),'uint8');
for n=1:7
    imgLabel_f(clIdx{n}) = n;
%     imgLabel_s = zeros(Header.sizes([2 1 3]),'uint8');
%     imgLabel_s(clIdx{n}) = 255;
%     strFn_Sav=[strFn_Img_Prefix '_lbCode' num2str(n) '.tif'];
%     writeTiffStack_UInt8(imgLabel_s,strFn_Sav);
end
strFn_Sav=[strFn_Img_Prefix '_lbCode_All.tif'];
writeTiffStack_UInt8(imgLabel_f,strFn_Sav);