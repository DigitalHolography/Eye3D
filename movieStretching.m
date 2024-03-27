function [RegisteredMovie, scale] = movieStretching (OriginalMovie, iwin, hwin)

imax = size(OriginalMovie, 3);

referenceFrame = mean(OriginalMovie(:,:,1:hwin),3);
currentFrameFiltered = imgaussfilt3(OriginalMovie,[1 1 2],'FilterSize',[1 1 iwin]);
currentFrameFiltered = mat2gray(currentFrameFiltered);

vX = zeros(imax,1);
vY = zeros(imax,1);
RegisteredMovie = zeros(size(OriginalMovie),'single');
referenceFrame = mean(OriginalMovie(:,:,1:hwin),3);
size(referenceFrame);
[X,Y] = meshgrid(linspace(-1,1,size(referenceFrame,1)),linspace(-1,1,size(referenceFrame,2)));
WaitMessage = parfor_wait(imax,'Scaling assessment : ','Waitbar', true);
parfor ii = 1:imax
    currentFrame = currentFrameFiltered(:,:,ii);
    [M , s] = stretchingRegistration(currentFrame,referenceFrame);
    scale (ii) = 1/s;
    [Xm,Ym] = meshgrid(linspace(-s,s,size(M.RegisteredImage,1)),linspace(-s,s,size(M.RegisteredImage,2)));
    imgavg = mean2(currentFrame);
    try
        rM = single(interp2(Xm,Ym,double(M.RegisteredImage),X,Y,'linear',imgavg));
    catch
        rM = single(OriginalMovie(:,:,ii));    
    end
    RegisteredMovie(:,:,ii) = mat2gray(rM);
    WaitMessage.Send;
    %     waitbar(ii/imax,wb,'Pupil scaling assessment 1/3');
    
end%ii
WaitMessage.Destroy

end %function