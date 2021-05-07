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
%s
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
% Contact: markus.millinger@ufz.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function for setting the data
%

function [f,g,s] = setData(techData,f,g,s)

%Technology variables
s.techNames                 =   techData.textdata.techInputData(2,3:end);
s.techNamesLegend           =   s.techNames;

%Sector variables
s.sectorNames               =   techData.textdata.techInputData(125:135,2)';
s.sectorNamesLegend         =   s.sectorNames;

%Fuel type variable
s.fuelNames                 =   techData.textdata.techInputData(136:142,2)';

%Feedstock variables
f.residueNames              =   techData.textdata.countryData(121:121+f.numResidue-1,1)';
f.cropNames                 =   techData.textdata.feedstockInputData(1,3:f.numCrop+2);
f.cat                       =   3; %For dividing e.g. biomass types into 3 equal shares with different prices
f.numPowerSource            =   2;
f.powerNames                =   {'PowerMix','PowerRes'};
f.feedNames                 =   [f.cropNames f.residueNames f.powerNames];

%% Definition of Input Data s= Technology specific  f=feedstock specific

f.runTime                   =   s.runTime;
s.year                      =   linspace(2020,2050,s.runTime);
s.hourYear                  =   linspace(1,8760,8760);
s.dayYear                   =   linspace(1,365,365);

%% Set parameters for power sector

%Onshore wind capacity [GW] from start year to end year in 5-year steps
s.onShore                   =   linspace(s.windOnShoreInit,s.windOnShoreEnd,7);

%Offshore
s.offShore                  =   linspace(s.windOffShoreInit,s.windOffShoreEnd,7); %GW

%Photovoltaics
s.photoV                    =   linspace(s.solarPVInit,s.solarPVEnd,7); %GW

%Power demand total for a year
s.demandPower               =   linspace(s.demandPowerInit,s.demandPowerEnd,7); %GW

%Power storage effect
s.powerStorage              =   linspace(s.powerStorageInit,s.powerStorageEnd,7);     %GW

%Power storage capacity
s.powerStorageMax           =   linspace(s.powerStorageMaxInit,s.powerStorageMaxEnd,7);   %GWh

%Capacity factor development
s.capFacPV                  =   linspace(s.capFacPVInit,s.capFacPVEnd,7)./8760; %fraction of time - C_f
s.capFacWindOnShore         =   linspace(s.capFacWindOnShoreInit,s.capFacWindOnShoreEnd,7)./8760; %fraction of time - C_f
s.capFacWindOffShore        =   linspace(s.capFacWindOffShoreInit,s.capFacWindOffShoreEnd,7)./8760; %fraction of time - C_f

%Scaling wind on- and offshore and PV generation accd. to capacity factor
for i=1:7
    [s.PVgenScaled(i,:),s.PVcapFacInst(i,:)]    =   ...
        scalingCapFacVRE(s.PVcap,s.PVgen,s.capFacPV(i));
    [s.WindOnScaled(i,:),s.WindOncapFacInst(i,:)]   =   ...
        scalingCapFacVRE(s.WindOnCap,s.WindOnGen,s.capFacWindOnShore(i));
    [s.WindOffScaled(i,:),s.WindOffcapFacInst(i,:)]   =   ...
        scalingCapFacVRE(s.WindOffCap,s.WindOffGen,s.capFacWindOffShore(i));
end

%Set parameters for crops
g.landMax                       =   10^6.*linspace(g.landUseInit,g.landUseEnd,s.runTime);   %ha

%Set restrictions for fuel types in sectors
%--Hydrogen
g.H2maxShipping                 =   linspace(0,0.1,s.runTime); %Share of market
g.H2maxGoods                    =   linspace(0,0.3,s.runTime); %Share of market
g.H2maxAviation                 =   linspace(0,0.1,s.runTime); %Share of market

%--Methane
g.CH4maxLand                    =   linspace(0,0,s.runTime);   %Share of market
g.CH4maxShipping                =   linspace(0,0,s.runTime);   %Share of market
g.CH4maxGoods                   =   linspace(0,0.3,s.runTime); %Share of market

