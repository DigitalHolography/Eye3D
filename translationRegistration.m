
function [RegisteredMovie, X_Translation, Y_Translation, Error] = ...
    translationRegistration(OriginalMovie,hwin,iwin,lwin,scalingFactor, RefMode, mask)

subPixelResolution = 100;

if (mod(lwin,2) == 0)
    lwin=lwin+1;%*nearest > odd #*
end

imax = size(OriginalMovie,3);

referenceFrame = mean(OriginalMovie(:,:,1:hwin),3);
currentFrameFiltered = imgaussfilt3(OriginalMovie,[1 1 2],'FilterSize',[1 1 iwin]);
currentFrameFiltered = mat2gray(currentFrameFiltered);
%mask
FFTreferenceFrame=fft2(referenceFrame .* mask);

X_Translation = zeros(imax,1);
Y_Translation = zeros(imax,1);
Error = zeros(imax,1);

switch RefMode
    
    case 'sliding'
        vX = zeros(imax,1);
        vY = zeros(imax,1);
        WaitMessage = parfor_wait(imax,'Translation sliding assessment : ','Waitbar', true);
        referenceFrame = zeros(size(OriginalMovie));
        for ii = hwin+1:imax %Preloading time filtered frame to prevent RAM overload
            referenceFrame(:,:,ii) = mean(OriginalMovie(:,:,ii-hwin:ii-1),3);
        end
        parfor ii = hwin+1:imax
            FFTreferenceFrame=fft2(referenceFrame(:,:,ii) .* mask);
            %currentFrame = imgaussfilt3(iwin)
            currentFrame = currentFrameFiltered(:,:,ii);
            FFTcurrentFrame = fft2(currentFrame .* mask);
            Output = dftregistration(double(FFTreferenceFrame), double(FFTcurrentFrame), subPixelResolution);
            Error(ii) = Output(1);
            diffphase = Output (2);
            vX(ii) = Output(4)*scalingFactor;
            vY(ii) = Output(3)*scalingFactor;
            WaitMessage.Send;
        end
        WaitMessage.Destroy;
        clear referenceFrame;
        %initialisation
        X_Translation(1) = 0;
        Y_Translation(1) = 0;
        RegisteredMovie(:,:,1) = single(currentFrameFiltered(:,:,1));
        
        for ii = 2:imax
            X_Translation(ii) = X_Translation(ii-1) + vX(ii);
            Y_Translation(ii) = Y_Translation(ii-1) + vY(ii);
        end
        WaitMessage = parfor_wait(imax,'Translation sliding registration ','Waitbar', true);
        parfor ii = 2:imax
            RegisteredMovie(:,:,ii) = single(imtranslate(mat2gray(OriginalMovie(:,:,ii)),[X_Translation(ii), Y_Translation(ii)],'bilinear','FillValues',mean2(mat2gray(OriginalMovie(:,:,ii)))));
            WaitMessage.Send;
        end
        WaitMessage.Destroy;
        
    case 'static'
        
        WaitMessage = parfor_wait(imax,'Translation static assessment : ','Waitbar', true);
        parfor ii = 1:imax
            %currentFrame = imgaussfilt3(iwin)
            currentFrame = currentFrameFiltered(:,:,ii);
            FFTcurrentFrame = fft2(currentFrame .* mask);
            Output = dftregistration(FFTreferenceFrame, FFTcurrentFrame, subPixelResolution);
            Error(ii) = Output(1);
            diffphase = Output (2);
            X_Translation(ii) = Output(4)*scalingFactor;
            Y_Translation(ii) = Output(3)*scalingFactor;
            WaitMessage.Send;
        end%ii
        WaitMessage.Destroy
        WaitMessage = parfor_wait(imax,'Image registration : ','Waitbar', true);
        parfor ii = 1:imax
            %utiliser le tableau currentFrame filtre
            currentFrame2 = mat2gray(OriginalMovie(:,:,ii));
            RegisteredMovie(:,:,ii) = single(imtranslate(currentFrame2,[X_Translation(ii) ,Y_Translation(ii)],'bilinear','FillValues',mean2(currentFrame2)));
            WaitMessage.Send;
        end%ii
        WaitMessage.Destroy
    case 'cumul'
        wb = waitbar(0,'Translation cumul assessment : 0%');
        for ii = hwin+1:imax
            referenceFrame = referenceFrame.*(ii-2)./(ii-1)+OriginalMovie(:,:,ii-1)./(ii-1);
            FFTreferenceFrame = fft2(referenceFrame .* mask);
            %currentFrame = imgaussfilt3(iwin)
            currentFrame = currentFrameFiltered(:,:,ii);
            FFTcurrentFrame = fft2(currentFrame .* mask);
            Output = dftregistration(double(FFTreferenceFrame), double(FFTcurrentFrame), subPixelResolution);
            Error(ii) = Output(1);
            diffphase = Output (2);
            X_Translation(ii) = Output(4)*scalingFactor;
            Y_Translation(ii) = Output(3)*scalingFactor;
            waitbar(ii/imax,wb,['Translation cumul assessment :',num2str(ii/imax*100, '%.2f')]);
        end%ii
        close(wb)
        WaitMessage = parfor_wait(imax,'Image registration : ','Waitbar', true);
        parfor ii = 1:imax
            %utiliser le tableau currentFrame filtre
            currentFrame2 = mat2gray(OriginalMovie(:,:,ii));
            %frame corerection
            RegisteredMovie(:,:,ii) = single(imtranslate(currentFrame2,[X_Translation(ii), Y_Translation(ii)],'bilinear','FillValues',mean(currentFrame2)));
            WaitMessage.Send;
        end
        WaitMessage.Destroy;
end

RegisteredMovie = mat2gray(RegisteredMovie);
avgt = mean(mean(RegisteredMovie,1),2);
WaitMessage = parfor_wait(imax,'Image smoothing : ','Waitbar', true);
parfor ii = 1:imax
    RegisteredMovie(:,:,ii) = (RegisteredMovie(:,:,ii) - avgt(ii)) ./ avgt(ii);
    WaitMessage.Send;
end
WaitMessage.Destroy;
RegisteredMovie = imgaussfilt3(RegisteredMovie,[1 1 2],'FilterSize',[1 1 lwin]);
RegisteredMovie = mat2gray(RegisteredMovie);

end%function