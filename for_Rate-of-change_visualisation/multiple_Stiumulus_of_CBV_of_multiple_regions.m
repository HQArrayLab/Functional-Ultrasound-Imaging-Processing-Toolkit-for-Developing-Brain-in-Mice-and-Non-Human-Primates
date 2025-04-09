clear;
clc;
% load scanfus.mat;
load 'F:'\2023-11-03\Trial2_cor_sAMY_DMH_100917_FusPlane.mat
% fusplane=scanfus;
data1=fusplane.Data;
% data1=fliplr(data1);
%%%%%%
addpath('./for_u1/')
load('dataAtlas');
slice =138;
rx=1.65; 
ry=2;
% X=1:size(data1,2);
% Z=1:size(data1,1);
X=1:size(data1);
Z=1:size(data1);
xk=0.67*10;
xb=-3;
yk=1.40*13;
yb=-10;


%%%%%%%%%time
frame=10;
times=[1/frame:1/frame:size(data1,3)/frame];

roi_num=2;
color=['k','g','b','m'];
k=size(data1,3);
dimension_x=0.1*size(data1,2);
dimension_z=0.075*size(data1,1);


figure;
Im_average=mean(data1,3);
Im_average2=Im_average.^0.25;
imagesc(Im_average2)
title('regions of interest')
% caxis([5 100]); 
colormap hot;
hold on
addLines(LinReg.Cor,slice,rx, ry,X,Z,xk,xb,yk,yb);
% daspect([dimension_z*2,dimension_x,1])    %%%绘图比例
% text(1,5,'Left click to get points,right click to get end point','FontSize',12,'Color','g');


%%%%%%%choose ROI%%%%%%%%%%%%%%%%%
rect=1;
for n=1:roi_num
    %% 矩形或圆形ROI
    mask=zeros(size(data1(:,:,1)));
    [x,z]=ginput(1);
    %方形
    mask(round(z)-rect:round(z)+rect,round(x)-rect:round(x)+rect)=1;
    %圆形
%     for nx=1:size(mask,2)
%         for nz=1:size(mask,1)
%             if norm([x-nx,z-nz],2)<rect
%                 mask(nz,nx)=1;
%             end
%         end
%     end

     roi_mask(:,:,n)=mask;

    %% 任意ROI
%     roi_mask(:,:,n)=roipoly;
    %%

    % imagesc(roi_mask)
    % daspect([dimension_z*2,dimension_x,1])    %%%绘图比例
    phi(:,:,n)=2*2*(0.5-roi_mask(:,:,n));


%     figure;
    imagesc(Im_average2);
    colormap('hot')
    title('regions of interest')
%     daspect([dimension_z*2,dimension_x,1])
    %text(1,5,'Left click to get points,right click to get end point','FontSize',12,'Color','g');
    hold on
    
    for k=1:n
        [c,h]=contour(phi(:,:,k),[0 0],color(k));
    end
     addLines(LinReg.Cor,slice,rx, ry,X,Z,xk,xb,yk,yb);
end 

hold off
%%%%%%%%%%%%%结束%%%%%%%%%%%%%%%%%

%%%%%%%%%calculate%%%%%%%%%
data_average=data1;
figure;
hold on
for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
dd2=data_average.*roi_mask_temp;
roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
plot(times,roi_average);
end
xlabel('Time(s)')
ylabel('Cerebral blood volume')
title('Cerebral blood volume of several regions')
hold off

figure;
hold on
for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
    dd2=data_average.*roi_mask_temp;
    roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
    
    roi_average_temp=roi_average(1:499);
    F0=mean(roi_average_temp(200:300));
    dF1=(roi_average_temp-F0)./F0;
    
    roi_average_temp=roi_average(500:1499);
    F0=mean(roi_average_temp(200:300));
    dF2=(roi_average_temp-F0)./F0;

    roi_average_temp=roi_average(1500:2499);
    F0=mean(roi_average_temp(200:300));
    dF3=(roi_average_temp-F0)./F0;

    roi_average_temp=roi_average(2500:3499);
    F0=mean(roi_average_temp(200:300));
    dF4=(roi_average_temp-F0)./F0;

    roi_average_temp=roi_average(3500:4000);
    F0=mean(roi_average_temp(200:300));
    dF5=(roi_average_temp-F0)./F0;   
    roi_average2=[dF1',dF2',dF3',dF4',dF5'];

    plot(times,roi_average2+i,color(i));
    roi_dF(i,:)=roi_average2;
    axis([0 400 0.5 3])
end
save roi_dF.mat roi_dF

stimulus(100:101)=3;
stimulus(200:201)=3;
stimulus(300:301)=3;
stimulus(302:400)=0;
plot(stimulus,"LineWidth",2,"Color","c")

xlabel('Time(s)')
ylabel('the change rate of Cerebral blood volume')
title('Blood flow growth rate of several regions')
grid on
hold off
stimulus=[];

%%%%（多个区域的原始data调取）
roi_mask_temp=roi_mask(:,:,1);
dd2=data_average.*roi_mask_temp;
roi1_rawdata=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
save roi1_rawdata.mat roi1_rawdata;
A1=roi1_rawdata(500:1500);
F0=mean(A1(1:400));
A1=(A1-F0)/F0;

A2=roi1_rawdata(1500:2500);
F0=mean(A2(1:400));
A2=(A2-F0)/F0;

A3=roi1_rawdata(2500:3500);
F0=mean(A3(1:400));
A3=(A3-F0)/F0;

A7=(A1+A2+A3)/3;
% F0=mean(A7(1:400));
% A7=(A7-F0)/F0;

num=3;%%%%%%%%  刺激次数
windows = 5;        %设置窗口数量        filter（b,a,x）;
b = 1/windows*(ones(1,windows));              %移动平均滤波器

for i=1:num  
    cmd=['data_smooth',num2str(i),'= filter(b,1,A',num2str(i),');'];%%%% A是region1的刺激
    eval(cmd)
end

frame=10;  %10
times=[1/frame:1/frame:length(A7)/frame];

for i=1:num
    cmd=['average_temp(:,i)=data_smooth',num2str(i),';'];
    eval(cmd)
end

average=mean(average_temp,2);
SD=std(average_temp,0,2);
SEM=SD./sqrt(size(average_temp,2));
MAX=average+SEM;
MIN=average-SEM;

for i=1:num
    cmd=['average_orgin(:,i)=A',num2str(i),';'];%%%%%%%%%
    eval(cmd)
end

figure;
plot(times,average,'k',LineWidth=2)
patch([times,fliplr(times)],[MIN',fliplr(MAX')],'r','edgecolor','none','FaceAlpha',0.5);
axis([0 length(A7)/frame -0.1 0.2]);
xlabel('Time(s)')
ylabel('Z-score')
title('\DeltaF/F of region1')


