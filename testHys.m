close all;
clear all;


%Z ; Bias
%06-15 + ; cte
%18-27 + ; - ; I=cte
%28-37 + ; - ; Counts=cte
%38-44 cte ; +
%45-53 cte ; +

%% Load data

dataSet=1;

switch dataSet
    case 1
        BaseName='Data/2015_07_08/FE_W(011)_';
        VarName='Z [nm]';
        idx=3:47;
        contact=-239e-9;
    case 2
        BaseName='Data/2015_07_02/FE_W(011)_';
        VarName='Z [nm]';
        idx=6:15;
        contact=-232e-9;
    case 3
        BaseName='Data/2015_07_02/FE_W(011)_';
        VarName='Z [nm]';
        idx=18:27;
        contact=-257e-9;
    case 4
        BaseName='Data/2015_07_02/FE_W(011)_';
        VarName='Z [nm]';
        idx=28:37;
        contact=-274e-9;
    case 5
        BaseName='Data/2015_07_02/FE_W(011)_';
        VarName='Bias [V]';
        idx=38:44;
        contact=-286e-9;
    case 6
        BaseName='Data/2015_07_02/FE_W(011)_';
        VarName='Bias [V]';
        idx=45:53;
        contact=-286e-9;
    case 7
        BaseName='Data/2015_06_30/FE_W(011)_';
        VarName='Bias [V]';
        idx=3:12;
        contact=-340e-9;
    case 8
        BaseName='Data/2015_06_30/FE_W(011)_';
        VarName='Bias [V]';
        idx=14:20;
        contact=-340e-9;
    case 9
        BaseName='Data/2015_06_29/FE_W(011)_';
        VarName='Bias [V]';
        idx=7:17;
        contact=-280e-9;
        
    case 10
        BaseName='Data/2015_06_10/FE_W(011)_';
        VarName='Index';
        idx=1:35;%15;
        contact=0;
    case 11
        BaseName='Data/2015_06_04/FE_W(011)_';
        VarName='Index';
        idx=1:8;
        contact=0;
    case 12
        BaseName='Data/2015_06_10/FE_W(011)_';
        VarName='Index';
        idx=16:21;
        contact=-316e-9;
    case 13
        BaseName='Data/2015_06_10/FE_W(011)_';
        VarName='Bias [V]';
        idx=25:35;
        contact=-346e-9;
    case 14
        BaseName='Data/2015_06_15/FE_W(011)_';
        VarName='Index';
        idx=4:13;
        contact=-315e-9;
    case 15
        BaseName='Data/2015_07_16/FE_W(011)_';
        VarName='Z [nm]';
        idx=3:12;
        contact=-280e-9;
        
end

S=0.1;


% Load & process Data
Ext='.hys';
fns=arrayfun(@(x) [BaseName, num2str(x,'%03u'), Ext],idx,'UniformOutput',false);
[headers,datas]=cellfun(@loadHys,fns,'UniformOutput',false);
hys=cellfun(@(x,y) processHys(x,y,S,contact),datas,headers);

% Prepare variables
Bias=arrayfun(@(x) x.header.TIP_BIAS_V,hys);
Z=arrayfun(@(x) x.header.TIP_Z_m,hys).*1e9;

if strcmp(VarName,'Bias [V]')
    Var=Bias;
    VarUnit='V';
elseif strcmp(VarName,'Z [nm]')
    Var=Z;
    VarUnit='nm';
elseif strcmp(VarName,'Index')
    Var=1:numel(hys);
    VarUnit='';
end

polName = sprintf('Polarization (Uncalib., S=%g) [au]',S);


%% signal/noise

RMS=arrayfun(@(x) x.model.rms,hys);
amp=arrayfun(@(x) x.model.amplitude,hys);
figure
hold all
plot(Var,amp./RMS,'x-')
title('Signal over RMS')

xlabel(VarName)
ylabel('Signal/Noise')
set(gca,'FontSize',15)


%% Bias
figure
plot(Z,abs(Bias),'x-')
title('Bias vs Z')
xlabel('Z [nm]')
ylabel('Bias [V]')
set(gca,'FontSize',15)
%% R-Squared
RS=arrayfun(@(x) x.model.RSquared,hys);
figure
plot(Var,RS,'x-')
title('R-Squared')
xlabel(VarName)
ylabel('R-Squared [au]')
set(gca,'FontSize',15)
%% Amplitude and RMS
RMS=arrayfun(@(x) x.model.rms,hys);
amp=arrayfun(@(x) x.model.amplitude,hys);
ampSTD=arrayfun(@(x) x.model.ampSTD,hys);
diffAmp=arrayfun(@(x) x.model.diffAmp,hys);
meanContr=arrayfun(@(x) x.meanContr,hys);
figure
hold all
errorbar(Var,amp,2*ampSTD,'x-')
plot(Var,RMS,'x-')
plot(Var,meanContr,'x-')
plot(Var,diffAmp,'x-')
title('Signal amplitude and RMS')
legend('Signal amplitude', 'Noise RMS')