%--Liquefied Methane
g.LCH4maxLand                   =   linspace(0,0,s.runTime);   %Share of market
g.LCH4maxShipping               =   linspace(0,0.3,s.runTime); %Share of market
g.LCH4maxGoods                  =   linspace(0,0.3,s.runTime); %Share of market

%Set input CO2 limitations, price and GHG reference for CO2 usage
s.co2source                     =   linspace(60,60,s.runTime);
s.co2price                      =   50*linspace(1,1,s.runTime); %€/tCO2
s.ghgRefCO2                     =   0;

%Maximal usage of power mix for EVs or hydrogen (if power mix is
%checked in the input file for these usages)
s.powerMixMax                   =   0.15*s.demandPowerInit*3.6; %PJ - 10% of the total power demand can be used for H2 and EVs - Change when expanding scope

%% Demand (time,sectors) [PJ]
for j=1:s.numSectors
    g.Demand(j,:)       =   ...
        interp1([2020 2050],[g.demandStart(j) g.demandEnd(j)],2020:1:2050,'linear');
end

% %% System data
% %Power price & heat price for required input
% s.powerPrice                =   10^3.*10^-2.*techData.data.demandData(10:12,1:s.runTime);%[€/MWh]
% % s.powerPriceDevNormed       =   techData.data.demandData(8,1:s.runTime);%[€/MWh]
% s.heatPrice                 =   10^3.*10^-2.*techData.data.demandData(15,1:s.runTime)';%[€/MWh]
%- for process heat, see feedCost function. Possibly differentiate input and output heat price - district heating could be output heat price reference
% s.GHGabateTarget            =   160*10^9*linspace(0.05,0.08,s.runTime); %kgCO2eq/a

%% Definition of technology data / Life Time
% Technology Lifetime (tech) [a]
s.plantLifeTime             =   techData.data.techInputData(1,1:s.numTech); %a

%% Definition of investment
% Technology full load hours per year (tech) [h/a]
s.fullLoadHoursInit         =   techData.data.techInputData(2,1:s.numTech); %h/a
s.fullLoadHoursEnd          =   techData.data.techInputData(3,1:s.numTech); %h/a
% Technology Invest(time) [€/MWcap]
s.plantInvCostProMWinit     =   techData.data.techInputData(4,1:s.numTech); %€/kWcap  = M€/GWcap
s.plantInvCostProMWend      =   techData.data.techInputData(5,1:s.numTech); %€/kWcap = M€/GWcap
% Maint & Operation [%/invest)
s.plantMOInvShareInit       =   techData.data.techInputData(9,1:s.numTech)*10^-2;
% s.plantMOInvShareEnd        =   techData.data.techInputData(10,1:s.numTech)*10^-2;
% Labour costs
s.plantOperLaborCost        =   techData.data.techInputData(10,1:s.numTech); %€/GJ

%% Calculation of conversion efficency over time and capacity factor

s.plantConvEtaInit          =   techData.data.techInputData(11,1:s.numTech); %fraction of energy in feedstock in end product (MJ/MJ)
s.plantConvEtaLimit         =   techData.data.techInputData(12,1:s.numTech);

s.convEtaBiomSpec(1,:,:)            =   techData.data.techInputData(147:170,1:s.numTech);
s.convEtaBiomSpec(s.runTime,:,:)    =   techData.data.techInputData(173:196,1:s.numTech);

for tech=1:s.numTech
    for feed=1:length(f.feedNames)
        s.convEtaBiomSpec(:,feed,tech)  =   ...
            linspace(s.convEtaBiomSpec(1,feed,tech),...
            s.convEtaBiomSpec(s.runTime,feed,tech),s.runTime);
    end
    s.plantConvEta(:,tech)                          =   ...
        linspace(s.plantConvEtaInit(tech),s.plantConvEtaLimit(tech),s.runTime)';
    s.plantFullLoadHours(:,tech)                    =   ...
        linspace(s.fullLoadHoursInit(tech),s.fullLoadHoursEnd(tech),s.runTime)';
    s.plantMOInvShare(:,tech)                       =   ...
        linspace(s.plantMOInvShareInit(tech),s.plantMOInvShareInit(tech),s.runTime)';
end

s.plantCapacityFactor       =   s.plantFullLoadHours./8760;

%% Definition of Biomass/ Feedstock data

