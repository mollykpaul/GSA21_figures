function [] = concordia(mystruct, samplestring, samplename, colors)
% CONCORDIA This function takes in a structure, samplestring (field names
% in the form of string), sample names (for labels, titles), and colors. 
%   This function will generate a single figure which includes a concordia
%   line, uncertainty on concordia based on propogated uncertainties in
%   decay constants, and error ellipses for each analysis. 

% test if the user has the conf95_ellipse function 

%test=exist(conf95_ellipse)
%assert(test==2,'You require the conf95_ellipse function to use this function.') 


cherriberry=colors;

% lambda 238 constants 
lambda238=1.55125*10^-10;                                                   % constant from Jaffey et al. 1971 
lambda238_2sigma=0.00166*10^-10;                                            % absolute uncertainty 2 sigma 
%lambda238_2sigma=lambda238*0.00108                                         % alternative calculation, uses % error 
lambda238_high=lambda238+lambda238_2sigma;                                  % adds abs 2sigma to known value 
lambda238_low=lambda238-lambda238_2sigma;                                   % subracts abs 2sigma from known value 

% lambda 235 constants 
lambda235=9.8485*10^-10;                                                    % constant from Jaffey et al. 1971
lambda235_2sigma=0.0135*10^-10;                                             % abs uncertainty 2 sigma     
%lambda235_2sigma=lambda235*0.00137;
lambda235_high=lambda235+lambda235_2sigma;
lambda235_low=lambda235-lambda235_2sigma;

% lambda 232 constants 
lambda232=4.9475*10^-11;
lambda232_2sigma=lambda232*0.0102;

% calculate  concordia constants 
time_concordia=0:1000:4500000000;                                           % create time vector 
Pb206U238_concordia=exp(lambda238*time_concordia)-1;                        % calculate 206Pb/238U ratio based off of decay equation solved for daughter/parent
Pb207U235_concordia=exp(lambda235*time_concordia)-1;                        % calculate 207Pb/235U ratio

Pb206U238_concordia_low=exp(lambda238_low*time_concordia)-1;                % repeat calculation above for high and low values of lambda    
Pb207U235_concordia_low=exp(lambda235_low*time_concordia)-1; 

Pb206U238_concordia_high=exp(lambda238_high*time_concordia)-1;              % repeat calculation above for high and low values of lambda
Pb207U235_concordia_high=exp(lambda235_high*time_concordia)-1;

% create concordia plot 
clear ax 
figure 
%subplot(1, 1, 1)





for i = 1 : numel(samplestring)                                             % iterate through samples 
    fieldname=samplestring(1,i);
    
    % for every field, call the correct column of data 
    
    Pb206U238_ratio=mystruct.(fieldname).Pb206U238_ratio;                   % call 206Pb/238U ratios from data structure 
    Pb207U235_ratio=mystruct.(fieldname).Pb207U235_ratio;                   % call 207Pb/235U ratios from data structure
    
    Pb206U238_ratio_2sigma=mystruct.(fieldname).Pb206U238_ratio.*(mystruct.(fieldname).Pb206U238_perr./100);    % 2 sigma percent error in decimal form 
    Pb207U235_ratio_2sigma=mystruct.(fieldname).Pb207U235_ratio.*(mystruct.(fieldname).Pb207U235_perr./100);    % 2 sigma percent error in decimal form 
    
    Pb207Pb206_ratio_perr=mystruct.(fieldname).Pb207Pb206_perr;             % 2 sigma percent error 
    Pb207U235_ratio_perr=mystruct.(fieldname).Pb207U235_perr;               % 2 sigma percent error
    Pb206U238_ratio_perr=mystruct.(fieldname).Pb206U238_perr;               % 2 sigma percent error
    
    % iterate through each column to find the correct row   
       
   for k = 1: 13
          
            Pb206U238_ratio_sample=Pb206U238_ratio(k,1);                    % go through each row of the vector above 
            Pb207U235_ratio_sample=Pb207U235_ratio(k,1);

            test = isnan(Pb206U238_ratio_sample);                           % test if the data exists in that row or is NaN 
            if test==1                                                      % if the data does not exist, skip this row 
                 k=k+1;                                                     
            
            else
                
            Pb207Pb206_ratio_perr_sample=Pb207Pb206_ratio_perr(k,1)/100;    % 2 sigma error percent -> decimal
            Pb206U238_ratio_perr_sample=Pb206U238_ratio_perr(k,1)/100;      % 2 sigma error percent -> decimal   
            Pb207U235_ratio_perr_sample=Pb207U235_ratio_perr(k,1)/100;      % 2 sigma error percent -> decimal 
            
            rho_numerator= (Pb207U235_ratio_perr_sample*100/2)^2+(Pb206U238_ratio_perr_sample*100/2)^2-(Pb207Pb206_ratio_perr_sample*100/2)^2; % uses 1 sigma percent error 
            rho_denomenator=2*(Pb207U235_ratio_perr_sample*100/2)*(Pb206U238_ratio_perr_sample*100/2); % uses 1 sigma percent error 
            rho=rho_numerator/rho_denomenator;
                        
            sig_x=(Pb207U235_ratio_perr_sample/2)*Pb207U235_ratio_sample; % 1 sigma absolute error 
            sig_y=(Pb206U238_ratio_perr_sample/2)*Pb206U238_ratio_sample; % 1 sigma absolute error 
                       
            
            matrix=[sig_x^2, rho*sig_x*sig_y; rho*sig_x*sig_y,sig_y^2]; % do not normalize the covariance matrix      
            [eigenvalues_Mark, eigenvectors_Mark]=conf95_ellipse(matrix,Pb207U235_ratio_sample, Pb206U238_ratio_sample, cherriberry{i}); % call conf95_ellipse function        
            
axis('square');
   end
   end
end
   %legend((samplename), 'Location','eastoutside', 'AutoUpdate', 'off', 'Location', 'northwest')
%legend('boxoff')   
hold on 

plot(Pb207U235_concordia, Pb206U238_concordia, 'Color', 'k')                % plot concordia using hypothetical Pb/U ratios for all time 
plot(Pb207U235_concordia_low, Pb206U238_concordia_high, 'Color', 'k', 'LineStyle', '--')    % plot lower uncertainty on the value of concordia 
plot(Pb207U235_concordia_high, Pb206U238_concordia_low, 'Color', 'k', 'LineStyle', '--')    % plot upper uncertainty on the value of concordia 
xlabel('^{207}Pb/^{235}U')
ylabel('^{206}Pb/^{238}U')
title('Wetherill Concordia Plot')
end

