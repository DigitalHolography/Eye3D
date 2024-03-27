function []=calibrationMovies()

% retina/
% pupil/

Original=mat2gray(mean(imread('D:\Stage1A\200625_GAJ0114\retina\image.jpg'),3));
imax = 100;
  
for ii = 1:100
    TranslatedVideo(:,:,ii) = Original;
end

% 
% 
% Y translate
% for ii = 1:30
%     TranslatedVideo(:,:,ii)=imtranslate(TranslatedVideo(:,:,ii),[0, 3*sin(ii/(2*pi))]);
%   
% end %ii
% 
% 
% %X translate
% for ii = 31:60
%     TranslatedVideo(:,:,ii)=imtranslate(TranslatedVideo(:,:,ii),[3*sin((ii-30)/(2*pi)), 0]);
% end %ii
% 
% 
%XY translate
Original = TranslatedVideo(:,:,1);
for ii = 1:100
    TranslatedVideo(:,:,ii)=imtranslate(TranslatedVideo(:,:,ii),[10*cos((ii)*(2*pi)/100), 10*sin((ii*(2*pi)/100))],'bilinear','FillValues',mean2(TranslatedVideo(:,:,ii)));
end %ii
% 
% % %{
% %Y translate
% Original = TranslatedVideo(:,:,60);
% for ii = 61:100
%     TranslatedVideo(:,:,ii)=imtranslate(TranslatedVideo(:,:,ii),[0, ii-60]);
% end %ii
% %}


%rotate

% 
% for ii = 1:100
%    TranslatedVideo(:,:,ii) = imrotate(TranslatedVideo(:,:,ii),ii/40,'bilinear','crop');
% end %ii


[X,Y] = meshgrid(linspace(-1,1,size(TranslatedVideo,1)),linspace(-1,1,size(TranslatedVideo,2)));
s = linspace(0.9,1.1,size(TranslatedVideo,3));
for ii = 1:100
    [Xm,Ym] = meshgrid(linspace(-s(ii),s(ii),size(TranslatedVideo,1)),linspace(-s(ii),s(ii),size(TranslatedVideo,2)));
    imgavg = mean2(TranslatedVideo(:,:,ii));
    try
        rM = single(interp2(Xm,Ym,TranslatedVideo(:,:,ii),X,Y,'linear',imgavg));
    catch
        rM = TranslatedVideo(:,:,ii);    
    end
    TranslatedVideo(:,:,ii) = rM;
end



%video registration
vout = VideoWriter('D:\Stage1A\200625_GAJ0114\pupil\syntheticMovie.avi');
vout.Quality = 95;
open(vout);
for ii = 1:100
    writeVideo(vout,squeeze(TranslatedVideo(:,:,ii)));
end%ii
close(vout); 

Original=mat2gray(mean(imread('D:\Stage1A\200625_GAJ0114\pupil\image.jpg'),3));
imax = 100;
  
for ii = 1:100
    TranslatedVideo(:,:,ii) = Original;
end

% 
% 
% Y translate
% for ii = 1:30
%     TranslatedVideo(:,:,ii)=imtranslate(TranslatedVideo(:,:,ii),[0, 3*sin(ii/(2*pi))]);
%   
% end %ii
% 
% 
% %X translate
% for ii = 31:60
%     TranslatedVideo(:,:,ii)=imtranslate(TranslatedVideo(:,:,ii),[3*sin((ii-30)/(2*pi)), 0]);
% end %ii
% 
% 
%XY translate
Original = TranslatedVideo(:,:,1);
for ii = 1:100
    TranslatedVideo(:,:,ii)=imtranslate(TranslatedVideo(:,:,ii),[10*cos((ii)*(2*pi)/100), 10*sin((ii*(2*pi)/100))],'bilinear','FillValues',mean2(TranslatedVideo(:,:,ii)));
end %ii
% 
% % %{
% %Y translate
% Original = TranslatedVideo(:,:,60);
% for ii = 61:100
%     TranslatedVideo(:,:,ii)=imtranslate(TranslatedVideo(:,:,ii),[0, ii-60]);
% end %ii
% %}


%rotate

% 
% for ii = 1:100
%    TranslatedVideo(:,:,ii) = imrotate(TranslatedVideo(:,:,ii),ii/40,'bilinear','crop');
% end %ii


[X,Y] = meshgrid(linspace(-1,1,size(TranslatedVideo,1)),linspace(-1,1,size(TranslatedVideo,2)));
s = linspace(0.9,1.1,size(TranslatedVideo,3));
for ii = 1:100
    [Xm,Ym] = meshgrid(linspace(-s(ii),s(ii),size(TranslatedVideo,1)),linspace(-s(ii),s(ii),size(TranslatedVideo,2)));
    imgavg = mean2(TranslatedVideo(:,:,ii));
    try
        rM = single(interp2(Xm,Ym,TranslatedVideo(:,:,ii),X,Y,'linear',imgavg));
    catch
        rM = TranslatedVideo(:,:,ii);    
    end
    TranslatedVideo(:,:,ii) = rM;
end



%video registration
vout = VideoWriter('D:\Stage1A\200625_GAJ0114\retina\syntheticMovie.avi');
vout.Quality = 95;
open(vout);
for ii = 1:100
    writeVideo(vout,squeeze(TranslatedVideo(:,:,ii)));
end%ii
close(vout); 


end %function