%%%%%%%% GHG Feedstock
%Emissions
f.ghgSeeds          =   techData.data.feedstockInputData(19,1:end); %kg/ha/a
f.ghgN2OhaAverage   =   techData.data.feedstockInputData(20,1:f.numCrop); %kg N2O/ha/a
f.ghgN2OhaHigh      =   techData.data.feedstockInputData(21,1:f.numCrop); %kg N2O/ha/a
f.ghgN2OhaLow       =   techData.data.feedstockInputData(22,1:f.numCrop); %kg N2O/ha/a
f.ghgN2Oha          =   f.ghgN2OhaAverage;

f.ghgNha            =   techData.data.feedstockInputData(23,1:f.numCrop); %kg N/ha/a
f.ghgDiesel         =   techData.data.feedstockInputData(30,1:f.numCrop); %l/ha/a

f.ghgP2O5           =   techData.data.feedstockInputData(24,1:f.numCrop); %kg/ha/a
f.ghgK2O            =   techData.data.feedstockInputData(25,1:f.numCrop); %kg/ha/a
f.ghgCaO            =   techData.data.feedstockInputData(26,1:f.numCrop); %kg/ha/a
f.ghgMgO            =   techData.data.feedstockInputData(27,1:f.numCrop); %kg/ha/a
f.ghgPesticides     =   techData.data.feedstockInputData(28,1:f.numCrop); %kg/ha/a
f.ghgPowerDrying    =   techData.data.feedstockInputData(29,1:f.numCrop); %kWh/ha/a

% Emission factors
f.ghgEFSeeds        =   techData.data.feedstockInputData(36,1:f.numCrop); %kg/ha/a
f.ghgEFN2O          =   298; %CO2eq/kg N2O
f.ghgEFNStandard    =   5.88; %CO2eq/kg N
f.ghgEFP2O5         =   1.01; %/kg
f.ghgEFK2O          =   [0.58 0.66]; %/kg
f.ghgEFCaO          =   [0.13 0.89]; %/kg
f.ghgEFMgO          =   0; %/kg
f.ghgEFPesticides   =   [10.97 13.9]; %/kg

% Energy content
f.cropDMcontent         =   techData.data.feedstockInputData(1,1:f.numCrop); %frac
f.cropDMenergyContent   =   techData.data.feedstockInputData(2,1:f.numCrop); %GJ/tDM
f.cropFMenergyContent   =   f.cropDMenergyContent.*f.cropDMcontent; %GJ/tFM

s.cropFMenergyContent   =   techData.data.techInputData(25,1:s.numTech); %GJ/tFM

for i=1:f.numCrop
    f.cropYieldFM(:,i)  =   linspace(f.cropYieldFMlow(i),f.cropYieldFMhigh(i),s.runTime);
end
f.cropYieldDM           =   f.cropYieldFM.*f.cropDMcontent;
f.cropYieldGJ           =   f.cropYieldDM.*f.cropDMenergyContent;
f.cropFMenergyContent   =   f.cropDMcontent.*f.cropDMenergyContent;

f.cropLabourHa          =   techData.data.feedstockInputData(6,1:f.numCrop); %Arbeitskraftstunden/ha
f.cropDieselHa          =   techData.data.feedstockInputData(7,1:f.numCrop); %Dieselbedarf/ha
f.cropMachineFixHa      =   techData.data.feedstockInputData(8,1:f.numCrop);
f.cropMachineVarHa      =   techData.data.feedstockInputData(9,1:f.numCrop);
f.cropServiceCostsHa    =   techData.data.feedstockInputData(10,1:f.numCrop);
f.cropDirectCostsHa     =   techData.data.feedstockInputData(11,1:f.numCrop);



%% Definition of technology data
s.heatInput             =   techData.data.techInputData(16,1:s.numTech); %kWh/GJ
s.powerInput            =   techData.data.techInputData(17,1:s.numTech); %kWh/GJ

s.transportCostLow      =   techData.data.techInputData(18,1:s.numTech); %EUR/GJ
s.transportCostHigh     =   techData.data.techInputData(19,1:s.numTech); %EUR/GJ
s.storageCostLow        =   techData.data.techInputData(20,1:s.numTech); %EUR/GJ
s.storageCostHigh       =   techData.data.techInputData(21,1:s.numTech); %EUR/GJ

