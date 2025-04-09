clear,clc
close all
filepath='D:\aHDM de Matlab\fusplane data\2023-11-03\trial 2 DMH cor';
filename = 'Trial2_cor_sAMY_DMH_100917_FusPlane';
load(filename)
load('dataAtlas');
data1=fusplane.Data(:,:,:);

slice =138;
rx=1.65; 
ry=2;
X=1:size(data1);
Z=1:size(data1);
xk=0.67*10;
xb=-3;
yk=1.40*13;
yb=-5;



color_list=[
            1 0 0;           %red
            0 0 1;           %blue
            0.13 0.55 0.13;  %绿
            0.6 0.1 0.9      %紫
            0.9290 0.6940 0.1250   %黄
            0 0 0 %black
            0.5 0.5 0.5]; %grey

%确定分析多少个脑区
roi_num=1;
k=size(fusplane.Data,3);
dimension_x=0.075*size(fusplane.Data,2);
dimension_z=0.1*size(fusplane.Data,1);

figure;
Im_average=mean(fusplane.Data,3);
Im_average2=Im_average.^0.25;
imagesc(Im_average2)
title([strrep(filename,'_','-'),'background'])
caxis([5 120]); 
colormap hot;  
addLines(LinReg.Cor,slice,rx, ry,X,Z,xk,xb,yk,yb);
daspect([dimension_x,dimension_z*1,1]) %%绘图比例
saveas(gca,[filepath,filename,'.background.png'])

for n=1:roi_num
roi_mark(:,:,n)=roipoly;
phi(:,:,n)=2*2*(0.5-roi_mark(:,:,n));

figure;
imagesc(Im_average2);
colormap('hot')
caxis([5 120]); 
addLines(LinReg.Cor,slice,rx, ry,X,Z,xk,xb,yk,yb);
daspect([dimension_x,dimension_z*1,1])
hold on

for k=1:n
[c,h]=contour(phi(:,:,k),[0 0],'Color',color_list(k,:));
end
end 
saveas(gca,[filepath,filename,'.background.fig']);
hold off
saveas(gca,[filepath,filename,'.background.png']);
hold off
save([filepath,filename,'roi_mark.mat'],'roi_mark');  %% save roi mask

%%%%%%%%%time
frame=10;
times=[1/frame:1/frame:size(data1,3)/frame];


%%%%%%%%% calculate intensity %%%%%%%%%
% load '2023-04-120412-electric-1_162209_FusPlaneroi_mark.mat'

data_average=data1;
figure;
hold on
for i=1:roi_num
    roi_mark_temp=roi_mark(:,:,i);
dd2=data_average.*roi_mark_temp;
roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mark_temp(:));
roi_average = filloutliers(roi_average,"nearest","mean");
roi_average=roi_average-i*800000;
plot(times,roi_average,'Color',color_list(i,:));
end
xlabel('Time(s)')
ylabel('Cerebral blood volume')
title('Cerebral blood volume of several regions')
saveas(gca,[filepath,filename,' heart_intensity.fig']);
hold off

