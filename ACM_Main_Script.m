%% Main script to extract the term premium from NACC bond yields

%% Script inputs
% NB: if there are significantly more maturities of yields (N)  
% than there are observations in the time series (T) the model may 
% give unreliable results.

N = 120;        % max maturity for ACM decomposition
K = 5;      % number of pricing factors in ACM model
raw_yield_data = 'ZAR Bond Curve.xlsx';   % name of data file for bond yields
interp = false;  % true -> linear interpolation, false -> NSS model

%% Process yield curve data 
% Includes example of JSE-bootstrapped NACC zero curve with daily data.
% Script assumes yield data will follow the same format with maturities in
% days.

% load and extract data from Excel file
yieldcurvedata = readmatrix(raw_yield_data);
dates = datetime(yieldcurvedata(2:end,1),'ConvertFrom','excel');
yields = yieldcurvedata(2:end,2:end);
maturities = yieldcurvedata(1,2:end)/30;
% extract end-of-month dates and yields
dates_mly = get_eom(dates,dates);
yields_mly = get_eom(yields,dates);

% if interp == true
    % Interpolate for required times to maturity
    yields_mly_interp = InterpolateCurve(yields_mly,maturities,1:maturities(end));
    yields_int = yields_mly_interp(:,1:N);   % extract yields for n=1:N
% else
    % Fit NSS model to yield curves
    % check for n=0 (gives NaN results)
    if maturities(1)==0
        maturities = maturities(2:end);
        yields_mly = yields_mly(:,2:end);
    end
    NSS_params = NSS_fitting(yields_mly,maturities);
    yields_NSS = NelsonSiegelSvensson(1:N,NSS_params);
% end

%% Perform ACM term premium decomposition
% Additional variables from the ACM model can be extracted by adding said
% variables to the outputs of ACM_estimation.m.
[term_prem,yields_fitted,yields_rn] =...
    ACM_estimation(K,1:N,dates_mly,yields_ACM');

[nmesh,tmesh] = meshgrid(1:N,dates_mly);
surf(nmesh,tmesh,1e4*(yields_int-yields_NSS))


