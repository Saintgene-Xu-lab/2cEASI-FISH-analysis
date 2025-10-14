strDir_P = 'Y:\Users\GLQ\Data\ProbeInterCleaved\airLoc';
Res_xyz = [0.09 0.09 0.4];%[0.12 0.12 0.36];%[0.09 0.09 0.36];%Header.spacedirections_matrix([1 5 9]);
Radius = [0.6 0.6 1.8]; %um [0.4 0.4 1.8];
R_Pix = floor(Radius./Res_xyz); %convert um to pixel
[X, Y, Z] = ndgrid(-R_Pix(2):R_Pix(2), -R_Pix(1):R_Pix(1), -R_Pix(3):R_Pix(3));
SE = (X/R_Pix(1)).^2 + (Y/R_Pix(2)).^2 + (Z/R_Pix(3)).^2 <= 1;
clChans = {'C1';'C2'};
strFn_Exp_SpLocs ='ch(\d)_Z7_AlignCh.csv$';
strFn_Exp_ImgRef ='_Ref_ch2.tif$';
clDirs = FindSubDirs_RegExp('S1', strDir_P, true)';%)|(S1)|(0403)
nDC = length(clDirs);
% parpool('local', 8);

tic
% parfor nD=1:nDC
for nD=1:nDC
%     try
        Vis_Spots_3Color_1Dir(clDirs{nD},strFn_Exp_SpLocs,strFn_Exp_ImgRef,SE,clChans)
%     catch
%         warning(['error in processing dir: ' clDirs{nD}]);
%     end
end
toc

function Vis_Spots_3Color_1Dir(strDir,strFn_Exp_SpLocs,strFn_Exp_ImgRef,SE,clChans)
[stackSize,clFn_Locs,strFn_Img_Prefix] = GetImgInfoFromDir(strDir,strFn_Exp_SpLocs,strFn_Exp_ImgRef);
Vis_Spots_3Color_helper(clChans,stackSize,clFn_Locs,strFn_Img_Prefix,SE,true);
end

function [stackSize,clFn_Locs,strFn_Img_Prefix] = GetImgInfoFromDir(strDir,strFn_Exp_SpLocs,strFn_Exp_ImgRef)
clFn_Locs = FindFiles_RegExp(strFn_Exp_SpLocs, strDir, false)';
clFn_Locs = SortFnByCounter(clFn_Locs,strFn_Exp_SpLocs);
clFn_ImgRef = FindFiles_RegExp(strFn_Exp_ImgRef, strDir, false)';
strFn_Img_ref = clFn_ImgRef{1};
imgInfo = imfinfo(strFn_Img_ref);
stackSize = [imgInfo(1).Width imgInfo(1).Height numel(imgInfo)];
strDir_Sav = [fileparts(strFn_Img_ref) '\Spots_Codes_80000_Z7'];
if exist(strDir_Sav,'dir')==0
    mkdir(strDir_Sav);
end
strFn_Img_Prefix = strrep(strFn_Img_ref(1:end-length(strFn_Exp_ImgRef)+1),strDir,strDir_Sav);
end
