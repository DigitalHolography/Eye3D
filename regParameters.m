classdef regParameters
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        target;
        type;
        mode;
        maskMode;
        temporalFilter;
        referenceSize;
        vout;
    end
    
    methods
        function regParameters = regParameters(target,type,mode,maskMode,temporalFilter,referenceSize,vout)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            regParameters.target = target;
            regParameters.type = type;
            regParameters.mode = mode;
            regParameters.maskMode = maskMode;
            regParameters.temporalFilter = temporalFilter;
            regParameters.referenceSize = referenceSize;
            regParameters.vout = vout;
        end
        
        function regParameters = set.target(regParameters,target)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            if (strcmp(target,'retina') || strcmp(target,'pupil'))
                regParameters.target = target;
            else
                error(strcat('Expected value within [''retina'' ''pupil''] not ',target));
            end
        end
        function regParameters = set.type(regParameters,type)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            if (strcmp(type,'translation') || strcmp(type,'rotation') || strcmp(type,'scaling'))
                regParameters.type = type;
            else
                error(strcat('Expected value within [''translation'' ''rotation'' ''scaling''] not ',type));
            end
        end
        function regParameters = set.mode(regParameters,mode)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            switch regParameters.type
                
                case 'translation'
                    if (strcmp(mode,'static') || strcmp(mode,'cumul') || strcmp(mode,'sliding'))
                        regParameters.mode = mode;
                    else
                        error(strcat('Expected value within [''static'' ''cumul'' ''sliding''] not ',mode));
                    end
                case 'scaling'
                    if (strcmp(mode,'static'))
                        regParameters.mode = mode;
                    else
                        error(strcat('Expected value within [''static''] not ',mode));
                    end
                case 'rotation'
                    if (strcmp(mode,'polar') || strcmp(mode,'cartesian'))
                        regParameters.mode = mode;
                    else
                        error(strcat('Expected value within [''cartesian'' ''polar''] not ',mode));
                    end
            end
        end       
        function regParameters = set.maskMode(regParameters,maskMode)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            if (strcmp(maskMode,'none') || strcmp(maskMode,'auto') || strcmp(maskMode,'manual'))
                regParameters.maskMode = maskMode;
            else
                error(strcat('Expected value within [''none'' ''auto'' ''manual''] not ',maskMode));
            end
        end 
        function regParameters = set.temporalFilter(regParameters,temporalFilter)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            if temporalFilter == floor(temporalFilter)
                regParameters.temporalFilter = temporalFilter;
            else
                error(strcat('Expected value within [1 VideoLength] not ',temporalFilter));
            end
        end
        function regParameters = set.referenceSize(regParameters,referenceSize)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            if referenceSize == floor(referenceSize)
                regParameters.referenceSize = referenceSize;
            else
                error(strcat('Expected value within [1 VideoLength] not ',referenceSize));
            end
        end
        function regParameters = set.vout(regParameters,vout)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            if islogical(vout)
                regParameters.vout = vout;
            else
                error(strcat('Expected value within [true false] not ',vout));
            end
        end
        
        function mask = getMask(obj,movie)
            
            hwin = 10;
            imax = size(movie,3);
            
            switch obj.maskMode
                case 'auto'
                    FilteredOriginalMovie = zeros(size(movie));
                    for ii = 1:imax
                        FilteredOriginalMovie(:,:,ii) = imgaussfilt(movie(:,:,ii),45);
                    end
                    FilteredMeanFrame = mean(FilteredOriginalMovie,3);
                    %imshow(FilteredMeanFrame);
                    mask = autoMask(FilteredMeanFrame);
                    figure; imshow(mask.*movie(:,:,1));
                case 'manual'
                    referenceFrame = mean(movie(:,:,1:hwin),3);
%                     imshow(referenceFrame);
                    r = getrect;
                    r = int16(r);
                    wx = hann(r(3));
                    wy = hann(r(4));
                    [wX,wY] = meshgrid(wx,wy);
                    w2d = wX.*wY;
                    mask = zeros(size(referenceFrame));
                    mask(int16(r(2)):int16(r(2)+r(4)-1),int16(r(1)):int16(r(1)+r(3)-1)) = w2d;
                    imshow(referenceFrame .* mask);
                case 'none'
                    mask = ones(size(mean(movie(:,:,1:hwin),3)));
            end
            
            
        end
    end
end

