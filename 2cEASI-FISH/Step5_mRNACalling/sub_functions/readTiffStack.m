function ImgData = readTiffStack(strTiffFilename,idx_S,idx_E)
%Use the Tiff Library to read Tiff Stack, it is much faster than imread
%function

%Saintgene 2013

if(nargin<2)
    idx_S = 1;
end
if(nargin<3)
    idx_E = inf;
end

% InfoImage = imfinfo(strTiffFilename);
% wImage = InfoImage(1).Width;
% hImage = InfoImage(1).Height;
% NumberImages = length(InfoImage);

% switch(BitDepth)
%     case 16
%         strFormat = 'uint16';
%     case 32
%         strFormat = 'double';
%     otherwise
%         strFormat = 'double';
% end
warning('off','all');
TifLink = Tiff(strTiffFilename, 'r');
dSampFmt = TifLink.getTag('SampleFormat');
BitDepth = TifLink.getTag('BitsPerSample');
[hImage,wImage]=size(TifLink.read());

TifLink.setDirectory(1);
NumberImages = 1;
while ~TifLink.lastDirectory()
    TifLink.nextDirectory();
    NumberImages = NumberImages + 1;
end

idx_S = max(1,idx_S);
idx_E = min(idx_E,NumberImages);

switch(BitDepth)
    case 1
        if(dSampFmt == Tiff.SampleFormat.UInt)
            strFormat = 'logical';
        else
            strFormat = 'uint8';
        end
    case 8
        if(dSampFmt == Tiff.SampleFormat.UInt)
            strFormat = 'uint8';
        else
            strFormat = 'int8';
        end
    case 16
         if(dSampFmt == Tiff.SampleFormat.UInt)
            strFormat = 'uint16';
         else
             strFormat = 'int16';
         end
    case 32
        if(dSampFmt == Tiff.SampleFormat.UInt)
            strFormat = 'uint32';
        elseif(dSampFmt == Tiff.SampleFormat.Int)
            strFormat = 'int32';
        else
            strFormat = 'single';
        end
    otherwise
        strFormat = 'double';
end


ImgData = zeros(hImage,wImage,idx_E-idx_S+1,strFormat);
for nImg=idx_S:idx_E
   TifLink.setDirectory(nImg);
   ImgData(:,:,nImg-idx_S+1)=TifLink.read();
end
TifLink.close();
warning('on','all');