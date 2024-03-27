function [MOVINGREG, scale] = stretchingRegistration(MOVING,FIXED)
%registerImages  Register grayscale images using auto-generated code from Registration Estimator app.
%  [MOVINGREG] = registerImages(MOVING,FIXED) Register grayscale images
%  MOVING and FIXED using auto-generated code from the Registration
%  Estimator app. The values for all registration parameters were set
%  interactively in the app and result in the registered image stored in the
%  structure array MOVINGREG.

% Default spatial referencing objects
fixedRefObj = imref2d(size(FIXED));
movingRefObj = imref2d(size(MOVING));

% Intensity-based registration
[optimizer, metric] = imregconfig('monomodal');
optimizer.GradientMagnitudeTolerance = 1.00000e-04;
optimizer.MinimumStepLength = 1.00000e-05;
optimizer.MaximumStepLength = 1.25E-03;%6.25000e-02;
optimizer.MaximumIterations = 100;
optimizer.RelaxationFactor = 0.500000;

% Align centers
[xFixed,yFixed] = meshgrid(1:size(FIXED,2),1:size(FIXED,1));
[xMoving,yMoving] = meshgrid(1:size(MOVING,2),1:size(MOVING,1));
sumFixedIntensity = sum(FIXED(:));
sumMovingIntensity = sum(MOVING(:));
fixedXCOM = (fixedRefObj.PixelExtentInWorldX .* (sum(xFixed(:).*double(FIXED(:))) ./ sumFixedIntensity)) + fixedRefObj.XWorldLimits(1);
fixedYCOM = (fixedRefObj.PixelExtentInWorldY .* (sum(yFixed(:).*double(FIXED(:))) ./ sumFixedIntensity)) + fixedRefObj.YWorldLimits(1);
movingXCOM = (movingRefObj.PixelExtentInWorldX .* (sum(xMoving(:).*double(MOVING(:))) ./ sumMovingIntensity)) + movingRefObj.XWorldLimits(1);
movingYCOM = (movingRefObj.PixelExtentInWorldY .* (sum(yMoving(:).*double(MOVING(:))) ./ sumMovingIntensity)) + movingRefObj.YWorldLimits(1);
translationX = fixedXCOM - movingXCOM;
translationY = fixedYCOM - movingYCOM;

if ~isfinite(translationX)
    translationX = 0;
end
if ~isfinite(translationY)
    translationY = 0;
end

% Coarse alignment
initTform = affine2d();
initTform.T(3,1:2) = [translationX, translationY];

% Apply Gaussian blur
fixedInit = imgaussfilt(FIXED,1.909722);
movingInit = imgaussfilt(MOVING,1.909722);

% Normalize images
movingInit = mat2gray(movingInit);
fixedInit = mat2gray(fixedInit);

% assess transformation from moving to ref
tform = imregtform(fixedInit,fixedRefObj,movingInit, movingRefObj, 'similarity',optimizer,metric,'PyramidLevels',5,'InitialTransformation',initTform);
MOVINGREG.Transformation = tform;
% T(:,:) = tform.T;
Tinv(:,:) = tform.invert.T;
ss = squeeze(Tinv(2,1));
sc = squeeze(Tinv(1,1));
ScaleRecovered = sqrt(ss*ss + sc*sc);

tformStretch = affine2d();
tformStretch.T(:,:) = eye(3,3);

u = [0 1]; 
v = [0 0]; 
[x, y] = transformPointsForward(tform, u, v); 
dx = x(2) - x(1); 
dy = y(2) - y(1);
scale = 1/sqrt(dx^2 + dy^2);

% imwarp for stretching and translation registration
%MOVINGREG.RegisteredImage = imwarp(MOVING, tformStretch);
MOVINGREG.RegisteredImage = imresize(MOVING,scale);
% Store spatial referencing object
MOVINGREG.SpatialRefObj = fixedRefObj;
end

