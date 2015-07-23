function Field = LoadTime2Field(loadTime,Voltage)
    %Inflexion time    
    Tinf=82/Voltage+3.25;
    %Linear model
    linearFit=@(x) 1/100000*(17*abs(x)+60)*Voltage;
    %Get load times smaller than Tinf
    smallLT=(abs(loadTime) < Tinf);
    %compute field
    Field=smallLT.*(loadTime./Tinf).*linearFit(Tinf)...
        +(~smallLT).*sign(loadTime).*linearFit(loadTime);
    %Multiply to get [G]
    Field=Field*1.14*500;
end