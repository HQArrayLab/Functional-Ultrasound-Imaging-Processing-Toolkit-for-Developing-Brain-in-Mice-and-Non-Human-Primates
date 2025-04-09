function [pymatrix,NREMREMmat,percent]=calculation(ycut,yd,Row,Column)

for i=1:Row
    mean_value = mean(ycut(i,:)); 
    ycut(i,:) = ycut(i,:) - mean_value; 
end

percentmatrix=[];
fmatrix=[];
delta_percentvec=[];
theta_percentvec=[];
pymatrix=[];
for i=1:Row
    Fs=20;
    [py, f] = pburg(ycut(i,:), 10, Column, Fs);
    power_total = sum(py);
    percent = py ./ power_total * 100;
    percent=percent.';
    f=f.';
    py=py.';
    pymatrix=[pymatrix;py];
    percentmatrix=[percentmatrix;percent];
    fmatrix=[fmatrix;f];
    
    delta_power = 0;
    for j = 1:length(f)
      if f(j) >= 0.5 && f(j) < 4
        delta_power = delta_power + py(j); 

      end  
    end
    delta_percent = delta_power/power_total * 100;
    delta_percentvec=[delta_percentvec,delta_percent];

    theta_power = 0;
    for j = 1:length(f)
      if f(j) >= 6 && f(j) < 10
        theta_power = theta_power + py(j); 

      end  
    end
    

    theta_percent = theta_power/power_total * 100;
    theta_percentvec=[theta_percentvec,theta_percent];
    subplot(2,1,1)
    plot(ycut(i,:))
    ylim([-0.2, 0.2])
    subplot(2,1,2)

    plot(f,percent)
    str = num2str(i); 
    title(str);
    xlim([0, 10]);
    ylim([0, 30]);
    pause(0.5)

end
delta_theta=[delta_percentvec;theta_percentvec];
% figure
% plot(delta_percentvec)
% hold on
% plot(theta_percentvec)
% hold off

NREMREMmat = zeros(3,length(delta_percentvec));

countREM=0;
countNREM=0;
countWake=0;
for i=1:length(delta_percentvec)

  delta_theta_diff = delta_percentvec(i) - theta_percentvec(i);


  if delta_theta_diff <= -10
    stage = 1;  % REM
    countREM=countREM+1;
  elseif delta_theta_diff >= 10
    stage = 2;  % NEM
    countNREM=countNREM+1;
  else
    stage = 3;  % WAKE
    countWake=countWake+1;
  end
  
  NREMREMmat(stage,i) = stage;
  
end

percentREM=countREM/(countREM+countNREM+countWake)*100;
percentNREM=countNREM/(countREM+countNREM+countWake)*100;
percentWAKE=countWake/(countREM+countNREM+countWake)*100;
percent=[percentREM,percentNREM,percentWAKE];
% figure
% bar([1,2,3],[percentREM,percentNREM,percentWAKE])
% set(gca,'XTickLabel',categorical({'REM' 'NREM' 'WAKE'}))
