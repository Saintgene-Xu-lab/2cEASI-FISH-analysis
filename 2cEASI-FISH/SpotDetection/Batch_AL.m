clDirs= {
    %'Y:\Users\GLQ\Data\ProbeInterCleaved\airLoc\0403';
    'Y:\Users\GLQ\Data\ProbeInterCleaved\airLoc\S1\Spots_v3';
    };

nDC=length(clDirs);
for nD=1:nDC
    strDir = clDirs{nD};
    strFn = [strDir '\Pars.ini'];
    try
    AIRLOCALIZE(strFn);
    catch
        warning(['Something is wrong, when processing file: ' strFn]);
    end
end