for i=1:s.numTech
    s.transportCost(i,:)    =   ...
        linspace((s.transportCostHigh(i)-s.transportCostLow(i))/2,...
        s.transportCostLow(i),s.runTime);
    s.storageCost(i,:)      =   ...
        linspace((s.storageCostHigh(i)-s.storageCostLow(i))/2,...
        s.storageCostLow(i),s.runTime);
end

s.feed2ndMethanolAmount =   techData.data.techInputData(34,1:s.numTech); %t/GJ
s.feed2ndH2inLow       =   techData.data.techInputData(35,1:s.numTech); %GJ/GJ
s.feed2ndH2inHigh      =   techData.data.techInputData(36,1:s.numTech); %GJ/GJ
s.feed2ndCO2Amount     =   techData.data.techInputData(37,1:s.numTech); %t/GJ

s.byProdDigestate      =   techData.data.techInputData(40,1:s.numTech); %t/GJ
s.byProdVinasse        =   techData.data.techInputData(41,1:s.numTech); %t/GJ
s.byProdDriedPulp      =   techData.data.techInputData(42,1:s.numTech); %t/GJ
s.byProdAldehyde       =   techData.data.techInputData(43,1:s.numTech); %t/GJ
s.byProdDDGS           =   techData.data.techInputData(44,1:s.numTech); %t/GJ
s.byProdSchrot         =   techData.data.techInputData(45,1:s.numTech); %t/GJ
s.byProdPharmaglycerin =   techData.data.techInputData(46,1:s.numTech); %t/GJ

% Heat as Byprod
s.heatByprodInit       =   techData.data.techInputData(47,1:s.numTech); %GJ/GJ
s.heatByprodLimit      =   techData.data.techInputData(48,1:s.numTech); %GJ/GJ

s.byProdNaphtha        =   techData.data.techInputData(49,1:s.numTech); %EUR/GJ

%Power as Byprod
s.powerByprodInit      =   techData.data.techInputData(50,1:s.numTech); %GJ/GJ
s.powerByprodLimit     =   techData.data.techInputData(51,1:s.numTech); %GJ/GJ

% Byproduct interpolate over years
for tech = 1:s.numTech
    s.heatByprod(:,tech)    =   ...
        linspace(s.heatByprodInit(tech),s.heatByprodLimit(tech),s.runTime);
    s.powerByprod(:,tech)   =   ...
        linspace(s.powerByprodInit(tech),s.powerByprodLimit(tech),s.runTime);
    s.feed2ndH2in(:,tech)   =   ...
        linspace(s.feed2ndH2inHigh(tech),s.feed2ndH2inLow(tech),s.runTime);
end

%%%%%%%%%%%%%%%%%% GHG Processes

s.ghgTransp1Amount      =   24; %t/transport
s.ghgTransp1DistFull    =   80; %km/transport
s.ghgTransp1DistEmpty   =   20; %km/transport
s.ghgTranspDieselFull   =   0.41; %/km
s.ghgTranspDieselEmpty  =   0.24; %/km

s.ghgP1Heat             =   s.heatInput.*s.cropFMenergyContent.*s.plantConvEta; %kWh/GJ_fuel - conversion efficiency to kWh/tFM
s.ghgP1Power            =   s.powerInput.*s.cropFMenergyContent.*s.plantConvEta; %kWh/GJ_fuel - converted to kWh/tFM
s.ghgP1Hydrogen         =   10^3.*s.feed2ndH2in.*s.cropFMenergyContent.*s.plantConvEta; %kg/tFM
s.ghgP1CO2              =   ...
    10^3.*s.feed2ndCO2Amount.*s.cropFMenergyContent.*s.plantConvEta; %kg/tFM

s.ghgP1AllocationFactor =   techData.data.techInputData(74,1:s.numTech); %proc
s.ghgP1Heat(:,s.ghgP1AllocationFactor~=1)   =   ...
    techData.data.techInputData(72,s.ghgP1AllocationFactor~=1).*linspace(1,1,s.runTime)'; %MJ/t_feed
