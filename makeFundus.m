% =======================================
% placing the ONH in a right eye fundus view
% assuming the center of rotation is in the fovea
% assuming ONH is positioned 12° nasally and 1.4° superior 

% by Josselin Gautier - INSERM Quinze Vingt
% 
% % =======================================
% clc
% clear
% close all;


% mean over 50 images
%  I=mean(I,3);
% OR prefilter, probably with bilateral filter
%{
patch = imcrop(I,[170, 35, 50 50]);
    patchVar = std2(patch)^2;
    DoS = 2*patchVar;
    I = imbilatfilt(I,DoS);
  %}  
% it seems the input image should be square for correct 
% polar and log-polar transform

function [PI] = makeFundus(I)

hW=16;% should be >12.6 because
W=hW*2;%36;
hH=16;%half height in deg;
H=hH*2;
deg2pix=512/6;
w=6;h=6;
wp=512;hp=wp;
Wp=W.*deg2pix;

R=uint8(zeros(round(hp*H/h),round(wp*W/w) ));


%location of the ONH image is from top left:
%top:  18-(6+1.4)
%left: 18+6
pt=round((hH-(w+1.4)).*deg2pix);
pl=round((hW+(12-(w/2))).*deg2pix);% should be 12.6
if pl+511>Wp
    
    fprintf('cutting the image');
    R(pt:pt+511,pl+1:Wp)=I(:,1:Wp-pl);
else
    R(pt:pt+511,pl:pl+511)=I;
end
%imshow(R);

%================== polar transform ====================
%%{

%ImToPolar parameters
L = size(R,1);
Rmin = 2*sqrt((pl-L/2)^2 + (pt+511-L/2)^2)/L;
Rmax = 2*sqrt((pl-L/2)^2 + (pt+511-L/2)^2)/L;

im=double(R);
fim=fft2(im);
pcimg=ImToPolar (im, 0, 1, 800, 800);% ! A REMPLACER PAR APPEL A ImToPolar()
% fpcimg=imgpolarcoord(fim);
% figure; subplot(2,2,1); imagesc(im); colormap gray; axis image;
% title('Input image');
% 
% subplot(2,2,2);
% imagesc(log(abs(fftshift(fim)+1)));   axis image;%colormap gray;
% title('FFT');

% subplot(2,2,3);

% find the enclosing square in the polar transform domain
[row,col] = find(pcimg);
[minRow]=min(row);
[minCol]=min(col);
% PI=pcimg(minRow:end,minCol:end);
PI=pcimg(400:end,200:300);
% imagesc(pcimg); %display the full or the crop
% imagesc(PI);
% colormap gray; %axis image;

% title('Polar Input image');
% 
% subplot(2,2,4);
% imagesc(log(abs(pcimg)+1));  axis image;%colormap gray;
% title('Polar FFT');


%}



%
% to do

% try to estimate the

end 