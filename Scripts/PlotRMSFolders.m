function PlotRMSFolders(sfn)
    %call loadFolder in all folder inside superfolder
    %sfn = 'Data';
    files=dir(sfn);
    
    
    A=[];
    B=[];
    Amp=[];
    
    for i=1:numel(files)
        file = files(i);
        
        if file.isdir && file.name(1)~='.'
            
            [f,q,a]=loadFolder([sfn,'/', file.name],file.name);
            A=[A,f];
            B=[B,q];
            Amp=[Amp,a];
            
            
        end
        
    end
    A(A>200)=nan;
    
    figure
    histogram(A(:),30);
    xlabel('Normalized Variance')
    title(sprintf('Median = %g',nanmedian(A(:))));
    nanmean(A(:))
    set(gca,'FontSize',20)
    
    figure
    plot(B(:),A(:),'x')
    
    figure
    histogram(Amp(:),200);
    xlabel('Fit Value Amplitude')
    
end
function R=funfit(X,Y)
    try
        f=fit(X',Y','p1*x','StartPoint',70);
        R=f.p1;
    catch exception
        R=nan;
    end
end
function [FITP,Q,ampl] = loadFolder(folderName,name)
    persistent loadedData
    
    fieldName=folderName;
    fieldName(fieldName=='/')=[];
    %Search all hys files
    files = dir([folderName, '/*.hys']);
    if numel(files)>0
        if isfield(loadedData,fieldName)
            headers=loadedData.(fieldName).headers;
            datas=loadedData.(fieldName).datas;
        else
            
            fns=arrayfun(@(x) [folderName,'/',x.name],files,'UniformOutput',false);
            [headers,datas]=cellfun(@load.loadHys,fns,'UniformOutput',false);
            
            loadedData.(fieldName).headers=headers;
            loadedData.(fieldName).datas=datas;
        end
        
        hys=cellfun(@(x,y) load.processHys(x,y,.1,0),datas,headers);
        
        
        [NE,RMS] = cellfun(@(x,y) op.getNeRmsCrv(x,y,.1,0),datas,headers,'UniformOutput',false);
        
        
        
        FITP = cellfun(@(X,Y) median(X.*Y.*Y) ,NE,RMS)';
        %FITP = cellfun(@(X,Y) funfit(1./X,Y.^2) ,NE,RMS)';
        %{
        X=NE{j}.^-1;
        Y=RMS{j}.^2;
        FIT(j).p1=median(Y./X);
        FIT(j).p2=0;
        
        %Fit if we can
        
        %}
        
        
        %FITP=[FIT.p1];
        Q=arrayfun(@(x) x.data.Q,hys)';
        ampl=arrayfun(@(x) x.model.amplitude,hys)';
        
        
        rms=arrayfun(@(x) x.model.rms,hys)';
        Fdiff=arrayfun(@(x) x.model.diffFlip,hys)';
        FStd=arrayfun(@(x) x.model.flipSTD,hys)';
        %{
        figure
        plot(FITP,'x--');%,'DisplayName',name);
        hold all
        plot(abs(Fdiff),'x--');
        plot(FStd,'x--');
        
        title(name)
        %{
        plot(Q,'x--')
        plot(ampl,'x--')
        plot(rms,'x--')
        xlabel('index')
        ylabel('Fit Value')
        %legend(gca,'show')
        %}
        
        figure
        hold all
        for j=1:numel(NE)
            plot(1./NE{j},RMS{j}.^2,'x-','DisplayName',sprintf('%d',j));
        end
        legend(gca,'show')
        xlabel('1/Nbr e- ')
        ylabel('Variance')
        title(name)
        
        %}
        
    else
        FITP=[];
        Q=[];
        ampl=[];
    end
    
end
