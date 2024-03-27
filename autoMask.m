% -----------------------------------------------------
% function:
%
%   geneates a mask using a gaussian blurred picture
%
%
% inputs: spacetially and temporally filtered movie (NxN matrix)
% outputs: mask
%
% -----------------------------------------------------

function [mask] = autoMask(MeanFrame)

dilationFactor = 10.0;

length = size(MeanFrame,1);

MeanFrame = imgaussfilt(MeanFrame,round(length/10));

A = linspace(1,length,length);
XData = mean(MeanFrame,1);
XData = (XData - mean(XData)).^2;
XData = (XData/max(XData)).^1;
YData = mean(MeanFrame,2);
YData = (YData - mean(YData)).^2;
YData = (YData/max(YData)).^1;
XResult = fit(A',XData','gauss1');
YResult = fit(A',YData,'gauss1');

% plot(1:512,XData,1:512,YData);

xSigma = int16((XResult.c1/2)*dilationFactor);
ySigma = int16((YResult.c1/2)*dilationFactor);


if (2*xSigma < length) && (2*ySigma < length) %c'était (2*xSigma > length) || (2*ySigma > length) mais bizarre
    wx = hann(length);
    wy = hann(length);
    [wX,wY] = meshgrid(wx,wy);
    w2d = wX.*wY;
    mask = zeros(length);
    mask(int16(length/2-ySigma):int16(length/2+ySigma-1),int16(length/2-xSigma):int16(length/2+xSigma-1)) = w2d;
else
    wx = hann(2*xSigma);
    wy = hann(2*ySigma);
    [wX,wY] = meshgrid(wx,wy);
    w2d = wX.*wY;
    mask = zeros(length);
    mask(int16(YResult.b1-ySigma):int16(YResult.b1+ySigma-1),int16(XResult.b1-xSigma):int16(XResult.b1+xSigma-1)) = w2d;
end




end %function
