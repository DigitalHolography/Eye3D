function [RegisteredMovie, angles] = movieRotation(OriginalMovie,mode,mask,iwin,hwin)

imax = size(OriginalMovie, 3);

referenceFrame = mean(OriginalMovie(:,:,1:hwin),3);
currentFrameFiltered = imgaussfilt3(OriginalMovie,[1 1 2],'FilterSize',[1 1 iwin]);
currentFrameFiltered = mat2gray(currentFrameFiltered);
switch mode
    case 'cartesian'
        angles = zeros(imax,1);
        
        referenceFrame = mean(OriginalMovie(:,:,1:hwin),3);
        WaitMessage = parfor_wait(imax,'Rotation assessment : ','Waitbar', true);
        parfor ii = 1:imax
            currentFrame = currentFrameFiltered(:,:,ii);
            [M , a] = rotationRegistration(currentFrame,referenceFrame);
            angles(ii) = a;
            RegisteredMovie(:,:,ii) = single(M.RegisteredImage);
            WaitMessage.Send;
        end%ii
        WaitMessage.Destroy;
    case 'polar'
        parfor ii = 1:imax
            POriginalMovie(:,:,ii) = makeFundus(OriginalMovie(:,:,ii));
        end
        RefMode = 'static';
        [RegisteredMovie,~, angles] = ...
            translationRegistration(POriginalMovie,hwin,iwin,1,1, RefMode, mask);
    end
end