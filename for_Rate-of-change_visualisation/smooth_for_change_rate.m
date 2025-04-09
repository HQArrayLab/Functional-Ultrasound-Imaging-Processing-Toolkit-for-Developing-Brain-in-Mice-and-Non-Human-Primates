clear;
clc;
%load roi_average2.mat;
load roi_dF.mat;



%% 平滑滤波

windows =10;        %设置窗口数量        filter（b,a,x）;
b = 1/windows*(ones(1,windows));              %移动平均滤波器

figure
stim = filter(b,1,roi_dF(1,:));
grid on
plot(stim,'k-')
hold on
set(gca,'xtick',[0 1000 2000 3000 4000],'xticklabel',{'0' '100' '200' '300' '400'})
axis([0 4000 -0.1 0.2])
xlabel('Time(s)')
ylabel('Change rate of Cerebral blood volume (%)')
title('Growth curve of cerebral blood volume of region1')

stimulus(1000:1020)=0.2;
stimulus(2000:2020)=0.2;
stimulus(3000:3020)=0.2;
stimulus(3021:4000)=0;
plot(stimulus,"LineWidth",2,"Color","c")


figure
stim = filter(b,1,roi_dF(2,:));
grid on
plot1=plot(stim,'g-');
hold on
% plot1.Color(4) = 0.5;
stimulus(1000:1020)=0.2;
stimulus(2000:2020)=0.2;
stimulus(3000:3020)=0.2;
stimulus(3021:4000)=0;
plot(stimulus,"LineWidth",2,"Color","c")
set(gca,'xtick',[0 1000 2000 3000 4000],'xticklabel',{'0' '100' '200' '300' '400'})
axis([0 4000 -0.2 0.4])
xlabel('Time(s)')
ylabel('Change rate of Cerebral blood volume (%)')
title('Growth curve of cerebral blood volume of region2')

% figure
% stim = filter(b,1,roi_dF(3,:));
% grid on
% plot1=plot(stim,'b-');
% hold on 
% stimulus(1500:1520)=0.2;
% stimulus(2500:2520)=0.2;
% stimulus(3500:3520)=0.2;
% stimulus(4500:4520)=0.2;
% stimulus(4521:6000)=0;
% plot(stimulus)
% % plot1.Color(4) = 0.4;
% set(gca,'xtick',[0 1500 2500 3500 4500 6000],'xticklabel',{'0' '150' '250' '350' '450' '600'})
% axis([0 6000 -0.5 0.8])
% xlabel('Time(s)')
% ylabel('Change rate of Cerebral blood volume (%)')
% title('Growth curve of cerebral blood volume of region3')
% 
% figure
% stim = filter(b,1,roi_dF(4,:));
% axis([0 6000 -0.5 0.6])
% grid on
% plot1=plot(stim,'m-');
% hold on
% % plot1.Color(4) = 0.5;
% set(gca,'xtick',[0 1500 2500 3500 4500 6000],'xticklabel',{'0' '150' '250' '350' '450' '600'})
% axis([0 6000 -0.5 0.5])
% xlabel('Time(s)')
% ylabel('Change rate of Cerebral blood volume (%)')
% title('Growth curve of cerebral blood volume of region4')
% stimulus(1500:1520)=0.2;
% stimulus(2500:2520)=0.2;
% stimulus(3500:3520)=0.2;
% stimulus(4500:4520)=0.2;
% stimulus(4521:6000)=0;
% plot(stimulus)

%hold on
%%%%%%%%%%%%%%%%%%%%%%

% windows = 20;        %设置窗口数量        filter（b,a,x）;
% B = 2/windows*(ones(2,windows));              %移动平均滤波器
% stim = filter(B,2,roi_average1);
% %save stim.mat stim;
% grid on
% plot(stim)
% hold on
% 
% stim = filter(B,2,roi_average2);
% %save stim.mat stim;
% grid on
% plot(stim)
% hold on
% 
% stim = filter(B,2,roi_average3);
% %save stim.mat stim;
% grid on
% plot(stim)
% hold on
% 
% xlabel('frame rate')
% ylabel('Cerebral blood volume')
% title('Average blood flow curve')
% hold off

%%%%%%%%%%%%%%% 
% t=0:1:32000;
% stimulus=zeros(1,length(t));
% stimulus(1200:1280)=0.2;
% plot(stimulus)
% hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%
% y=-0.5:0.5;
% x=zeros(1,length(y));
% plot(x,y)
%axis([0 6000 -0.3 3]);
% hold off
% figure
% stim=x1(401:3200);
% save stim.mat stim
% plot([0:0.5:1400],stim)