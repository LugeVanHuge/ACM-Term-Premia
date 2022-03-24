% Main script to extract the term premium from NACC bond yields.
% Estimates and plots nominal and real term premia with the option to
% estimate and plot the term premium of a coupon bond defined by its cash
% flows.
% All rates are assumed NACC.

%% Script inputs
% NB: if there are significantly more maturities of yields (N)  
% than there are observations in the time series (T) the model may 
% give unreliable results.

N = 120;        % max maturity for ACM decomposition
K = 5;      % number of pricing factors in ACM model
raw_yield_data = 'ZAR Bond Curve.xlsx';   % name of data file for bond yields
raw_realyield_data = 'ZAR Real Bond Curve.xlsx';    % ditto real bond yields
NSS = true;  % true -> NSS model, false -> linear interpolation
plot_maturities = [120];   % maturities in months of term premia plots

% Coupon bond term premium (leave either array empty if not required)
CB_cashflows = [10 10 10 10 110];   % cash flows (include principal repayment)
CB_maturities = [24 48 72 96 120]';   % months until cash flows

%% Process yield curve data 
% Includes example of JSE-bootstrapped NACC zero curve with daily data.
% Script assumes yield data will follow the same format with maturities in
% days.

% load data from Excel file
nom_yield_data = readmatrix(raw_yield_data);
real_yield_data = readmatrix(raw_realyield_data);
% process data
[nom_yields_ACM,nom_dates] = ProcessData(nom_yield_data,NSS,N);
[real_yields_ACM,real_dates] = ProcessData(real_yield_data,NSS,N);

%% Perform ACM term premium decomposition
% Additional variables from the ACM model can be extracted by adding said
% variables to the outputs of ACM_estimation.m.
[nom_term_prem,nom_yields_fitted,nom_yields_rn] =...
    ACM_estimation(K,1:N,nom_dates,nom_yields_ACM');
[real_term_prem,real_yields_fitted,real_yields_rn] =...
    ACM_estimation(K,1:N,real_dates,real_yields_ACM');

%% Compute coupon bond term premium
if isempty(CB_cashflows) == 0 && isempty(CB_maturities) == 0
    if length(CB_cashflows)~=length(CB_maturities)
        error('Coupon bond cash flows and cash flow dates must have same dimension')
    end
    CB_termprem = CBTermPremium(CB_cashflows,CB_maturities,...
    nom_yields_fitted,nom_yields_rn);
    % plot
    figure()
    plot(nom_dates,CB_termprem*100)
    title('Coupon Bond Term Premium (%)')
end

%% Plot term premium time series
for n = plot_maturities
    figure()
    plot(nom_dates,nom_term_prem(n-1,:)*100)
    title([num2str(n) '-month Nominal Term Premium (%)'])
    figure()
    plot(real_dates,real_term_prem(n-1,:)*100)
    title([num2str(n) '-month Real Term Premium (%)'])
end