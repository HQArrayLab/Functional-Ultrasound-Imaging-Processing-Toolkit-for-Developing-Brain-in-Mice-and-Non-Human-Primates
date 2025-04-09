function cmap = judgeMatrix(M)

uniqueVals = unique(M).'; 

if length(uniqueVals)==2 && all(uniqueVals==[0,1])
   cmap=[1,1,1;0.81,0.68,0.84]; %白，紫
elseif length(uniqueVals)==2 && all(uniqueVals==[0,2])
   cmap=[1,1,1;0.51,0.78,0.97]; %白，蓝
elseif length(uniqueVals)==2 && all(uniqueVals==[0,3])
   cmap=[1,1,1;0.97,0.80,0.40]; %白，黄
elseif length(uniqueVals)==3 && all(uniqueVals==[0,1,2])
   cmap=[1,1,1;0.81,0.68,0.84; 0.51,0.78,0.97]; %白，紫，蓝
elseif length(uniqueVals)==3 && all(uniqueVals==[0,1,3])
   cmap=[1,1,1;0.81,0.68,0.84; 0.97,0.80,0.40]; %白，紫，黄
% elseif length(uniqueVals)==3 && all(uniqueVals==[0,2,3])
%    cmap=[1,1,1;0.51,0.78,0.97; 0.97,0.80,0.40]; %白，蓝，黄
else
   cmap=[1,1,1;0.81,0.68,0.84; 0.51,0.78,0.97; 0.97,0.80,0.40];%白，紫，蓝，黄
end

end