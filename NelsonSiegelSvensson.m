% compute ZCB yields for a vector of maturities "n", given history of 
% Nelson-Siegel yield curve parameters "params", as per
% "GSW Parameters.xlsm" (saved as a Matlab Matrix too).
function yields = NelsonSiegel(n_vec, params)
    yields = zeros(size(params,1),length(n_vec));
    % extract Nelson-Siegel-Svensson parameters
    lambda_1 = params(:,1);
    lambda_2 = params(:,2);
    beta_0 = params(:,3);
    beta_1 = params(:,4);
    beta_2 = params(:,5);
    beta_3 = params(:,6);
    % loop through time series
    for i = 1:size(params,1) 
        yields(i,:) = beta_0(i)+...
            beta_1(i)*(1-exp(-lambda_1(i)*n_vec))./(lambda_1(i)*n_vec)+...
            beta_2(i)*((1-exp(-lambda_1(i)*n_vec))./(lambda_1(i)*n_vec)-...
            exp(-lambda_1(i)*n_vec))+...
            beta_3(i)*((1-exp(-lambda_2(i)*n_vec))./(lambda_2(i)*n_vec)-...
                exp(-lambda_2(i)*n_vec));
    end
end
    
        