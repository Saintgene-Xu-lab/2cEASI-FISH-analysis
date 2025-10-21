function matMatchePairs = IntersectSpots_v2(imgLabelA,imgLabelB,tbStatsA,tbStatsB)

% tbStatsA = regionprops3(imgLabelA,"VoxelIdxList","VoxelList");
% tbStatsB = regionprops3(imgLabelB,"VoxelIdxList","VoxelList");

lgA = imgLabelA>0;
lgB = imgLabelB>0;

tbStatsAB = regionprops3(lgA&lgB,"VoxelIdxList");

nSC_AB = size(tbStatsAB,1);
clMatchPairs = cell(nSC_AB,1);

imgLabelA_tmp = zeros(size(imgLabelA),'like',imgLabelA);
imgLabelB_tmp = zeros(size(imgLabelB),'like',imgLabelB);
for nS=1:nSC_AB
    VoxelIdx = tbStatsAB.VoxelIdxList{nS};

    idxLabelA_S = unique(imgLabelA(VoxelIdx),"sorted");%%subregion
    idxLabelB_S = unique(imgLabelB(VoxelIdx),"sorted");

    nSC_AS = numel(idxLabelA_S);
    nSC_BS = numel(idxLabelB_S);

    if(nSC_AS==1&&nSC_BS==1)
        clMatchPairs{nS} = [idxLabelA_S idxLabelB_S];
    else
        VoxelPos= cell2mat([tbStatsA.VoxelList(idxLabelA_S');tbStatsB.VoxelList(idxLabelB_S')]);
        posMin =min(VoxelPos);
        posMax =max(VoxelPos);

        XX=posMin(1):posMax(1);
        YY=posMin(2):posMax(2);
        ZZ=posMin(3):posMax(3);

        for nS_S=1:nSC_AS
            idx = idxLabelA_S(nS_S);
            imgLabelA_tmp(tbStatsA.VoxelIdxList{idx})=nS_S;
        end

        for nS_S=1:nSC_BS
            idx = idxLabelB_S(nS_S);
            imgLabelB_tmp(tbStatsB.VoxelIdxList{idx})=nS_S;
        end

        imgLabelA_S = imgLabelA_tmp(YY,XX,ZZ);
        imgLabelB_S = imgLabelB_tmp(YY,XX,ZZ);

        matMatchePairs_S = MatchSpots(imgLabelA_S,imgLabelB_S);
        clMatchPairs{nS}=[idxLabelA_S(matMatchePairs_S(:,1)) idxLabelB_S(matMatchePairs_S(:,2))];

        imgLabelA_tmp(YY,XX,ZZ) = 0;
        imgLabelB_tmp(YY,XX,ZZ) = 0;
    end
end

matMatchePairs = cell2mat(clMatchPairs);
end


function matMatchPairs = MatchSpots(imgLabelA,imgLabelB)
idxLabelA = unique(imgLabelA(imgLabelA>0),'sorted');
idxLabelB = unique(imgLabelB(imgLabelB>0),'sorted');
nSC_A = numel(idxLabelA);
nSC_B = numel(idxLabelB);
if(nSC_A==1&&nSC_B==1)
    matMatchPairs = [idxLabelA idxLabelB];
else
%     nSC = min(nSC_A,nSC_B);
%     matMatchPairs = zeros(nSC,2);

    matMatchScore = zeros(nSC_A,nSC_B,2);

    tbStatsA = regionprops3(imgLabelA,imgLabelB,"VoxelValues");
    tbStatsB = regionprops3(imgLabelB,imgLabelA,"VoxelValues");

    for nS=1:nSC_A
        tbVals = tabulate(tbStatsA.VoxelValues{nS});
        [~,ia,ib] = intersect(idxLabelB,tbVals(:,1),'stable');
        matMatchScore(nS,ia,1)=tbVals(ib,3);
    end

    for nS=1:nSC_B
        tbVals = tabulate(tbStatsB.VoxelValues{nS});
        [~,ia,ib] = intersect(idxLabelA,tbVals(:,1),'stable');
        matMatchScore(ia,nS,2)=tbVals(ib,3);
    end

    matMatchScore_T = sum(matMatchScore,3);
    matMatchPairs = matchpairs(matMatchScore_T,0,'max');
%     for nS=1:nSC
%         [~,I]=max(matMatchScore_T,[],"all");
%         [r,c]=ind2sub([nSC_A,nSC_B],I);
%         matMatchScore_T(r,:)=0;
%         matMatchScore_T(:,c)=0;
%         matMatchPairs(nS,:)=[r,c];
%     end
end
end

