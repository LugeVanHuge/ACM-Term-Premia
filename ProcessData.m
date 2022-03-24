% subfunction for processing raw yield curve data to extract yields
% suitable for ACM procedure
function [yields_ACM,dates_mly] = ProcessData(raw_yields,NSS,N)
    dates = datetime(raw_yields(2:end,1),'ConvertFrom','excel');
    yields = raw_yields(2:end,2:end);
    maturities = raw_yields(1,2:end)/30;
    % extract end-of-month dates and yields
    dates_mly = get_eom(dates,dates);
    yields_mly = get_eom(yields,dates);

    if NSS == false
        % Interpolate for required times to maturity
        yields_mly_interp = InterpolateCurve(yields_mly,maturities,1:maturities(end));
        yields_ACM = yields_mly_interp(:,1:N);   % extract yields for n=1:N
    else
        % Fit NSS model to yield curves
        % check for n=0 (gives NaN results)
        if maturities(1)==0
            maturities = maturities(2:end);
            yields_mly = yields_mly(:,2:end);
        end
        NSS_params = NSS_fitting(yields_mly,maturities);
        yields_ACM = NelsonSiegelSvensson(1:N,NSS_params);
    end
end