s.ghgP1Power(:,s.ghgP1AllocationFactor~=1)  =   ...
    techData.data.techInputData(73,s.ghgP1AllocationFactor~=1).*linspace(1,1,s.runTime)'; %MJ/t_feed


s.ghgP2AllocationFactor =   techData.data.techInputData(81,1:s.numTech); %proc
s.ghgP2Heat             =       zeros(s.runTime,s.numTech);
s.ghgP2Power            =       zeros(s.runTime,s.numTech);
s.ghgP2CH3OH            =       zeros(s.runTime,s.numTech);
s.ghgP2Heat(:,s.ghgP1AllocationFactor~=1)   =   ...
    techData.data.techInputData(78,s.ghgP1AllocationFactor~=1).*linspace(1,1,s.runTime)'; %MJ/t_feed_intermediate
s.ghgP2Power(:,s.ghgP1AllocationFactor~=1)  =   ...
    techData.data.techInputData(79,s.ghgP1AllocationFactor~=1).*linspace(1,1,s.runTime)'; %MJ/t_feed_intermediate
s.ghgP2CH3OH(:,s.ghgP1AllocationFactor~=1)  =   ...
    techData.data.techInputData(80,s.ghgP1AllocationFactor~=1).*linspace(1,1,s.runTime)'; %MJ/t_feed_intermediate

s.ghgTranspAmount       =   1+49.*techData.data.techInputData(86,1:s.numTech); %t/transport - either 1 (grid) or 50 (tanker)
s.ghgTranspGasGridPower =   4.625.*techData.data.techInputData(85,1:s.numTech); %kWh/m³ - only for those with grid option marked "1"
s.ghgTranspProcessHeat  =   1.6.*techData.data.techInputData(85,1:s.numTech); %MJ/m³ - only for those with grid option marked "1"
s.ghgTransp2DistFull    =   150.*techData.data.techInputData(86,1:s.numTech); %km/transport - only for those with tanker option marked "1"
s.ghgTransp2DistEmpty   =   50.*techData.data.techInputData(86,1:s.numTech); %km/transport - only for those with tanker option marked "1"

s.fuelSpecificEnergy    =   techData.data.techInputData(89,1:s.numTech); %GJ/t [CH4: /m³, unit for electricity?]

s.ghgEFDiesel           =   3.14; %/l
s.ghgEFProcessH2O       =   0.0004; %kgeq/kg
s.ghgEFHNO3             =   1.89; %kgCO2eq/kg
s.ghgEFNaOH             =   [0.47 1.12]; %kgCO2eq/kg
s.ghgEFH3PO4            =   3.011; %kgCO2eq/kg
s.ghgEFDryYeast         =   3.2; %kgCO2eq/kg
s.ghgEFCH4N2O           =   0.81; %kgCO2eq/kg

s.ghgEFCH3OH            =   (10^-3)*43*linspace(27,7,s.runTime); %43 GJ/t (BTL) * kgCO2eq/GJ * t/kg => kgCO2eq/kg

f.ghgEFN                =   linspace(f.ghgEFNStandard,f.ghgEFNStandard*0.2,s.runTime);
s.heatOption            =   2;
s.heatEta               =   0.8;
s.ghgEFDiesel           =   linspace(3.14,3.14*0.2,s.runTime); %/l - Assuming increasing renewable diesel or equivalent
s.ghgP2YieldByprod      =   zeros(1,s.numTech);
s.ghgP2ByprodUpgradePower =   zeros(1,s.numTech);
% s.ghgEFPowerData                =   techData.data.powerEmissions(1,[2017 2018 2030 2050]-2016); %kgCO2eq/kWh interp1([2015 2020 2025 2030 2035 2040 2045 2050],co2sourceData,2020:1:2050,'linear');
s.ghgEFPower            =   interp1([2017 2018 2030 2050],s.ghgEFPowerData,2020:1:2050,'linear');
s.ghgEFHydrogen         =   0.*(s.ghgEFPower./0.7); %Assumed renewable! %om power mix, with 70% eta
s.ghgEFCO2              =   zeros(1,s.runTime);

