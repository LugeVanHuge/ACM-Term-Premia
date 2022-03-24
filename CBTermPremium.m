% Compute the term premium associated with a coupon bond given cash flows
% and cash flow dates. 
% CB term premium is estimated as the difference between the objective and
% risk-neutral YtMs of the bond.
% Note: function assumes yields and yields_rn are fitted yields from ACM
% algorithm (i.e. array is (N-1)xT)
function CB_termprem = CBTermPremium(CB_cashflows,CB_maturities,...
    yields,yields_rn)
    
    % ensure CB arrays are column vectors for following calculations
    if size(CB_cashflows,2)~=1
        CB_cashflows = CB_cashflows';
    end
    if size(CB_maturities,2)~=1
        CB_maturities = CB_maturities';
    end
    
    % find objective and risk-neutral discount rates for cash flows
    discount_obj = yields(CB_maturities-1,:);   
    discount_rn = yields_rn(CB_maturities-1,:);
    
    % ytm bond price inline func
    ytm_price = @(ytm) sum(CB_cashflows.*exp(-ytm.*CB_maturities));
    
    % find objective YtM
    price_obj = sum(CB_cashflows.*exp(-discount_obj.*CB_maturities));
    ytm_func_obj = @(ytm) sum((price_obj-ytm_price(ytm)).^2);
    ytm_obj = fminunc(ytm_func_obj,0.1*ones(size(price_obj)));
    
    % find risk-neutral YtM
    price_rn = sum(CB_cashflows.*exp(-discount_rn.*CB_maturities));
    ytm_func_rn = @(ytm) sum((price_rn-ytm_price(ytm)).^2);
    ytm_rn = fminunc(ytm_func_rn,0.1*ones(size(price_rn)));
    
    CB_termprem = ytm_obj-ytm_rn;  
end