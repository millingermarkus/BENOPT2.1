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
%
% Calculation of greenhouse gas emissions of biomass crops and conversion
% technologies
%

function [s,f]=ghgEmissions(s,f)

for time=1:s.runTime
    %% Feedstock
    f.ghgCultivationTotHa(time,:)           =   f.ghgSeeds.*f.ghgEFSeeds...
        +f.ghgN2Oha.*f.ghgEFN2O...
        +f.ghgNha.*f.ghgEFN(time)...
        +f.ghgP2O5.*f.ghgEFP2O5...
        +f.ghgK2O.*f.ghgEFK2O(1)...
        +f.ghgCaO.*f.ghgEFCaO(1)...
        +f.ghgMgO.*f.ghgEFMgO...
        +f.ghgPesticides.*f.ghgEFPesticides(1)...
        +f.ghgPowerDrying.*s.ghgEFPower(time)...
        +f.ghgDiesel.*s.ghgEFDiesel(time); %kg Co2eq/ha/a
    
    f.ghgCultivationTotTfm(time,:)          =   f.ghgCultivationTotHa(time,:)./f.cropYieldFM(time,:); %%kg Co2eq/tFM - FeedYield without temporal development
    f.ghgCultivationTotGJfeed(time,:)       =   f.ghgCultivationTotTfm(time,:)./f.cropFMenergyContent; %%kg Co2eq/GJfeed
    %%
    f.ghgTransport1(time)                   =   (s.ghgTransp1DistFull.*s.ghgTranspDieselFull+...
        s.ghgTransp1DistEmpty.*s.ghgTranspDieselEmpty).*s.ghgEFDiesel(time)./s.ghgTransp1Amount; %CO2eq/tFM
    
    f.ghgTransport1GJfeed(time,1:f.numCrop) =   f.ghgTransport1(time).*ones(1,f.numCrop)./f.cropFMenergyContent; %CO2eq/tFM
    
    
    %% Hard coded reference to Poplar - redo!
    if      s.heatOption==1
        s.ghgEFHeat(time,:)                 =   ones([s.numTech,1]).*0.067; %kgCO2eq/MJ
    elseif  s.heatOption==2
        s.ghgEFHeat(time,:)                 =   ones([s.numTech,1])*(...
            f.ghgCultivationTotHa(time,6)...                    %CO2eq/ha
            +f.ghgTransport1(time).*f.cropYieldFM(6)...  %CO2eq/tFM * tFM/ha
            )./(f.cropYieldGJ(6).*10^6*s.heatEta);         %CO2eq/ha  *(GJ/ha)^-1 * GJ/MJ * eta^-1
    end
    s.ghgP1tot(time,:)                      =   s.ghgP1Heat(time,:).*s.ghgEFHeat(time,:)...
        +   s.ghgP1Power(time,:).*s.ghgEFPower(time)...                                    +   s.ghgP1Hydrogen.*s.ghgEFHydrogen(time)...Hydrogen GHG is calculated in GAMS
        +   s.ghgP1CO2(time,:).*s.ghgEFCO2(time);%
    
    s.ghgP2tot(time,:)                      =   s.ghgP2Heat(time,:).*s.ghgEFHeat(time,:)...
        +s.ghgP2Power(time,:).*s.ghgEFPower(time)...
        +s.ghgP2CH3OH(time,:).*s.ghgEFCH3OH(time);
    
    s.ghgP2Byprod(time,:)                   =   s.ghgP2YieldByprod.*10^3-s.ghgP2ByprodUpgradePower.*s.ghgEFPower(time); %/tFM_crop
    
    s.ghgTransport21(time,:)                =   s.ghgTranspGasGridPower.*s.ghgEFPower(time)+s.ghgTranspProcessHeat.*s.ghgEFHeat(time,:); %kWh/GJ * kgCO2/kWh + MJ/GJ * kgCO2/MJ = kgCO2/GJ
    s.ghgTransport22(time,:)                =   (s.ghgTransp2DistFull.*s.ghgTranspDieselFull+s.ghgTransp2DistEmpty.*s.ghgTranspDieselEmpty).*s.ghgEFDiesel(time)./s.ghgTranspAmount./s.fuelSpecificEnergy; %kgCO2eq/t * (GJ/t)^-1 = kgCO2eq/GJ
    s.ghgTransport2(time,:)                 =   s.ghgTransport21(time,:)+s.ghgTransport22(time,:);
    
    s.P1toGJfactor(time,:)                  =   s.ghgP1AllocationFactor.*s.ghgP2AllocationFactor...
        ./(s.cropFMenergyContent.*s.plantConvEta(time,:));
    
    s.P2toGJfactor(time,:)                  =   s.ghgP2AllocationFactor./(s.cropFMenergyContent.*s.plantConvEta(time,:));
    
    s.ghgCultivationTotGJ(time,:)           =   zeros(1,s.numTech);%s.ghgCultivationTotHa(time,:).*s.hatoGJfactor(time,:);
    s.ghgTransport1GJ(time,:)               =   zeros(1,s.numTech);%s.ghgTransport1(time,:).*s.P1toGJfactor(time,:);
    
    %%
    s.ghgP1totGJ(time,:)                    =   s.ghgP1tot(time,:).*s.P1toGJfactor(time,:);
    s.ghgP2totGJ(time,:)                    =   s.ghgP2tot(time,:).*s.P2toGJfactor(time,:);
    s.ghgP2ByprodGJ(time,:)                 =   -s.ghgP2Byprod(time,:)./(s.cropFMenergyContent.*s.plantConvEta(time,:));
    s.ghgTransport2GJ(time,:)               =   s.ghgTransport2(time,:);
    
    %kgCo2eq/GJ
    s.fuelGHGemission(time,:)               =   s.ghgCultivationTotGJ(time,:)+s.ghgTransport1GJ(time,:)+s.ghgP1totGJ(time,:)+s.ghgP2totGJ(time,:)+s.ghgP2ByprodGJ(time,:)+s.ghgTransport2GJ(time,:);
    
    
    s.ghgHeatTotGJ(time,:)                  =   s.ghgP1Heat(time,:).*s.ghgEFHeat(time,:).*s.P1toGJfactor(time,:)...
        +   s.ghgP2Heat(time,:).*s.ghgEFHeat(time,:).*s.P2toGJfactor(time,:)...
        +   s.ghgTranspProcessHeat.*s.ghgEFHeat(time,:);
    
    s.ghgPowerTotGJ(time,:)                 =   s.ghgP1Power(time,:).*s.ghgEFPower(time).*s.P1toGJfactor(time,:)...
        +   s.ghgP2Power(time,:).*s.ghgEFPower(time).*s.P2toGJfactor(time,:)...
        +   s.ghgTranspGasGridPower.*s.ghgEFPower(time);
    s.ghgDieselTotGJ(time,:)                =   s.ghgTransport22(time,:);
    
    s.ghgSoilN2OTotGJ(time,:)               =   zeros(1,s.numTech);
    s.ghgFertilizerTotGJ(time,:)            =   zeros(1,s.numTech);
    
    s.ghg2ndFeedTotGJ(time,:)               =   s.ghgP2CH3OH(time,:).*s.ghgEFCH3OH(time).*s.P2toGJfactor(time,:);
    
    s.ghgOtherTotGJ(time,:)                 =   zeros(1,s.numTech);
    
    s.fuelGHGabatement(time,:)              =   s.referenceGHGemission-s.fuelGHGemission(time,:); %% %kgCo2eq/GJ - Positive number
end