xlabel(VarName)
ylabel(polName)
set(gca,'FontSize',15)

%% Flip index
flipIdx=arrayfun(@(x) x.model.flipIdx,hys);
flipSTD=arrayfun(@(x) x.model.flipSTD,hys);
figure
errorbar(Var,flipIdx,2*flipSTD,'x-')
title('Coercity field')
xlabel(VarName)
ylabel('Load time [\mus]')
set(gca,'FontSize',15)

%% Q factor
Q=arrayfun(@(x) x.Q,hys);
figure
plot(Var,Q,'x-')
title('Q')
xlabel(VarName)
ylabel('Correction factor Q [au]')
set(gca,'FontSize',15)

%% Current
I=arrayfun(@(x) x.meanI,hys);
figure
plot(Var,I,'x-')
title('Current')

xlabel(VarName)
ylabel('current [I]')
set(gca,'FontSize',15)
%% Counts
CH0=arrayfun(@(x) x.meanCH0,hys);
CH2=arrayfun(@(x) x.meanCH2,hys);
figure
plot(Var,CH0,Var,CH2,'x-')
title('Counts')
legend('Channel 0','Channel 2')
xlabel(VarName)
ylabel('Counts [Hz]')
set(gca,'FontSize',15)

%% F-N
figure

V=abs(Bias);
D=Z.*1e-9;
E=V./D;
J=I;


plot(1./E,log(J./E.^2),'x-')
title('F-N')
ylabel('log(J./E.^2)')
xlabel('1./E')

%% Current vs counts
figure
plot(I,CH0,'x-',I,CH2,'x-')
title('Counts vs Current')
legend('Channel 0','Channel 2','Location','northwest')
xlabel('current [I]')
ylabel('Counts [Hz]')
set(gca,'FontSize',15)

%% Plot hysteresis
plotHys(hys(4));
%For each data set
%for i=11:11%size(hys,2)

%end


%% RMS VS # electrons in one detector
names=arrayfun(@(x) sprintf(['%d' VarUnit],round(x)),Var,'UniformOutput',false);
[NE,RMS,FIT]=RMSvsNBRE(datas,headers,S,contact);

FL=figure();
hold on

FR=figure();
hold on

for j=1:numel(NE)
    %Plot (x^-0.5 so that the plot is linear)
    
    figure(FL)
    plot(NE{j}.^-0.5,RMS{j},'x-','DisplayName',names{j})
    
    figure(FR)
    plot(NE{j},RMS{j},'x-','DisplayName',names{j})
    
end

%Linearize data and remove NaN
NEline=cat(2,NE{:});
RMSline=cat(2,RMS{:});
NEline=NEline(~isnan(RMSline))';
RMSline=RMSline(~isnan(RMSline))';

X=min(NEline):10:max(NEline);

Xir=X.^-0.5;

%Fit data to a*x^-.5
[STDFit,gof]=fit(NEline.^-0.5,RMSline,'p1*x','StartPoint',30);

%Finish plot

figure(FL)
plot(Xir,STDFit.p1.*Xir,'r-','DisplayName',sprintf('fit a=%.2f',STDFit.p1))
xlabel('Number of Electrons^{-1/2}')
%    ylabel(polName)
title(sprintf('Noise RMS vs Number of electrons, slope=%.2f',STDFit.p1));
set(gca,'FontSize',15)

legend(gca,'show','Location','northwest');



figure(FR)
plot(X,STDFit.p1.*Xir,'r-','DisplayName',sprintf('fit a=%.2f',STDFit.p1))
xlabel('Number of Electrons')
ylabel(polName)
title('Noise RMS vs Number of electrons')
set(gca,'FontSize',15)


%legend(gca,'show');

%
figure
plot(Var,[FIT.p1],'x')
xlabel(VarName)
ylabel('Fit Coefficient p1 [au]')
set(gca,'FontSize',15)

%%
figure
plot(Var,[FIT.p2],'x-')
xlabel(VarName)
ylabel('Fit Coefficient p2 [au]')
set(gca,'FontSize',15)


%%
%{

idxline=sum(STDX<8000,2);
idx = sub2ind(size(STDX), 1:size(STDX,1), idxline');
figure
plot(Var,STDY(idx))

%}