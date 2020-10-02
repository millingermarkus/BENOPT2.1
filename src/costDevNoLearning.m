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


function [s,f]  =   costDevNoLearning(s,f)


    % Methanol, Hydrogen and heat price
    s.methanolPrice                         =   f.priceDev*28.5*19.9; %EUR/t --- 28.5EUR/GJ start (BioMeOH), 19.9GJ/t (methanol) => EUR/t
%     s.hydrogenPrice                         =   5000*s.powerPriceDevNormed(time); %EUR/t
    %s.heatPrice(time)=f.lignoPrice(time).*3.6./(f.feedDMenergyContent(f.posMin(time)+3).*s.heatEta*10^3); %EUR/tDM * (GJ/tDM)^-1 * (MJ/GJ)^-1 * MJ/kWh * eta^-1 -> EUR/kWh
    
    s.feedCost2nd                           =   s.feed2ndMethanolAmount.*s.methanolPrice';%+...        s.feed2ndHydrogenAmount.*s.hydrogenPrice(time); %EUR/GJ, methanol kgDM/GJ,H2 kgDM/GJ Hydrogen excluded since calculated in GAMS

    %% Calculation of revenue for byproducts, part of marginal costs
    
    % Recalculation of feedprice development
%     f.feedPriceDev                          =   f.feedPriceMin./f.feedPriceMin(1,:);
    
    % Definition of price components for byproducts
    s.digestatePrice                        =   zeros(1,s.runTime);
    s.aldehydePrice                         =   zeros(1,s.runTime);
    s.vinassePrice                          =   124.62  *ones(1,s.runTime);%70*f.feedPriceDev(time,2);
    s.driedpulpPrice                        =   144.44  *ones(1,s.runTime);
    s.schrotPrice                           =   246.22  *ones(1,s.runTime); %235.6*f.feedPriceDev(time,3); % Konstantin Zech
    s.pharmaglycerinPrice                   =   300     *ones(1,s.runTime); %145*f.feedPriceDev(time,3);% Konstantin Zech. Vorher:600*f.feedPriceDev(time,3);
    s.naphthaPrice                          =   500.01  *ones(1,s.runTime); % 4*f.priceDev(time); %EUR/t
    s.ddgsPrice                             =   251.26  *ones(1,s.runTime); %233.7*f.feedPriceDev(time,7);
    s.fuelgasPrice                          =   704.55  *ones(1,s.runTime); %100*f.lignoPrice(time);  
    s.ligninPrice                           =   170     *ones(1,s.runTime); %180.*f.lignoPrice(time); %Phenol referenzpreis 500EUR/t lt Jakob Hildebrandt
        
    % Calculation of the byproduct revenue
    s.fuelByprodRevenue     =...
        s.byProdDigestate.*s.digestatePrice'+...
        s.byProdVinasse.*s.vinassePrice'+...
        s.byProdDriedPulp.*s.driedpulpPrice'+...
        s.byProdAldehyde.*s.aldehydePrice'+...
        s.byProdDDGS.*s.ddgsPrice'+...
        s.byProdSchrot.*s.schrotPrice'+...
        s.byProdPharmaglycerin.*s.pharmaglycerinPrice'+...
        s.byProdNaphtha.*s.naphthaPrice';
    %+...        s.byProdLignin.*s.ligninPrice(time)+...        s.byProdFuelgas.*s.fuelgasPrice(time);
        %s.powerByprod(time,:).*s.powerPrice(time);
        %s.heatByprod(time,:).*s.heatPrice(time)+...



%%---------------------------------------------------------------------INVESTMENT AND PRODUCTION COST

%% Investment calculations
for i=1:s.numTech
    s.fuelInvCost(:,i)                             =   1000*linspace(s.plantInvCostProMWinit(i)./(3.6*s.fullLoadHoursInit(i)),s.plantInvCostProMWend(i)./(3.6*s.fullLoadHoursEnd(i)),s.runTime); %EUR/TJ -> EUR/GJ
%     s.plantInvCostWithoutCapacityFactor(:,i)        =   linspace(s.plantInvCostProMWinit(i),s.plantInvCostProMWend(i),s.runTime); %EUR/MW_cap
    s.plantInvCost(:,i)                             =   linspace(s.plantInvCostProMWinit(i),s.plantInvCostProMWend(i),s.runTime); %Million EUR/GW_cap
%     s.plantInvCostWithoutCapacityFactor(:,i)        =   linspace(s.plantInvCostProMWinit(i)./(3.6*8760),s.plantInvCostProMWend(i)./(3.6*8760),s.runTime); %EUR/GJ_cap
    
% levelized investment costs  [EUR/GJ]    
    s.annuityFactor(i)                              =   (s.discountRateInvest*(1+s.discountRateInvest)^s.plantLifeTime(i))/...
                                                        ((1+s.discountRateInvest)^s.plantLifeTime(i)-1);
    s.plantInvCostLevel(:,i)                        =   s.plantInvCost(:,i)*s.annuityFactor(i);
    s.fuelInvCostLevel(:,i)                         =   s.fuelInvCost(:,i)*s.annuityFactor(i); %EUR/GJ
%     s.plantInvCostLevelWithoutCapacityFactor(:,i)   =   s.plantInvCostWithoutCapacityFactor(:,i)*s.annuityFactor(i);
    
    s.vehicleCostLevel(:,i)                         =   linspace(s.vehicleCostPerVehicleStart(i),s.vehicleCostPerVehicleEnd(i),s.runTime).*s.annuityFactorVehicle;
    s.vehicleCostPerKm(:,i)                         =   s.vehicleCostLevel(:,i)./s.passengerVehicleKMperVehicle';
    
    % Operation and maintanance costs [EUR/GJ] (dependent on invest costs)
%     s.plantMOInvShare(:,i)                          =   linspace(s.plantMOInvShareInit(i),s.plantMOInvShareEnd(i),s.runTime);
    s.fuelOandMcost(:,i)                           =   s.plantMOInvShare(:,i).*s.fuelInvCost(:,i);  
%     s.vehicleCostPerVehicleKM(:,i)                  =   linspace(s.vehicleCostPerVehicleStart(:,i)*s.annuityFactorVehicle,... 
%                                                                    s.vehicleCostPerVehicleEnd(:,i)*s.annuityFactorVehicle,s.runTime)./s.passengerVehicleKMperVehicle; %EUR/vehicle-km./s.passengerVehicleKMperVehicle
end

%     s.vehicleCostPerGJfuel                          =   s.vehicleCostPerVehicleKM./(s.MJperKMavgICEV.*s.relativeFuelEconomy(:,6)');
%     s.vehicleCostPerGJfuel(isnan(s.vehicleCostPerGJfuel))                   =   0;
%%

%% Calculation of marginal costs
    s.infrastructureCost                =   s.transportCost + s.storageCost;
        
%       %Operating marginal costs per GJ fuel from each plant                                              
        s.fuelMargCost                  =   s.infrastructureCost' + s.fuelOandMcost + s.plantOperLaborCost.*ones(s.runTime,s.numTech) + s.feedCost2nd - s.fuelByprodRevenue;
        %  +s.feedCostHeatPower(time,i)+s.fuelFeedCost(time,i)  % internal in GAMS
end
