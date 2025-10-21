function [clFn_O,vtCounter] = SortFnByCounter(clFn_I,strCounterExp)

nFileCount = length(clFn_I);
vtCounter = zeros(nFileCount,1);
for nFile = 1:nFileCount
    strFn = clFn_I{nFile};
    strCounter = regexp(strFn,strCounterExp,'tokens');
    vtCounter(nFile) = str2double(strCounter{1});
end

[vtCounter,Indx] = sort(vtCounter);
clFn_O = clFn_I(Indx);