figure;
hold on
for i=1:roi_num
    roi_mark_temp=roi_mark(:,:,i);
    dd2=data_average.*roi_mark_temp;
    roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mark_temp(:));
    roi_average = filloutliers(roi_average,"nearest","mean");

    roi_average_temp=roi_average(1:499);
    F0=mean(roi_average_temp(1:300));
    dF1=(roi_average_temp-F0)./F0;
    
    roi_average_temp=roi_average(500:1499);
    F0=mean(roi_average_temp(1:300));
    dF2=(roi_average_temp-F0)./F0;

    roi_average_temp=roi_average(1500:2499);
    F0=mean(roi_average_temp(1:300));
    dF3=(roi_average_temp-F0)./F0;

    roi_average_temp=roi_average(2500:3499);
    F0=mean(roi_average_temp(1:300));
    dF4=(roi_average_temp-F0)./F0;

    roi_average_temp=roi_average(3500:4000);
    F0=mean(roi_average_temp(1:300));
    dF5=(roi_average_temp-F0)./F0;   

    roi_average2=[dF1',dF2',dF3',dF4',dF5'];

%     roi_average2=roi_average2-2*i;
    plot(times,roi_average2,'Color',color_list(i,:));
%     axis([10 30 -1.5 6])
end
xlabel('Time(s)')
ylabel('the change rate of Cerebral blood volume')
title('Blood flow growth rate of several regions')
grid on
hold off

%%%%（roi 多次trial 平均值）
    figure
    for i=1:roi_num
    hold on
    roi_mark_temp=roi_mark(:,:,i);
    data2=data_average.*roi_mark_temp;
    roi_average=squeeze(sum(sum(data2,1),2))./sum(roi_mark_temp(:));  
    roi_average = filloutliers(roi_average,"nearest","mean");
    
    trial1=roi_average(500:1500);
    trial2=roi_average(1500:2500);
    trial3=roi_average(2500:3500);
    trial4=(trial1+trial2+trial3)./3;

    F0=mean(trial4(200:400));
    trial_roi_average=(trial4-F0)./F0;
%     trial_roi_average=trial_roi_average-0.5*i;
    plot(trial_roi_average,'Color',color_list(i,:));
    end
    hold off
    title('dF of several regions')
    saveas(gca,[filepath,filename,' dF_average.fig']);
    saveas(gca,[filepath,filename,' dF_average.png']);

%% calculate Zscore
data_average=data1;

    figure;
    hold on
    for i=1:roi_num
    roi_mark_temp=roi_mark(:,:,i);
    data2=data_average.*roi_mark_temp;
    roi_average=squeeze(sum(sum(data2,1),2))./sum(roi_mark_temp(:));  
    roi_average = filloutliers(roi_average,"nearest","mean");

    roi_average_temp=roi_average(1:499);
    F0=mean(roi_average_temp(1:300));
    dF1=(roi_average_temp-F0)./F0;
    
    roi_average_temp=roi_average(500:1499);
    F0=mean(roi_average_temp(1:300));
    dF2=(roi_average_temp-F0)./F0;

    roi_average_temp=roi_average(1500:2499);
    F0=mean(roi_average_temp(1:300));
    dF3=(roi_average_temp-F0)./F0;

    roi_average_temp=roi_average(2500:3499);
    F0=mean(roi_average_temp(1:300));
    dF4=(roi_average_temp-F0)./F0;

    roi_average_temp=roi_average(3500:4000);
    F0=mean(roi_average_temp(1:300));
    dF5=(roi_average_temp-F0)./F0;   

    roi_average2=[dF1',dF2',dF3',dF4',dF5'];

    F0=mean(roi_average2(1:300));
    roi_average=(roi_average2-F0)./F0;

    stimN = roi_average-mean(roi_average);
    stimN = stimN./sqrt(mean(stimN.^2));
%     stimN = filloutliers(stimN,"nearest","mean");
%     stimN=stimN-5*i;
    x=(1:1:length(stimN)).*0.1;  %10Hz_0.1s %20Hz_0.05s
    plot(x,stimN,'Color',color_list(i,:));
%     axis([0 50 -45 -5])
%     set(gca,'xtick',[],'ytick',[],'xcolor','w','ycolor','w') % 'xcolor','w','ycolor','w'
    end
    title([strrep(filename,'_','-'),' Zscore'])
%     legend({'Heart_1','Forebrain','Midbrain','Hindbrain'},'Location','northeast')
    set(gcf,'outerposition',get(0,'screensize'));
    grid off
    hold off
    saveas(gca,[filepath,filename,' Zscore.fig']);
    saveas(gca,[filepath,filename,' Zscore.png']);

%%%%（roi 多次trial 平均值）
    figure
    for i=1:roi_num
    hold on
    roi_mark_temp=roi_mark(:,:,i);
    data2=data_average.*roi_mark_temp;
    roi_average=squeeze(sum(sum(data2,1),2))./sum(roi_mark_temp(:));  
    roi_average = filloutliers(roi_average,"nearest","mean");

    trial1=roi_average(500:1500);
    trial2=roi_average(1500:2500);
    trial3=roi_average(2500:3500);
    trial4=(trial1+trial2+trial3)./3;

    stimN = trial4-mean(trial4(200:400));
    stimN = stimN./sqrt(mean(stimN.^2));
%     stimN=stimN-5*i;
    plot(stimN,'Color',color_list(i,:));
    end
    hold off
    title('ZScore of several regions')
    saveas(gca,[filepath,filename,' Zscore_average.fig']);
    saveas(gca,[filepath,filename,' Zscore_average.png']);
