

clc
clear
close all;

%% Get Retina File

[fname, fpath] = uigetfile({'*.avi;*.mp4;', 'Retina Movie'}, 'Select movie file of retina');
if fname == 0
    return
end
PathForMovieToReadRetina = fullfile(fpath, fname);

[~, tmp_name, ext] = fileparts(fname);
filepath1 = fpath;
name1 = tmp_name;
extRet = ext;

%% Get Pupil File

[fname, fpath] = uigetfile({'*.avi;*.mp4;', 'Pupil Movie'}, 'Select movie file of pupil');
if fname == 0
    return
end
PathForMovieToReadPupil = fullfile(fpath, fname);

[~, tmp_name, ext] = fileparts(fname);
filepath2 = fpath;
name2 = tmp_name;
extPup = ext;

%%

% PathForMovieToReadRetina =  'D:\Stage1A\200715_JAV0232\retina\200715_JAV0232_OD_pupil_0_M0.avi';%retina
% PathForMovieToReadRetina =  'F:\200903_JAT0112\Eye3d\200903_JAT0112_OS_ONH_pupil_1_M0.avi';%retina
% PathForMovieToReadRetina =  'D:\holovibes_data\\200630_PUL0111\200630_PUL0111_OD_r.avi';%retina
% [filepath1,name1,extRet] = fileparts(PathForMovieToReadRetina);
% PathForMovieToReadPupil =    'D:\Stage1A\200715_JAV0232\pupil\200715_JAV0232_OD_pupil_2_M0.avi';% pupil
% PathForMovieToReadPupil = 'D:\Stage1A\200625_GAJ0114\pupil\200625_GAJ0114_OD_ONH1_0_M0.avi';
% PathForMovieToReadPupil =    'F:\200903_JAT0112\Eye3d\200903_JAT0112_OS_ONH_pupil_0_M0.avi';% pupil
% PathForMovieToReadPupil =    'D:\holovibes_data\\200630_PUL0111\200630_PUL0111_OD_p.avi';% pupil
% [filepath2,name2,extPup] = fileparts(PathForMovieToReadPupil);

PathForMatFile = [filepath1,'\..\registration'];%,'\..\..\'];
mkdir(PathForMatFile);

%name1 = [name1,'_tmp'];

SamplingFreq = 33500;
StrideSTFT = 32;
scalingFactor = 1/1.48;
hwin = 3;%50; %filtre temporel l'image de reference
iwin = 3;%8; %filtre temporel de qualite d'image lue


imax = 1024; %Maximum read images, can go over actual maximum
% registration types and parameters target;type;mode;maskMode;temporalFilter;referenceSize;vout;
regArrayParameters = [];
regArrayParameters = [regArrayParameters regParameters('retina','translation','sliding','none',3,3,true)];
regArrayParameters = [regArrayParameters regParameters('retina','translation','static','none',3,imax,true)];
regArrayParameters = [regArrayParameters regParameters('retina','scaling','static','none',3,50,true)];
regArrayParameters = [regArrayParameters regParameters('retina','rotation','cartesian','none',3,imax,true)];
regArrayParameters = [regArrayParameters regParameters('pupil','scaling','static','auto',3,50,false)];
regArrayParameters = [regArrayParameters regParameters('pupil','translation','static','none',3,imax,true)];
regArrayParameters = [regArrayParameters regParameters('pupil','translation','static','none',1,imax,true)];



%%
% Sorting out Retina treatment/pupil treatment
regArrayParametersRet = [];
regArrayParametersPup = [];
for ii = 1:length(regArrayParameters)
    switch  regArrayParameters(ii).target
        case 'retina'
            regArrayParametersRet = [regArrayParametersRet,regArrayParameters(ii)];
        case 'pupil'
            regArrayParametersPup = [regArrayParametersPup,regArrayParameters(ii)];
    end
end

%%
%Retina
nParametersRet = length(regArrayParametersRet);


%reading retina video
v = VideoReader(PathForMovieToReadRetina);
OriginalMovie = zeros([size(mean(readFrame(v),3)) imax]);
if nParametersRet>0
    ii =1;
    while hasFrame(v)
        OriginalMovie(:,:,ii) = single(mat2gray(mean(readFrame(v),3)));
        ii = ii+1;
        if ii==imax +1
            break
        end
    end
    imax = ii-1;
    OriginalMovie = OriginalMovie(:,:,1:imax);