%% VEHICLES
s.relativeFuelEconomy   =   techData.data.techInputData(56:66,1:s.numTech)'; %GJ/GJ, relative to Petrol/Otto process, for diff. sectors
s.vehicleCostPerVehicleStart =   techData.data.techInputData(67,1:s.numTech); %€/vehicle
s.vehicleCostPerVehicleEnd =   techData.data.techInputData(68,1:s.numTech); %€/vehicle
% s.vehicleCost                   =   linspace(s.vehicleCostPerVehicleStart,s.vehicleCostPerVehicleEnd,s.runTime);

s.eDensityPetrol        =   32.7; %MJ per liter petrol
s.MJperKMavgICEVstart   =   s.literPetrolPer100KMstart*s.eDensityPetrol/100; %liter/100km * MJ / liter  /100 => MJ/km
s.vehicleEtaBaselineDev =   linspace(1,0.6,s.runTime);

s.MJperKMavgICEV        =   s.MJperKMavgICEVstart.*s.vehicleEtaBaselineDev; %MJ/vehicle-km
s.personPerVehicle      =   1.5;

s.personKMtot           =   10^9*linspace(s.personKMInit,s.personKMEnd,s.runTime);
s.passengerVehicleKMtot =   s.personKMtot./s.personPerVehicle;

s.vehicleLifeT          =   14;
s.passengerVehicleKMperVehicle  =   s.passengerVehicleKMtot./s.totalVehicles;

s.newVehiclesPerYear    =   linspace(s.totalVehicles/s.vehicleLifeT,s.totalVehicles/s.vehicleLifeT,s.runTime); %This assumes a constant passenger vehicle fleet
s.newVehicSharePass     =   s.newVehiclesPerYear/s.totalVehicles;
s.EVincreaseFactor      =   1.5;
s.EVincreaseFactorLow   =   1.3;
s.EVnewStart            =   s.EVstart*(s.EVincreaseFactor-1);
s.EVpowerReq            =   linspace(0.2,0.15,s.runTime);

s.discountRateVehicle   =   0.05;
s.annuityFactorVehicle  =   ...
    (s.discountRateVehicle*(1+s.discountRateVehicle)^s.vehicleLifeT)/...
    ((1+s.discountRateVehicle)^s.vehicleLifeT-1);

%The number of historic passenger vehicles in each fuel type
%(Diesel,Hybrid (excl. Plug-in-hybrid),Plug-in-Hybrid,Battery electric/Fuel
%cell,Natural gas (incl. LPG),Flex-Fuel,Petrol)
% s.fuelTypePassengerVehicles =   techData.data.vehicleMarket(20:50,14:20);

for i=1:3 %Decommission of historic Diesel, Petrol and Gas vehicles
    s.fuelTypePassengerVehiclesMainFuels1(1:s.vehicleLifeT,i) =   linspace(s.fuelTypePassengerVehicles(i),0,s.vehicleLifeT);
end
s.fuelTypePassengerVehiclesMainFuels                =   zeros(s.runTime,3);
s.fuelTypePassengerVehiclesMainFuels(1:s.vehicleLifeT,1:3)                =   s.fuelTypePassengerVehiclesMainFuels1;

s.passengerVehiclesTotal    =   sum(s.fuelTypePassengerVehicles,1);
% s.fuelTypePassengerVehiclesMainFuels = s.fuelTypePassengerVehicles(:,[1 7 5]);

s.fuelTypeSharePassengerVehicles   =   ...
    s.fuelTypePassengerVehiclesMainFuels./s.passengerVehiclesTotal;%s.totalVehicles;         

s.fuelTypeSharePassengerVehicles(isnan(s.fuelTypeSharePassengerVehicles))=0;

s.sharePassengerICEVsTotal  =   sum(s.fuelTypeSharePassengerVehicles,2);

s.demLand                   =   s.MJperKMavgICEV.*s.passengerVehicleKMtot*10^-9;%
s.historicICEVPJPerFuelType =   s.fuelTypeSharePassengerVehicles.*s.demLand';


%% Initial capacity decommissioning
for i=1:s.numTech
    s.cap1(1:s.plantLifeTime(i),i) =   linspace(s.plantCap(i),0,s.plantLifeTime(i));
end
s.cap0                  =   s.cap1(1:s.runTime,1:s.numTech); %Necessary if plantLifeTime > runTime (otherwise matrix is too large in gamsRun)

end