roi_mask_temp=roi_mask(:,:,2);
dd2=data_average.*roi_mask_temp;
roi2_rawdata=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
save roi2_rawdata.mat roi2_rawdata;
B1=roi2_rawdata(500:1500);
F0=mean(B1(1:400));
B1=(B1-F0)/F0;

B2=roi2_rawdata(1500:2500);
F0=mean(B2(1:400));
B2=(B2-F0)/F0;

B3=roi2_rawdata(2500:3500);
F0=mean(B3(1:400));
B3=(B3-F0)/F0;

B7=(B1+B2+B3)/3;
% F0=mean(B7(1:400));
% B7=(B7-F0)/F0;

for i=1:num  
    cmd=['data_smooth',num2str(i),'= filter(b,1,B',num2str(i),');'];%%%%%%%
    eval(cmd)
end

% frame=10;  %10
% times=[1/frame:1/frame:length(B7)/frame];

for i=1:num
    cmd=['average_temp(:,i)=data_smooth',num2str(i),';'];
    eval(cmd)
end

average=mean(average_temp,2);
SD=std(average_temp,0,2);
SEM=SD./sqrt(size(average_temp,2));
MAX=average+SEM;
MIN=average-SEM;

for i=1:num
    cmd=['average_orgin(:,i)=B',num2str(i),';'];%%%%%%%
    eval(cmd)
end

figure;
plot(times,average,'g',LineWidth=2)
patch([times,fliplr(times)],[MIN',fliplr(MAX')],'r','edgecolor','none','FaceAlpha',0.5);
axis([0 length(A7)/frame -0.1 0.2]);
xlabel('Time(s)')
ylabel('Z-score')
title('\DeltaF/F of region2')




% roi_mask_temp=roi_mask(:,:,3);
% dd2=data_average.*roi_mask_temp;
% roi3_rawdata=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
% save roi3_rawdata.mat roi3_rawdata;
% C1=roi3_rawdata(1000:2000);
% C2=roi3_rawdata(2000:3000);
% C3=roi3_rawdata(3000:4000);
% C4=roi3_rawdata(4000:5000);
% C7=(C1+C2+C3+C4)/4;
% F0=mean(C7(1:400));
% C7=(C7-F0)/F0;
% 
% roi_mask_temp=roi_mask(:,:,4);
% dd2=data_average.*roi_mask_temp;
% roi4_rawdata=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
% save roi4_rawdata.mat roi4_rawdata;
% D1=roi4_rawdata(1000:2000);
% D2=roi4_rawdata(2000:3000);
% D3=roi4_rawdata(3000:4000);
% D4=roi4_rawdata(4000:5000);
% D7=(D1+D2+D3+D4)/4;
% F0=mean(D7(1:400));
% D7=(D7-F0)/F0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 平滑
windows = 10;        %设置窗口数量        filter（b,a,x）;
b = 1/windows*(ones(1,windows));              %移动平均滤波器
stim1 = filter(b,1,A7);
stim2 = filter(b,1,B7);
% stim3 = filter(b,1,C7);
% stim4 = filter(b,1,D7);

figure
stimulus(500:510)=0.2;
stimulus(511:1000)=0;
plot(stimulus)
hold on
plot(stim1,'k-')
axis([0 1000 -0.1 0.3])
xlabel('frame rate')
ylabel('the change rate of Cerebral blood volume')
title('Growth curve of cerebral blood volume of region1')


figure
stimulus(500:510)=0.2;
stimulus(511:1000)=0;
plot(stimulus)
hold on
plot(stim2,'g-')
axis([0 1000 -0.1 0.2])
xlabel('frame rate')
ylabel('the change rate of Cerebral blood volume')
title('Growth curve of cerebral blood volume of region2')

% figure
% stimulus(500:510)=0.2;
% stimulus(511:1000)=0;
% plot(stimulus)
% hold on
% plot(stim3,'b-')
% xlabel('frame rate')
% ylabel('the change rate of Cerebral blood volume')
% title('Growth curve of cerebral blood volume of region3')
% 
% figure
% stimulus(500:510)=0.2;
% stimulus(511:1000)=0;
% plot(stimulus)
% hold on
% plot(stim4,'m-')
% xlabel('frame rate')
% ylabel('the change rate of Cerebral blood volume')
% title('Growth curve of cerebral blood volume of region4')
% set(gca,'YTick',[]);


%%%%（区域1/区域2）再求DF
% a=roi1_average./roi2_average;
% F0=mean(a(1:1000));
% roi_average=(a-F0)./F0;
% plot(roi_average)
% save roi_average.mat roi_average
