close all;
clear all;

%% Load data
fn='Data/2015_06_30/FE_W(011)_006.hys';
[header,data]=loadHys(fn);

S=0.02;

%Load time
Time=data(:,1);

%Separate time for Raising and Falling
bounds=find(Time==max(Time)|Time==min(Time));

fallingT=Time(bounds(1):bounds(2));
raisingT=Time(bounds(2):bounds(3));

%Q is computed such as mean = 0
Q=sum(data(bounds(1):bounds(end),2))/sum(data(bounds(1):bounds(end),3));

%Compute contrast
Contr=1/S*(Q*data(:,3)-data(:,2))./(Q*data(:,3)+data(:,2));


%Separate lines
for i=(floor((numel(bounds)-3)/2)*2+1):-2:1%make sure we have an even number of back and forth
    idx=(i+1)/2;
    fallingLines(:,idx)=Contr(bounds(i):bounds(i+1));
    raisingLines(:,idx)=Contr(bounds(i+1):bounds(i+2)); 
end

%Switch if rising first
if Time(bounds(1))<Time(bounds(2))
    %Switch time
    tmp=fallingT;
    fallingT=raisingT;
    raisingT=tmp;
    %Switch lines
    tmp=fallingLines;
    fallingLines=raisingLines;
    raisingLines=tmp;
end

%Compute mean on loop
fallingMean=mean(fallingLines,2);
raisingMean=mean(raisingLines,2);

%% Find data shape

%Find data amplitude and flip position
idxF=find(fallingT>0);%Values at HIGH Level
idxR=find(raisingT<0);%Values at LOW level = -HIGH

amplitude=1/2*(mean(mean(fallingLines(idxF,:)))-mean(mean(raisingLines(idxR,:))));

flipFalling=-sum(fallingMean)/(2*amplitude);
flipRaising=-sum(raisingMean)/(2*amplitude);
flip=(flipFalling-flipRaising)/2;

idxHighFalling=fallingT>flip;
idxHighRising=raisingT>-flip;

modelF=amplitude.*(idxHighFalling-(~idxHighFalling));
modelR=amplitude.*(idxHighRising-(~idxHighRising));
%{
figure
hold all;
plot(fallingT,fallingMean);
%plot(raisingT,raisingMean);
plot(fallingT,modelF);
%plot(raisingT,modelR);

plot(fallingT,fallingMean-modelF);
%plot(raisingT,raisingMean-modelR);
%}




%% Plot Raw Data
figure
hold on;

for i=1:size(raisingLines,2)
    plot(fallingT,fallingLines(:,i),'b');
    plot(raisingT,raisingLines(:,i),'r');
end
title(sprintf('Raw data S=%.4f Q=%.2f',S,Q));
legend('Falling','Raising');



%% Plot Mean Over line
figure
plot(fallingT,fallingMean)
hold all
plot(raisingT,raisingMean)
plot(fallingT,modelF);
plot(raisingT,modelR);

%plot center
plot([max(Time),min(Time)],[0,0],'g')
plot([0,0],[max(fallingMean),min(fallingMean)],'g')



title('Mean over loops');
legend('Mean Falling','Mean Raising','center');



%% Combine back & forth & plot
MeanBoth=mean([fallingMean,-raisingMean],2);

%Plot
figure
plot(fallingT,fallingMean)
hold all
plot(-raisingT,-raisingMean)
plot(fallingT,MeanBoth, 'LineWidth',3);

%Plot center
plot([max(Time),min(Time)],[0,0],'g')
plot([0,0],[max(MeanBoth),min(MeanBoth)],'g')

title('Mean over loops + symmetry');
legend('Mean Falling','Symmetry of Raising','Mean','Center')
