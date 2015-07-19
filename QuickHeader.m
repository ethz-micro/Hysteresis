close all
clear all

idx=1:53;
BaseName='Data/2015_07_02/FE_W(011)_';
Ext='.hys';

fns=arrayfun(@(x) [BaseName, num2str(x,'%03u'), Ext],idx,'UniformOutput',false);

hys=cellfun(@processHys,fns);

Bias=arrayfun(@(x) x.header.TIP_BIAS_V,hys);
Z=arrayfun(@(x) x.header.TIP_Z_m,hys);

figure
plot(Bias)
figure
plot(Z)




