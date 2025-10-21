function writeTiffStack_UInt8(matImg,strFn_Sav)
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 8;
tagstruct.Compression = Tiff.Compression.PackBits;
tagstruct.ImageLength = size(matImg,1);
tagstruct.ImageWidth = size(matImg,2);
tagstruct.SamplesPerPixel = 1;
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software = 'MATLAB';

disp(['Writting file: ' strFn_Sav]);
objTiffStack = Tiff(strFn_Sav,'w8');
nFrameCount = size(matImg,3);
for nFrame = 1:nFrameCount
    try
        objTiffStack.setTag(tagstruct);
        objTiffStack.write(uint8(matImg(:,:,nFrame)));
        if(nFrame<nFrameCount)
            objTiffStack.writeDirectory();
        end
    catch
       objTiffStack.close();
    end
end
objTiffStack.close();