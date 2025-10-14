function FullSubDirs = FindSubDirs_RegExp(subdir_regexp, directory, isRecursive,nRecurseLevel)
% check inputs
if(nargin<2)
    error('SG:FindSubDirs_RegExp:NotEnoughInputs','You must define entry and directory.');
end
if(nargin<3)
    isRecursive = false;
end

if(nargin<4)
    nRecurseLevel = inf;
end

if(~isdir(directory))
    error('SG:FindSubDirs_RegExp:ErrorDir','No such directory found.');
end;

d = dir(directory);

FullSubDirs = {};
numMatches = 0;

nRecurseLevel = nRecurseLevel-1;
if(nRecurseLevel == 0)
    isRecursive = false;
end

for i=1:length(d)
    a_name = d(i).name;
    a_dir = d(i).isdir;

    if(a_dir && ~isempty(regexp(fullfile(directory,a_name),subdir_regexp,'start')))
        numMatches = numMatches + 1;
        FullSubDirs{numMatches} = fullfile(directory, a_name); %#ok<AGROW>
        % if recursive is required
    elseif(isRecursive && a_dir && ~strcmp(a_name,'.') && ~strcmp(a_name,'..'))
        FullSubDirs = [FullSubDirs  FindSubDirs_RegExp(subdir_regexp, fullfile(directory,a_name), true,nRecurseLevel)]; %#ok<AGROW>
        numMatches = length(FullSubDirs);
    end
end
