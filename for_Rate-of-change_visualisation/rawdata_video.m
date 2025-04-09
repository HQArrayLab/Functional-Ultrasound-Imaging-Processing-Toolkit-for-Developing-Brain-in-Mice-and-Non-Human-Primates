clear;
clc;
% load scanfus.mat
% fusplane=scanfus;
load 'C:\Users\71053\Desktop\Matlab\fusplane data\2023-06-20'\Sham_2_130327_FusPlane.mat
data1=fusplane.Data;

data_average=(data1);
fusplane.Data=0;
fusplane.Data=data_average(:,:,:);
k=size(fusplane.Data,3);
%%%video
vedio = VideoWriter('456.mp4','MPEG-4'); %初始化一个avi文件
vedio.FrameRate = 10;
open(vedio);
figure('Visible','off')

for i=1:k
    %Im=fusplane.Data(1:size(fusplane.Data,1),1:size(fusplane.Data,2),i)./max(max(fusplane.Data(:,:,i)));
%     Im2=10*log10(Im);
    Im=fusplane.Data(:,:,i);
    Im2=Im.^0.25;
    imagesc(Im2)
    caxis([5,120])
    title(['t',num2str(i)])
    colormap hot;
    colorbar;
%   pause(0.01)
%   saveas(gcf, ['results\t',num2str(i)], 'png')
    frame=getframe(gcf);%获取每帧图片
    writeVideo(vedio,frame);%写入AVI中
end
close(vedio);