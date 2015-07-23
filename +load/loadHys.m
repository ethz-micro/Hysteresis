function [header, data] = loadHys(fn)
fid = fopen(fn, 'r', 'ieee-be');    % open with big-endian

%Read Header until we have
% \1A\04 (hex) indicates beginning of binary data
headertxt='';
s1 = [0 0];
while s1~=[26 4]
              s2 = fread(fid, 1, 'char');
              headertxt=[headertxt s2];
              s1(1) = s1(2);
              s1(2) = s2;
end

%remove last thing
headertxt=headertxt(1:end-2);
%save Raw txt
header.RAWTXT=headertxt;
headertxt=strsplit(headertxt,'\n');

for i=1:numel(headertxt)/2
    fieldName=strtrim(headertxt{2*i-1});
    fieldValue=strtrim(headertxt{2*i});
    if fieldName(1)==fieldName(end)&&fieldName(1)==':'
        header.(fieldName(2:end-1))=fieldValue;
    else
        display('Bad header')
    end
    
    
end

%Transform key parameters to num
if isfield(header,'MSR_SIZE')
    header.MSR_SIZE=str2num(header.MSR_SIZE);
else
    header.MSR_SIZE=nan;
end
if isfield(header,'TIP_BIAS_V')
    header.TIP_BIAS_V=str2num(header.TIP_BIAS_V);
else
    header.TIP_BIAS_V=nan;
end
if isfield(header,'TIP_Z_m')
    header.TIP_Z_m=str2num(header.TIP_Z_m);
else
    header.TIP_Z_m=nan;
end
if isfield(header,'MSR_VOLT')
    header.MSR_VOLT=str2num(header.MSR_VOLT);
else
    header.MSR_VOLT=nan;
end
if isfield(header,'AVRG_WAIT_ms')
    header.AVRG_WAIT_ms=str2num(header.AVRG_WAIT_ms);
else
    header.AVRG_WAIT_ms=nan;
end

%Read Data
data =fread(fid, [header.MSR_SIZE 4], 'float');

fclose(fid);
end