function Mat4x4 = antsMat4_4(antsMatFn)
    % Read in and convert the .mat file from ANTs format to a 4x4 transformation matrix in image coordinate.
    
    % Load the .mat file
    antsMat = load(antsMatFn);
    
    rot = reshape(antsMat.AffineTransform_double_3_3(1:9), [3, 3])';
    trans = antsMat.AffineTransform_double_3_3(10:12);
    center = antsMat.fixed;
    offset = center + trans- rot*center;

    Mat4x4 = [[rot offset];[0 0 0 1]];
end