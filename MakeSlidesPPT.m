%% TO BE MODIFIED

% % %planche ppt
% Folder = PathForMatFile;
% DataPath_movie       = fullfile(Folder, [name1, '_3Deye_retina.jpeg']);
% DataPath_ROIs        = fullfile(Folder, [name1, '_3Deye_XTranslation.jpeg']);
% DataPath_plot        = fullfile(Folder, [name1, '_3Deye_pupil.jpeg']);
% DataPath_ResMap      = fullfile(Folder, [name1, '_3Deye_YTranslation.jpeg']);
% DataPath_systdiast   = fullfile(Folder, [name1, '_3Deye_motion.jpeg']);
% DataPath_composite   = fullfile(Folder, [name1, '_3Deye_scale.jpeg']);

%DataPath_movie_cmp   = fullfile(Folder, '200110_GOM0180_OD_ONH1_CompositeMOVIE_ff=2_6-6_25kHz.gif');
 function [] = MakeSlidesPPT(Folder, DataPath_movie, DataPath_ROIs, DataPath_plot, DataPath_ResMap, DataPath_systdiast, DataPath_composite)%, DataPath_movie_cmp)


%Folder               = 'D:\Stage1A\'; 



%% Datapaths

template_name        = 'Dopplerogramme_V5_3_Demo.pptx';
template_Datapath    = fullfile(Folder, template_name);
DataPath_slide       = template_Datapath; % which means the generated slide is added to the template file

Date                 = 200110;
Name                 = 'GOM0180';
Eye                  = 'OD';

IR_A                 = 0.2348;
t_ascend_artery      = 0.0614;
t_mean_artery        = 0.3167;
t_mean_vein          = 0.3375;
t_mean_a2v           = 0.0208;

f                    = [2 6; 2 25; 6 25];
FrequencyBandLow     = 1;
FrequencyBandHigh    = 1;
FrequencyBand_Movie  = 3;
FrequencyBand_AVG    = 3;
FrequencyBand_Plot   = 3;
FrequencyBand_Resist = 3;

% DataPath_movie       = fullfile(Folder, '200110_GOM0180_OD_ONH1_MOVIE_ff=6_25kHz.gif');
% DataPath_ROIs        = fullfile(Folder, 'ROIs.jpg');
% DataPath_plot        = fullfile(Folder, '200110_GOM0180_OD_ONH1_Plots_ff=6_25kHz.png');
% DataPath_ResMap      = fullfile(Folder, '200110_GOM0180_OD_ONH1_ResMap_ff=6_25kHz.jpg');
% DataPath_systdiast   = fullfile(Folder, '200110_GOM0180_OD_ONH1_SystoleDiastole_ff=6_25kHz.jpg');
% DataPath_composite   = fullfile(Folder, '200110_GOM0180_OD_ONH1_Composite_ff=2_6-6_25kHz.jpg');
% DataPath_movie_cmp   = fullfile(Folder, '200110_GOM0180_OD_ONH1_CompositeMOVIE_ff=2_6-6_25kHz.gif');

%% Make slide

import mlreportgen.ppt.*

slides             = Presentation(DataPath_slide, template_Datapath);
masters            = getMasterNames(slides);
slide_current      = add(slides, 'LDH Slide');

% Information about patient
contents           = find(slide_current, 'Infos');
chr                = num2str(Date);
chr                = [chr newline Name];
chr                = [chr newline Eye];
replace(contents(1), chr);

% Pulsatile information
contents           = find(slide_current, 'InfoPulsatility');
chr                = [sprintf('%.2f', IR_A)];
chr                = [chr newline sprintf('%.2f', t_ascend_artery) ' s'];
chr                = [chr newline sprintf('%.2f', t_mean_artery) ' s'];
chr                = [chr newline sprintf('%.2f', t_mean_vein) ' s'];
chr                = [chr newline sprintf('%.2f', t_mean_a2v) ' s'];
replace(contents(1), chr);

% Other infos on measurements
fS = 67;
contents           = find(slide_current, 'InfoMeasurements');
chr                = [num2str(fS) ' kHz'];
chr                = [chr newline num2str(f(FrequencyBandLow, 1)) '-' num2str(f(FrequencyBandLow, 2)) ' kHz'];
chr                = [chr newline num2str(f(FrequencyBandHigh, 1)) '-' num2str(f(FrequencyBandHigh, 2)) ' kHz'];
replace(contents(1), chr);



picture_size       = '7.7';
% LIGNE DU HAUT
contents           = find(slide_current, 'PowerDopplerMovie');
f_string           = [num2str(f(FrequencyBand_Movie, 1)) '-' num2str(f(FrequencyBand_Movie, 2)) ' kHz'];
chr                = ['Power Doppler movie, ' f_string];
replace(contents(1), chr);
plane              = Picture(DataPath_movie);
plane.X            = '5.5cm';
plane.Y            = '1.1cm';
plane.Width        = [picture_size 'cm'];
plane.Height       = [picture_size 'cm'];
add(slide_current, plane);

contents           = find(slide_current, 'PowerDoppler');
f_string           = [num2str(f(FrequencyBand_AVG, 1)) '-' num2str(f(FrequencyBand_AVG, 2)) ' kHz'];
chr                = ['Power Doppler, ' f_string];
replace(contents(1), chr);
plane              = Picture(DataPath_ROIs);
plane.X            = '13.62cm';
plane.Y            = '1.1cm';
plane.Width        = [picture_size 'cm'];
plane.Height       = [picture_size 'cm'];
add(slide_current, plane);

contents           = find(slide_current, 'PowerDopplerVariations');
f_string           = [num2str(f(FrequencyBand_Plot, 1)) '-' num2str(f(FrequencyBand_Plot, 2)) ' kHz'];
chr                = ['Power Doppler variations, ' f_string];
replace(contents(1), chr);
plane              = Picture(DataPath_plot);
plane.X            = '21.57cm';
plane.Y            = '1.1cm';
plane.Width        = '12.3cm';
plane.Height       = [picture_size 'cm'];
add(slide_current, plane);


% LIGNE DU BAS
contents           = find(slide_current, 'ResistivityMap');
f_string           = [num2str(f(FrequencyBand_Resist, 1)) '-' num2str(f(FrequencyBand_Resist, 2)) ' kHz'];
chr                = ['Resistivity, ' f_string];
replace(contents(1), chr);
plane              = Picture(DataPath_ResMap);
plane.X            = '0.15cm';
plane.Y            = '11cm';
plane.Width        = ['9.31cm'];
plane.Height       = [picture_size 'cm'];
add(slide_current, plane);

plane              = Picture(DataPath_systdiast);
plane.X            = '9.83cm';
plane.Y            = '11cm';
plane.Width        = [picture_size 'cm'];
plane.Height       = [picture_size 'cm'];
add(slide_current, plane);

plane              = Picture(DataPath_composite);
plane.X            = '18.02cm';
plane.Y            = '11cm';
plane.Width        = [picture_size 'cm'];
plane.Height       = [picture_size 'cm'];
add(slide_current, plane);

contents           = find(slide_current, 'CompositeMovie');
chr                = 'Composite movie';
replace(contents(1), chr);

close(slides)

end %function