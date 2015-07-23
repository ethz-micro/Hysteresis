close all
clear all
%% Load data

fn = 'Data/2015_06_15/FE_W(011)_002.hys';
%fn = 'Data/2015_06_03/FE_W(011)_001.hys';

contact=-280e-9;
S=0.1;
[Header,Data]=load.loadHys(fn);
hys=load.processHys(Data,Header,S,contact);

% plot hysteresis

plot.plotHys(hys)

%% look at curve
[NE,RMS]=op.getNeRmsCrv(Data,Header,S,contact);
figure
plot(1./NE,RMS.^2,'x--');
xlabel('1/Neq');
ylabel('Variance')
set(gca,'FontSize',20)

%% plot given number of loops
maxLoop=27;
hys=load.processHys(Data,Header,S,contact,maxLoop);

plot.plotHys(hys)