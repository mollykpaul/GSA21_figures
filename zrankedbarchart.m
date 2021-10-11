function [] = zrankedbarchart(min_y,max_y, samplename, samplestring, mystruct, mycolors)
%ZRANKEDBARCHART creates a figure with one large plot and multiple
%subplots. The inputs are a min and max y axis, sample names (for labels),
%field names (samplestring), a structure of data, and colors. 
%   Currently, this function does not have a built-in capability to resize
%   the subplot based on the number of inputs, and the exact sizing depends
%   on personal preference, so please contact Molly or modify the code
%   below to adapt it to fit your dataset. 

assert(numel(samplename)<=4, 'The number of samples you are trying to display is not compatible with this function. Modify the subplot dimensions before proceeding.')

figure      

cherriberry=mycolors;

% determine how many fractions are in each sample, store this data as a vector
empty=zeros(1, numel(samplename)+1);                                        % create a vector of zeros 
for i = 1 : numel(samplename)                                               % iterate through each sample  
     
 fieldname=samplestring(1,i);                                               % iterate through each fieldname (sample)
 num_int=nnz(~isnan(mystruct.(fieldname).Pb206U238_age));                   % determine how many fractions are in each sample
 empty(1, i)=num_int;                                                       % reset a value in the "empty" matrix to the number of fractions
end                                                                         % end the loop 
 
tot_meas=sum(empty, 'omitnan');                                             % calculate how many total fractions were measured (incl every sample)

 
start=1;                                                                    % set the variable start to start at 1 
stop=empty(1);                                                              % set the variable stop to the number of fractions in the first sample 

%%% plot the top 1/3 of the figure %%%
subplot(3, 2, [1,2]);                                                       % create a subplot with 3x2 spaces, combine the first two into one graph space, use that space 

for i = 1 : numel(samplename)                                               % iterate through the samples 
        hold on                                                             % plot everything in the for loop on the same graph spot indicated in the subplot fxn 
        clear ax                                                            % clear the axes 
        
        fieldname=samplestring(1,i);                                        % iterate through field names (samples) 

% determing positioning on axes based on how many fractions are in each sample       
        x_axes=NaN(1, numel(mystruct.(fieldname).Pb206U238_age));           % create NaN matrix the length of the number of elements stored in a variable
        x_ticks=(start:stop);                                               % set the variable "x_ticks" to be a vector from start to stop, with increments of 1 
          
        for k = 1 : empty(i)                                                % iterate from 1 to the number of analyses in any given sample 
            x_axes(k)=x_ticks(k);                                           % replace the value of "x_axes" at position k with the value of "x_ticks" at position k 
        end                                                                 % end the for loop 
        
        x_axes=x_axes*1.5;                                                  % control spacing between values 
        
        [age_sorted, sort_order]=sort(mystruct.(fieldname).Pb206U238_age);  % sort the fractions by age and genereate a vector of positions
        sigma_sorted=mystruct.(fieldname).Pb206U238_sigma(sort_order);      % sort the values of the 2sigma absolute error for each fraction by the position vector

% plot the dates and errors using the errorbar function
        e=errorbar(x_axes, age_sorted, sigma_sorted, 's', 'Color', cherriberry{i}); 

% modify properties of the errorbar plot 
        e.MarkerSize=0.0001;
        e.LineWidth=8;
        e.CapSize=0.0001;

% add legend 
legend((samplename), 'Location','eastoutside', 'AutoUpdate', 'off')
legend('boxoff')         
        
% modify start and stop values 
        start=start+empty(i)+1;
        stop=start + empty(i+1)-1;
  
end 

start=1;                                                                    % set the variable start to start at 1 
stop=empty(1);                                                              % set the variable stop to the number of fractions in the first sample 

for i = 1 : numel(samplename)                                               % iterate through the samples 
        hold on                                                             % plot everything in the for loop on the same graph spot indicated in the subplot fxn 
        clear ax                                                            % clear the axes 
        
        fieldname=samplestring(1,i);                                        % iterate through field names (samples) 