end
%calculating each registration
if nParametersRet>0
    regArrayRet(1) = applyReg(OriginalMovie,regArrayParametersRet(1));
    if nParametersRet>1
        for ii = 2:nParametersRet
           regArrayRet(ii) = applyReg(regArrayRet(ii-1).movie,regArrayParametersRet(ii));
        end
    end
end



%saving wanted videos
if nParametersRet>0
    for ii = 1:nParametersRet
        PathForMovieToWriteRetina = [filepath1,'\',name1,'_Reg',num2str(ii),extRet];
        if regArrayParametersRet(ii).vout
            vout = VideoWriter(PathForMovieToWriteRetina);
            vout.Quality = 95;
            open(vout);
            RegisteredMovieRetina = regArrayRet(ii).movie;
            for ii = 1:imax
                
                writeVideo(vout,squeeze(RegisteredMovieRetina(:,:,ii)));
            end%ii
            close(vout);
        end
            clear regArrayRet(ii).movie;
    end
end




%%
%Pupil
nParametersPup = length(regArrayParametersPup);


%reading pupil video
v = VideoReader(PathForMovieToReadPupil);

ii =1;

if nParametersPup>0
    while hasFrame(v)
        OriginalMovie(:,:,ii) = single(mat2gray(mean(readFrame(v),3)));
        ii = ii+1;
        if ii==imax +1
            break
        end
    end
    imax = ii-1;
end

%calculating each registration
if nParametersPup>0
    regArrayPup(1) = applyReg(OriginalMovie,regArrayParametersPup(1));
    if nParametersPup>1
        for ii = 2:nParametersPup
           regArrayPup(ii) = applyReg(regArrayPup(ii-1).movie,regArrayParametersPup(ii));
        end
    end
end



%saving wanted videos
if nParametersPup>0
    for ii = 1:nParametersPup
        PathForMovieToWritePupil = [filepath2,'\',name2,'_Reg',num2str(ii),extPup];
        if regArrayParametersPup(ii).vout
            vout = VideoWriter(PathForMovieToWritePupil);
            vout.Quality = 95;
            open(vout);
            RegisteredMoviePupil = regArrayPup(ii).movie;
            for jj = 1:imax
                writeVideo(vout,squeeze(RegisteredMoviePupil(:,:,jj)));
            end%ii
            close(vout);
        end
        clear regArrayPup(ii).movie;
    end
end

%%
% Getting proper data for plotting
anglePupil = zeros(imax,1);
angleRetina = zeros(imax,1);
scalePupil = ones(1,imax);
scaleRetina = ones(1,imax);
X_TranslationRetina = zeros(imax,1);
Y_TranslationRetina = zeros(imax,1);
X_TranslationPupil = zeros(imax,1);
Y_TranslationPupil = zeros(imax,1);
CellRetina(1) = {'Registration retina :'};
CellPupil(1) = {'Registration pupil :'};
if nParametersRet>0
    for ii = 1:nParametersRet
        switch regArrayParametersRet(ii).type % Summing rotations/translations 
            case 'translation'
                X_TranslationRetina = X_TranslationRetina + regArrayRet(ii).data1;
                Y_TranslationRetina = Y_TranslationRetina + regArrayRet(ii).data2;
            case 'rotation'
                angleRetina = angleRetina + regArrayRet(ii).data1;
            case 'scaling'
                scaleRetina = scaleRetina + (regArrayRet(ii).data1-1);
        end
        CellRetina(ii+1) = {[regArrayParametersRet(ii).type,' ',regArrayParametersRet(ii).mode,', mask = ',regArrayParametersRet(ii).maskMode,', iwin = ',num2str(regArrayParametersRet(ii).temporalFilter),', hwin = ',num2str(regArrayParametersRet(ii).referenceSize)]}; 
    end
    regMovieRetina = regArrayRet(nParametersRet).movie;
    MeanRetina = mean(regMovieRetina, 3);
end

if nParametersPup>0
    for ii = 1:nParametersPup
        switch regArrayParametersPup(ii).type %Summing translations/scalings
            case 'translation'
                X_TranslationPupil = X_TranslationPupil + regArrayPup(ii).data1;
                Y_TranslationPupil = Y_TranslationPupil + regArrayPup(ii).data2;
            case 'scaling'
                scalePupil = scalePupil + (regArrayPup(ii).data1-1);
            case 'rotation'
                anglePupil = anglePupil + regArrayPup(ii).data1;
        end
        CellPupil(ii+1) = {[regArrayParametersPup(ii).type,' ',regArrayParametersPup(ii).mode,', mask = ',regArrayParametersPup(ii).maskMode,', iwin = ',num2str(regArrayParametersPup(ii).temporalFilter),', hwin = ',num2str(regArrayParametersPup(ii).referenceSize)]};
    end
    regMoviePupil = regArrayPup(nParametersPup).movie;
    MeanPupil = mean(regMoviePupil, 3);
end

X_TranslationPupil = X_TranslationPupil.*scalePupil';
Y_TranslationPupil = Y_TranslationPupil.*scalePupil';






%%
%PSNR
if nParametersPup > 0
    contrastedMeanPupil = mat2gray(imgaussfilt(MeanPupil,3)-mean2(imgaussfilt(MeanPupil,3)));
    parfor ii = 1:imax
        contrastedPupilFrame = mat2gray(imgaussfilt(regMoviePupil(:,:,ii),8)-mean2(imgaussfilt(regMoviePupil(:,:,ii),8)));
        PSNRPup(ii) = psnr(contrastedPupilFrame,contrastedMeanPupil);
    end
    kPup = find(PSNRPup < mean(PSNRPup)-3);
    rPup = find(PSNRPup > mean(PSNRPup)-2);
end
if nParametersRet > 0
    parfor ii = 1:imax
        PSNRRet(ii) = psnr(regMovieRetina(:,:,ii),MeanRetina);
    end
    kRet = find(PSNRRet < mean(PSNRRet)-3);
    rRet = find(PSNRRet > mean(PSNRRet)-2);
end

%%
% plots

t = linspace(0,imax*StrideSTFT/SamplingFreq,imax);

% 

% %black
% % ax = gca;
% % set(gca,'color',[0 0 0]);%fond
% % set(gca,'Xcolor',[1 1 1]);%fond
% % set(gca,'Ycolor',[1 1 1]);%fond
% % set(gca,'AmbientLightColor',[0 0 0]);%fond
% 
% 
% 

% 
% % 
% % figure(5) %3D eye movie
% % 
% % %subplot(325)
% % [x,y,z] = sphere();
% % r = 5;
% % sph = surf( r*x, r*y, r*z+2,'edgecolor','none','FaceAlpha',0.5 ,'FaceColor','TextureMap');
% % axis equal, grid on, axis on
% % %sph.EdgeColor = 'none';
% % 
% % hold on
% % [x,y,z] = sphere;      
% % x = x(1:5,:);       
% % y = y(1:5,:);       
% % z = z(1:5,:);      
% % rx = 4;ry = 4;rz = 8;  
% % cornea = surf(rz*z+2.25,ry*y,rx*x+2,'FaceAlpha',0.5);  
% % axis equal;  
% % 
% % set(gcf, 'Renderer', 'OpenGL');
% % shading interp, material shiny, lighting phong, lightangle(0, 55)
% % 
% % 
% % title('Motion of eye');
% % for ii = 2:imax
% %     z = [0 0 1];
% %     center = [0 0 2];
% %     rotate(sph, z, (X_TranslationTot(ii)-X_TranslationTot(ii-1)), center);
% %     rotate(cornea, z, (X_TranslationTot(ii)-X_TranslationTot(ii-1)), center);
% %     y = [0 1 0];
% %     rotate(sph, y, (Y_TranslationTot(ii)-Y_TranslationTot(ii-1)), center);
% %     rotate(cornea, y, (Y_TranslationTot(ii)-Y_TranslationTot(ii-1)), center);
% %     drawnow
% % end


% a faire 

% fonction rotrescale sur films recales filtres

%film de l'oeil3D

%planche eps fig1
% saveas(figure(1), [PathForMatFile,'\',name1 , '_3Deye_retina.jpeg']);
% saveas(figure(2), [PathForMatFile,'\',name1 , '_3Deye_XTranslation.jpeg']);
% saveas(figure(3), [PathForMatFile,'\',name1 , '_3Deye_pupil.jpeg']);
% saveas(figure(4), [PathForMatFile,'\',name1 , '_3Deye_YTranslation.jpeg']);
% saveas(figure(5), [PathForMatFile,'\',name1 , '_3Deye_motion.jpeg']);
% saveas(figure(6), [PathForMatFile,'\',name1 , '_3Deye_scale.jpeg']);


% % %planche ppt
% Folder = PathForMatFile;
% DataPath_movie       = fullfile(Folder, [name1, '_3Deye_retina.jpeg']);
% DataPath_ROIs        = fullfile(Folder, [name1, '_3Deye_XTranslation.jpeg']);
% DataPath_plot        = fullfile(Folder, [name1, '_3Deye_pupil.jpeg']);
% DataPath_ResMap      = fullfile(Folder, [name1, '_3Deye_YTranslation.jpeg']);
% DataPath_systdiast   = fullfile(Folder, [name1, '_3Deye_motion.jpeg']);
% DataPath_composite   = fullfile(Folder, [name1, '_3Deye_scale.jpeg']);
% %DataPath_movie_cmp   = fullfile(Folder, '200110_GOM0180_OD_ONH1_CompositeMOVIE_ff=2_6-6_25kHz.gif');
% 
% %MakeSlidesPPT(Folder, DataPath_movie, DataPath_ROIs, DataPath_plot, DataPath_ResMap, DataPath_systdiast, DataPath_composite)%, DataPath_movie_cmp)
% 


%sauvegarde des mesures
if (nParametersPup>0 && nParametersRet>0)
 save([PathForMatFile,'\','registrationData.mat'],...
    'name1','name2','X_TranslationPupil','PathForMatFile','PathForMovieToReadPupil','nParametersPup',...
    'Y_TranslationPupil','X_TranslationRetina','CellRetina','CellPupil','PathForMovieToReadRetina',...
    'Y_TranslationRetina','scalePupil','scaleRetina','anglePupil','angleRetina','regArrayParameters','imax',...
    'MeanRetina','MeanPupil','t','kRet','kPup','rRet','rPup','PSNRRet','PSNRPup','nParametersRet',...
    '-nocompression');
elseif nParametersPup >0
    save([PathForMatFile,'\','registrationData.mat'],...
    'name1','name2','X_TranslationPupil','PathForMatFile','nParametersPup',...
    'Y_TranslationPupil','CellPupil','PathForMovieToReadPupil',...
   'scalePupil','anglePupil','regArrayParameters','imax',...
    'MeanPupil','t','kPup','rPup','PSNRPup','nParametersRet',...
    '-nocompression');
elseif nParametersRet >0 
     save([PathForMatFile,'\','registrationData.mat'],...
    'name1','name2','PathForMatFile','PathForMovieToReadRetina','nParametersPup',...
    'X_TranslationRetina','CellRetina',...
    'Y_TranslationRetina','scaleRetina','angleRetina','regArrayParameters','imax',...
    'MeanRetina','t','kRet','rRet','PSNRRet','nParametersRet',...
    '-nocompression');
end

if isdeployed
    copyfile (fullfile(ctfroot, 'HoloEye3D', "regParameters.m"), [PathForMatFile,'\regParameters.m']);
else
    copyfile ("regParameters.m", [PathForMatFile,'\regParameters.m']);
end

%% Planche EPS 

% Paramètres généraux

translationLimits = 200; %[-translationLimits +translationLimits]
rotationLimits = 5;% [-rotationLimits +rotationLimits]
scaleLimits = 0.9; % [1-scaleLimits 1+scaleLimits] 

figure(1)
clf(1,'reset')
clf(1)
figure(1)
%Planche rétine/pupille
if (nParametersPup>0 && nParametersRet>0)
    hsg = subplot_grid(5,4,'no_zoom','mergelist',{[5 6],[7 8],[9 10],[11 12],[13 14],[15 16],[17 18],[19 20]});

    %title
    formatedName = PathForMovieToReadRetina;
    hsg.figtitle(formatedName,'Fontsize',10,'FontWeight','normal');
    hsg.subfigtitle(' ','Fontsize',1);

    %Retina plots
    hsg.set_gca('viewer',1,1); %MeanRetina
    imshow(MeanRetina);

    hsg.set_gca(1,2); %PathRetina
    scatter(X_TranslationRetina,Y_TranslationRetina,1,'.');
    hold on
    scatter(X_TranslationRetina(kRet), Y_TranslationRetina(kRet),1,'r','.');
    set(gca,'Box','on');
    xmR = max(abs(X_TranslationRetina(rRet)));
    ymR = max(abs(Y_TranslationRetina(rRet)));
    xlabel('x (px)');
    ylabel('y (px)');
    title('translation','FontWeight','normal');
    marginFactor = 1.1;
    if ymR < translationLimits
        ylim([-ymR ymR]*marginFactor)
    else 
        ylim([-translationLimits translationLimits]*marginFactor)
    end
    if ymR < translationLimits
        xlim([-xmR xmR]*marginFactor)
    else 
        xlim([-translationLimits translationLimits]*marginFactor)
    end
    if xmR < ymR
        xlim([-ymR ymR]*marginFactor)
    else 
        ylim([-xmR xmR]*marginFactor)
    end
    if ymR > translationLimits
        ylim([-translationLimits translationLimits]*marginFactor)
        xlim([-translationLimits translationLimits]*marginFactor)
    end    
    if xmR > translationLimits
        xlim([-translationLimits translationLimits]*marginFactor)
        xlim([-translationLimits translationLimits]*marginFactor)
    end    
    axis square;
    grid on;

    hsg.set_gca(2,1); %translation Retina
    plot(t,X_TranslationRetina,'.','MarkerSize',1);
    hold on
    plot(t,Y_TranslationRetina,'.','color', [0.4940 0.1840 0.5560],'MarkerSize',1);
    xlabel('time (s)')
    ylabel('translation (px)')
    hold on 
    scatter(t(kRet), X_TranslationRetina(kRet),1,'r','.');
    hold on 
    scatter(t(kRet), Y_TranslationRetina(kRet), 1, [0.6350 0.0780 0.1840],'filled');
    axis tight
    if max(xmR,ymR) < translationLimits
        ylim([-max(xmR,ymR) max(xmR,ymR)]*marginFactor)
    else 
        ylim([-translationLimits translationLimits])
    end
    legend('x','y');

    if mean(scaleRetina) ~=1
        hsg.set_gca(3,1); %Retina scaling
        plot(t,scaleRetina,'.','MarkerSize',1);
        xlabel('time (s)')
        ylabel('scaling (relative)')
        hold on
        scatter(t(kRet), scaleRetina(kRet),1, 'r','.');
        scM = max(abs(scaleRetina(rRet)-1));
        axis tight
        if scM < scaleLimits
            ylim([1-scM*marginFactor 1+scM*marginFactor])
        else
            ylim([1-scaleLimits 1+scaleLimits])
        end
    else
        hsg.set_gca(3,1);
        axis off
    end

    if mean(angleRetina)~=0
        hsg.set_gca(4,1); %Retina Rotation
        plot(t,angleRetina,'.','MarkerSize',1);
        xlabel('time (s)')
        ylabel('rotation (deg)')
        hold on
        scatter(t(kRet), angleRetina(kRet),1, 'r','.');
        agM = max(abs(angleRetina(rRet)));
        axis tight
        if agM < rotationLimits
            ylim([-agM agM]*marginFactor)
        else
            ylim([-rotationLimits rotationLimits])
        end
    else
        hsg.set_gca(4,1);
        axis off
    end

    hsg.set_gca(5,1); %Retina PSNR
    [color,aColor] = getColorPlot(PSNRRet, 1, 3);
    scatter(t, PSNRRet,1,color,'filled');
    set(gca,'Box','on');
    xlabel('time (s)');
    ylabel('PSNR (dB)');
    hold on 
    plot(t,mean(PSNRRet)*ones(imax,1),'b','MarkerSize',1);
    plot(t,(mean(PSNRRet)-3)*ones(imax,1),'r','MarkerSize',1);
    axis tight


    %Pupil plots
    hsg.set_gca(1,3); %MeanPupil
    imshow(MeanPupil);

    hsg.set_gca(1,4); %PathPupil
    scatter(X_TranslationPupil,Y_TranslationPupil,1,'.');
    hold on
    scatter(X_TranslationPupil(kPup), Y_TranslationPupil(kPup),1,'r','.');
    set(gca,'Box','on');
    xlabel('x (px)');
    ylabel('y (px)');
    title('translation','FontWeight','normal');
    xmP = max(abs(X_TranslationPupil(rPup)));
    ymP = max(abs(Y_TranslationPupil(rPup)));
    marginFactor = 1.1;
    if ymP < translationLimits
        ylim([-ymP ymP]*marginFactor)
    else 
        ylim([-translationLimits translationLimits]*marginFactor)
    end
    if ymP < translationLimits
        xlim([-xmP xmP]*marginFactor)
    else 
        xlim([-translationLimits translationLimits]*marginFactor)
    end
    if xmP < ymP
        xlim([-ymP ymP]*marginFactor)
    else 
        ylim([-xmP xmP]*marginFactor)
    end
    if ymP > translationLimits
        ylim([-translationLimits translationLimits]*marginFactor)
        xlim([-translationLimits translationLimits]*marginFactor)
    end    
    if xmP > translationLimits
        xlim([-translationLimits translationLimits]*marginFactor)
        xlim([-translationLimits translationLimits]*marginFactor)
    end    
    axis square;
    grid on;


    hsg.set_gca(2,3); %translation Pupil
    plot(t,X_TranslationPupil,'.','MarkerSize',1);
    hold on
    plot(t,Y_TranslationPupil,'.','color', [0.4940 0.1840 0.5560],'MarkerSize',1);
    xlabel('time (s)')
    ylabel('translation (px)')
    hold on 
    scatter(t(kPup), X_TranslationPupil(kPup),1,'r','.');
    hold on 
    scatter(t(kPup), Y_TranslationPupil(kPup), 1, [0.6350 0.0780 0.1840],'filled');
    axis tight
    if max(xmR,ymR) < translationLimits
        ylim([-max(xmR,ymR) max(xmR,ymR)]*marginFactor)
    else 
        ylim([-translationLimits translationLimits])
    end
    legend('x','y');

    if mean(scalePupil) ~= 1
        hsg.set_gca(3,3); %Pupil dilation
        plot(t,scalePupil,'.','MarkerSize',1);
        xlabel('time (s)')
        ylabel('scaling (relative)')
        hold on
        scatter(t(kPup), scalePupil(kPup),1, 'r','.');
        scM = max(abs(scalePupil(rPup)-1));
        axis tight
        if scM < scaleLimits
            ylim([1-scM*marginFactor 1+scM*marginFactor])
        else
            ylim([1-scaleLimits 1+scaleLimits])
        end
    else
        hsg.set_gca(3,3);
        axis off
    end

    if mean(anglePupil) ~= 0
        hsg.set_gca(4,3); %Pupil Rotation
        plot(t,anglePupil,'.','MarkerSize',1);
        xlabel('time (s)')
        ylabel('rotation (deg)')
        hold on
        scatter(t(kPup), anglePupil(kPup),1, 'r','.');
        agM = max(abs(anglePupil(rPup)));
        axis tight
        if agM < rotationLimits
            ylim([-agM agM]*marginFactor)
        else
            ylim([-rotationLimits rotationLimits])
        end
    else
        hsg.set_gca(4,3);
        axis off
    end
    
    hsg.set_gca(5,3); %Pupil PSNR
    [color,aColor] = getColorPlot(PSNRPup, 1, 3);
    scatter(t, PSNRPup,1,color,'filled');
    set(gca,'Box','on');
    xlabel('time (s)');
    ylabel('PSNR (dB)');
    hold on 
    plot(t,mean(PSNRPup)*ones(imax,1),'b','MarkerSize',1);
    plot(t,(mean(PSNRPup)-3)*ones(imax,1),'r','MarkerSize',1);
    axis tight




    hsg.coltitles({{'Retina'},{'Pupil'}}, 'top', 'Fontsize',18,'FontWeight','normal');
    hsg.coltitles({[{''} CellRetina {''}],[{''} CellPupil {''}]}, 'bottom', 'FontSize',9,'FontWeight','normal');

    curfig = gcf;
    newpos = [2 0 4.1 18]/10;
    set(curfig, 'Units', 'normalized','Position',newpos);
    % PDF Save and resizing of figure
    saveas(figure(1), [PathForMatFile,'\',name1 , '_3Deye.pdf'],'pdf');
    newpos = [2 0.7 4.1 8]/10;
    set(curfig, 'Units', 'normalized','Position',newpos);
elseif nParametersRet > 0
    hsg = subplot_grid(5,2,'no_zoom','mergelist',{[3 4],[5 6],[7 8],[9 10]});

    %title
    formatedName = PathForMovieToReadRetina;

    hsg.figtitle(formatedName,'Fontsize',10,'FontWeight','normal');
    hsg.subfigtitle(' ','Fontsize',1);

    %Retina plots
    hsg.set_gca('viewer',1,1); %MeanRetina
    imshow(MeanRetina);

    hsg.set_gca(1,2); %PathRetina
    scatter(X_TranslationRetina,Y_TranslationRetina,1,'.');
    hold on
    scatter(X_TranslationRetina(kRet), Y_TranslationRetina(kRet),1,'r','.');
    set(gca,'Box','on');
    xmR = max(abs(X_TranslationRetina(rRet)));
    ymR = max(abs(Y_TranslationRetina(rRet)));
    xlabel('x (px)');
    ylabel('y (px)');
    title('translation','FontWeight','normal');
    marginFactor = 1.1;
    if ymR < translationLimits
        ylim([-ymR ymR]*marginFactor)
    else 
        ylim([-translationLimits translationLimits]*marginFactor)
    end
    if ymR < translationLimits
        xlim([-xmR xmR]*marginFactor)
    else 
        xlim([-translationLimits translationLimits]*marginFactor)
    end
    axis square;
    grid on;

    hsg.set_gca(2,1); %translation Retina
    plot(t,X_TranslationRetina,'.','MarkerSize',1);
    hold on
    plot(t,Y_TranslationRetina,'.','color', [0.4940 0.1840 0.5560],'MarkerSize',1);
    xlabel('time (s)')
    ylabel('translation (px)')
    hold on 
    scatter(t(kRet), X_TranslationRetina(kRet),1,'r','.');
    hold on 
    scatter(t(kRet), Y_TranslationRetina(kRet), 1, [0.6350 0.0780 0.1840],'filled');
    axis tight
    if max(xmR,ymR) < translationLimits
        ylim([-max(xmR,ymR) max(xmR,ymR)]*marginFactor)
    else 
        ylim([-translationLimits translationLimits])
    end
    legend('x','y');

    if mean(scaleRetina) ~= 1
        hsg.set_gca(3,1); %Retina scaling
        plot(t,scaleRetina,'.','MarkerSize',1);
        xlabel('time (s)')
        ylabel('scaling (relative)')
        hold on
        scatter(t(kRet), scaleRetina(kRet),1, 'r','.');
        scM = max(abs(scaleRetina(rRet)-1));
        axis tight
        if scM < scaleLimits
            ylim([1-scM*marginFactor 1+scM*marginFactor])
        else
            ylim([1-scaleLimits 1+scaleLimits])
        end
    else
        hsg.set_gca(3,1);
        axis off
    end
    
    if mean(angleRetina) ~= 0
        hsg.set_gca(4,1); %Retina Rotation
        plot(t,angleRetina,'.','MarkerSize',1);
        xlabel('time (s)')
        ylabel('rotation (deg)')
        hold on
        scatter(t(kRet), angleRetina(kRet),1, 'r','.');
        agM = max(abs(angleRetina(rRet)));
        axis tight
        if agM < rotationLimits
            ylim([-agM agM]*marginFactor)
        else
            ylim([-rotationLimits rotationLimits])
        end
    else 
        hsg.set_gca(4,1);
        axis off
    end


    hsg.set_gca(5,1); %Retina PSNR
    [color,aColor] = getColorPlot(PSNRRet, 1, 3);
    scatter(t, PSNRRet,1,color,'filled');
    set(gca,'Box','on');
    xlabel('time (s)');
    ylabel('PSNR (dB)');
    hold on 
    plot(t,mean(PSNRRet)*ones(imax,1),'b','MarkerSize',1);
    plot(t,(mean(PSNRRet)-3)*ones(imax,1),'r','MarkerSize',1);
    axis tight
    
    hsg.coltitles({'Retina'}, 'top', 'Fontsize',18,'FontWeight','normal');
    hsg.coltitles({[{''} CellRetina {''}]}, 'bottom', 'FontSize',9,'FontWeight','normal');

    curfig = gcf;
    newpos = [2 0 2.5 18]/10;
    set(curfig, 'Units', 'normalized','Position',newpos);
    
    % PDF Save and resizing of figure
    saveas(figure(1), [PathForMatFile,'\',name1 , '_3Deye.pdf'],'pdf');
    newpos = [2 0.7 2.5 8]/10;
    set(curfig, 'Units', 'normalized','Position',newpos);
elseif nParametersPup > 0
    hsg = subplot_grid(5,2,'no_zoom','mergelist',{[3 4],[5 6],[7 8],[9 10]});
    
    %title
    formatedName = PathForMovieToReadPupil;
    hsg.figtitle(formatedName,'Fontsize',10,'FontWeight','normal');
    hsg.subfigtitle(' ','Fontsize',1);
    
    %Pupil plots
    hsg.set_gca(1,1); %MeanPupil
    imshow(MeanPupil);

    hsg.set_gca(1,2); %PathPupil
    scatter(X_TranslationPupil,Y_TranslationPupil,1,'.');
    hold on
    scatter(X_TranslationPupil(kPup), Y_TranslationPupil(kPup),1,'r','.');
    set(gca,'Box','on');
    xlabel('x (px)');
    ylabel('y (px)');
    title('translation','FontWeight','normal');
    xmP = max(abs(X_TranslationPupil(rPup)));
    ymP = max(abs(Y_TranslationPupil(rPup)));
    marginFactor = 1.1;
    if ymP < translationLimits
        ylim([-ymP ymP]*marginFactor)
    else 
        ylim([-translationLimits translationLimits]*marginFactor)
    end
    if ymP < translationLimits
        xlim([-xmP xmP]*marginFactor)
    else 
        xlim([-translationLimits translationLimits]*marginFactor)
    end
    axis square
    grid on


    hsg.set_gca(2,1); %translation Pupil
    plot(t,X_TranslationPupil,'.','MarkerSize',1);
    hold on
    plot(t,Y_TranslationPupil,'.','color', [0.4940 0.1840 0.5560],'MarkerSize',1);
    xlabel('time (s)')
    ylabel('translation (px)')
    hold on 
    scatter(t(kPup), X_TranslationPupil(kPup),1,'r','.');
    hold on 
    scatter(t(kPup), Y_TranslationPupil(kPup), 1, [0.6350 0.0780 0.1840],'filled');
    axis tight
    if max(xmP,ymP) < translationLimits
        ylim([-max(xmP,ymP) max(xmP,ymP)])
    else 
        ylim([-translationLimits translationLimits]*marginFactor)
    end
    legend('x','y');

    if mean(scalePupil) ~= 1
        hsg.set_gca(3,1); %Pupil dilation
        plot(t,scalePupil,'.','MarkerSize',1);
        xlabel('time (s)')
        ylabel('scaling (relative)')
        hold on
        scatter(t(kPup), scalePupil(kPup),1, 'r','.');
        scM = max(abs(scalePupil(rPup)-1));
        axis tight
        if scM < scaleLimits
            ylim([1-scM*marginFactor 1+scM*marginFactor])
        else
            ylim([1-scaleLimits 1+scaleLimits])
        end
    else
        hsg.set_gca(3,1);
        axis off
    end

    if mean(anglePupil) ~= 0
        hsg.set_gca(4,1); %Pupil Rotation
        plot(t,anglePupil,'.','MarkerSize',1);
        xlabel('time (s)')
        ylabel('rotation (deg)')
        hold on
        scatter(t(kPup), anglePupil(kPup),1, 'r','.');
        agM = max(abs(anglePupil(kPup)));
        axis tight
        if agM < rotationLimits
            ylim([-agM agM]*marginFactor)
        else
            ylim([-rotationLimits rotationLimits])
        end
    else
        hsg.set_gca(4,1);
        axis off
    end
    
    hsg.set_gca(5,1); %Pupil PSNR
    [color,aColor] = getColorPlot(PSNRPup, 1, 3);
    scatter(t, PSNRPup,1,color,'filled');
    set(gca,'Box','on');
    xlabel('time (s)');
    ylabel('PSNR (dB)');
    hold on 
    plot(t,mean(PSNRPup)*ones(imax,1),'b','MarkerSize',1);
    plot(t,(mean(PSNRPup)-3)*ones(imax,1),'r','MarkerSize',1);
    axis tight




    hsg.coltitles({'Pupil'}, 'top', 'Fontsize',18,'FontWeight','normal');
    hsg.coltitles({[{''} CellPupil {''}]}, 'bottom', 'FontSize',9,'FontWeight','normal');
    
    curfig = gcf;
    newpos = [2 0 2.5 18]/10;
    set(curfig, 'Units', 'normalized','Position',newpos);
    
    % PDF Save and resizing of figure
    saveas(figure(1), [PathForMatFile,'\',name2 , '_3Deye.pdf'],'pdf');
    newpos = [2 0.7 2.5 8]/10;
    set(curfig, 'Units', 'normalized','Position',newpos);
end

