function matPairs_c = cleanPairs(matPairs,Rm1,Rm2)
[~,ia]=setdiff(matPairs(:,1),Rm1);
matPairs_c = matPairs(ia,:);
[~,ia]=setdiff(matPairs_c(:,2),Rm2);
matPairs_c=matPairs_c(ia,:);
end