% determing positioning on axes based on how many fractions are in each sample       
        x_axes=NaN(1, numel(mystruct.(fieldname).Pb206U238_age));           % create NaN matrix the length of the number of elements stored in a variable
        x_ticks=(start:stop);                                               % set the variable "x_ticks" to be a vector from start to stop, with increments of 1 
          
        for k = 1 : empty(i)                                                % iterate from 1 to the number of analyses in any given sample 
            x_axes(k)=x_ticks(k);                                           % replace the value of "x_axes" at position k with the value of "x_ticks" at position k 
        end                                                                 % end the for loop 
        
        x_axes=x_axes*1.5;                                                  % control spacing between values 
        
      
% plot the weighted mean age as a horizontal line 
age=mystruct.(fieldname).Pb206U238_age;                                     % 206Pb/238U age 
err=mystruct.(fieldname).Pb206U238_sigma./2;                                % 1 sigma absolute uncertainty 
weighted_mean=sum(age./(err.^2), 'omitnan')/sum(1./(err.^2), 'omitnan');    % weighted mean age 
        
one=ones(1,numel(x_axes));                                                  % empty vector 
x_axes(1,1)=x_axes(1,1)-1;                                                  % axis position for weighted mean age 
x_axes(1,empty(i))=x_axes(1,empty(i))+1;
vector_mean=one.*weighted_mean;                                             % fill the empty vector with the weighted mean age 
        line(x_axes, vector_mean, 'Color', 'black', 'LineWidth', 0.75)      % plot a line using the x position from line 98 and y pos from line 99   
        
        
% modify start and stop values 
        start=start+empty(i)+1;                                             
        stop=start + empty(i+1)-1;
  
end 


% modify axis properties, title, and labels 
ax = gca; 
ax.YTick = [min_y :1: max_y];
ax.YLim = [min_y max_y];
 ax.XTick=([]);
ax.XTickLabel={};

title('Zirconia Megacrysts')
clear ylabel
ylabel ('Age (Ma)')   

%%% prepare to make lower 2/3 of the figure %%%  
hold off 
clear age 
clear err 
clear age_sorted
clear sigma_sorted


integers=[1:10];

for i = 1 : numel(samplename)
subplot(3, 2, 2+i)                                                          % create a subplot and in each loop change position in the subplot 
        clear ax 
        hold on 
        fieldname=samplestring(1,i);                                        % iterate through sample names (field names) 
       
        age=mystruct.(fieldname).Pb206U238_age;
        err=mystruct.(fieldname).Pb206U238_sigma./2;                        % 1 sigma absolute uncertainty 
        
        weighted_mean=sum(age./(err.^2), 'omitnan')/sum(1./(err.^2), 'omitnan');% weighted mean calculation    
        std_err_weighted_mean=2*sqrt(1/(sum(1./(err.^2), 'omitnan')));      % 2 sigma absolute error on weighted mean age 
       
        integers=nnz(~isnan(age));                                          % omit NaNs from calculation

% plot the mean age as a horizontal line 
        empty=ones(1,integers+2);
        vector_mean=empty.*weighted_mean;
        vector_integers=(1:integers+2);
        line(vector_integers-1, vector_mean, 'Color', 'black')

% plot a rectangle showing +/- 2 sigma absolute error 
        ry=weighted_mean-std_err_weighted_mean;                             % lower left y position of rectangle 
        rx=0;                                                               % lower left x position of rectangle 
        width=integers+1;
        height=2*std_err_weighted_mean;                                     % height represents uncertainty of weighted mean     
        
        r=rectangle('Position',[rx ry width height]);                       % plot rectangle of 2 sigma uncertainty in each direction
        
        [age_sorted, sort_order]=sort(mystruct.(fieldname).Pb206U238_age);  % sort ages by increasing value 
        sigma_sorted=mystruct.(fieldname).Pb206U238_sigma(sort_order);      % 2sigma error (match uncertainties to ages by using sorting order)
        
        e=errorbar(age_sorted, sigma_sorted, 's', 'Color', cherriberry{i}); % errorbar to plot 
        e.MarkerSize=0.0001;                                                % minimize marker size 
        e.LineWidth=8;                                                      % bar thickness 
        e.CapSize=0.0001;                                                   % minimize cap size 
        
        ax = gca;  
        ax.YTick = [min_y :1: max_y];
        ax.YLim = [min_y max_y];
        ax.XTick=([]);
        ax.XTickLabel={};
        ax.XLim = [0 integers+1];

        title(samplename(1,i))
        clear ylabel
        clear age 
        clear err
        clear weighted_mean
        
        ylabel ('Age (Ma)')
        
        hold off 

end 





end

