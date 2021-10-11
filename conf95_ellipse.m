function [eigenvalues, eigenvectors] = conf95_ellipse(C,x_pos, y_pos, color_choice)
% 
% This function takes a covariacne matrix formatted as [sig_x^2,
% rho*sig_x*sig_y; rho*sig_x*sig_y,sig_y^2], an x and y position for the
% center of the ellipse, and a color scheme. This function assumes a 95%
% confidence interval by using the chi squared test. The covariance matrix
% is used to calculate eigenvectors (rotate major & minor axes) and
% eiganvalues (lengthen or shorten axes). 

%assert(C~=[NaN, NaN; NaN, NaN], 'Covariance matrix is invalid.')

[Q,lam] = eig( inv( C ) );

% Q are eigenvectors; lam are eigenvalues.


% Step 2: Find the percentile confidence ellipsoid semiaxis lengths. If you
% are using MATLAB you can find the percentile of with the command
% chi2inv(0.95,n), where n=degrees of freedom
n = 2;

delta2 = chi2inv( 0.95, n ); % Inverse of the chi2 CDF
delta  = sqrt( delta2 ); % Delta parameter
% semi-axis
Qs(:,1) = delta / sqrt( lam(1,1) ) * Q(:,1);
Qs(:,2) = delta / sqrt( lam(2,2) ) * Q(:,2);

% Now build the ellipse
theta = ( 0 : 0.01 : 2*pi )'; % this is a theta vector for cylindrical coordinates
r = zeros( length(theta), n ); % Allocate a vector (r_1, r_2).

r(:,1) = ... % calculate the x point of the ellipsoid for all angles
    Qs(1,1) * cos(theta) + ...
    Qs(1,2) * sin(theta);

r(:,2) = ... % calculate the y point of the ellipsoid for all angles
    Qs(2,1) * cos(theta) + ...
    Qs(2,2) * sin(theta);

% Indicate the center of the ellipse
x0 = x_pos;
y0 = y_pos;

 % plot the ellipse centered at (x0,y0)
plot( x0 + r(:,1), y0 + r(:,2), 'Color', color_choice, 'LineWidth', 1); hold on; grid on;
% fill( x0 + r(:,1), y0 + r(:,2), 'k');
%plot( x0, y0, 'Marker','.','MarkerFaceColor','black','MarkerEdgeColor','black');

eigenvalues=Q;
eigenvectors=lam;

end

