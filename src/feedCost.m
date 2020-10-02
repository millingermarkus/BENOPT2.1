%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BENOPT (BioENergy OPTimisation model)
%     Copyright (C) 2012-2020 Markus Millinger
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
% 
% Contact: markus.millinger@ufz.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [s,f]=feedCost(s,f)

for time=1:f.runTime
    f.priceDev(time)            =   (1+s.priceDevFactor)^(time-1);
end

    indexWheat                  =   find(contains(f.cropNames,{'Wheat'}));
    f.wheatIncome               =   f.wheatPriceStart*f.cropYieldFM(:,indexWheat).*f.priceDev'; %€/ha

    s.labourCost                =   s.labourCostStart.*f.priceDev;
    s.dieselCost                =   s.dieselCostStart.*f.priceDev;
    f.cropLabourCostHa          =   s.labourCost.*f.cropLabourHa';
    f.cropDieselCostHa          =   s.dieselCost.*f.cropDieselHa';
    f.cropExpensesHa            =   f.cropLabourCostHa+f.cropDieselCostHa+ones(1,s.runTime).*(f.cropMachineFixHa+f.cropMachineVarHa+f.cropServiceCostsHa+f.cropDirectCostsHa)';

    f.wheatProfit               =   f.wheatIncome-f.cropExpensesHa(indexWheat,:)';
    f.cropProfit                =   f.wheatProfit;
    f.cropIncomeHa              =   f.cropExpensesHa+ones(1,s.runTime).*f.cropProfit';

        
    %% Residue price development
    f.resPriceMin(:,time)       =   f.resPriceIniMin(:,1).*f.priceDev(time);
    f.resPriceMax(:,time)       =   f.resPriceIniMax(:,1).*f.priceDev(time);
   
    %% Calculate price categories

    f.cropPrice              =   f.cropIncomeHa./f.cropYieldDM'; %€/tDM
    f.cropPriceGJBase            =   f.cropPrice./f.cropDMenergyContent'; % €/GJ
    
    for c=1:f.cat
        for b=1:f.numCrop
            f.cropPriceGJ(:,b,c)    =   f.cropPriceGJBase(b,:);
        end
        for b=1:f.numResidue
            if c==1
                f.resPrice(:,b,c)       =   f.resPriceMin(b,:);
            elseif c==2
                f.resPrice(:,b,c)       =   (f.resPriceMin(b,:)+f.resPriceMax(b,:))/2;
            elseif c==3
                f.resPrice(:,b,c)       =   f.resPriceMax(b,:);
            end
        end
            f.powerPrice(:,1,c)     =   s.powerPrice(1,:)./3.6; %€/MWh -> Mio€/PJ (€/GJ) - Power mix price
            f.powerPrice(:,2,c)     =   s.erePriceShare.*s.powerPrice(1,:)./3.6; %Excess electricity price %zeros(s.runTime,1)
    end
    
    %% Land demand / biomass
    f.landReqGJFuel                 =   (f.cropDMenergyContent.*f.cropYieldDM).^-1; %ha/GJ_crop

end