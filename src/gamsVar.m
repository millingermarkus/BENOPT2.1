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


function [gamsTemp,g]=gamsVar(s,f,q,r,scenario,g,techData)


%% Definition of sets
% Price categories
g.cats          =   strsplit(num2str(1:f.cat));
g.C             =   gamsVarCreate('cat',0,g.cats,0,0,'set');

%Technology set
g.I             =   gamsVarCreate('tech',0,s.techNames,0,0,'set');

g.J             =   gamsVarCreate('market',0,s.sectorNames,0,0,'set');

g.F             =   gamsVarCreate('fuel',0,s.fuelNames,0,0,'set');

g.BR            =   gamsVarCreate('feedResidue',0,f.residueNames,0,0,'set');

g.BF            =   gamsVarCreate('feedCrop',0,f.cropNames,0,0,'set');

% Power sources
g.PwrSrc        =   gamsVarCreate('powerSource',0,f.powerNames,0,0,'set');

% Power mix set
g.PwrMix        =   gamsVarCreate('PowerMix',0,'PowerMix',0,0,'set');

g.PwrRes        =   gamsVarCreate('PowerRes',0,'PowerRes',0,0,'set');

% Biomass/Feestock: Residues+Cultivation+power source combined
g.B             =   gamsVarCreate('feed',0,f.feedNames,0,0,'set');

%% Set Dependency

% Which technologies use which biomass
g.techbiomass   =   transpose(techData.data.techInputData(96:(96+f.numResidue+f.numCrop+f.numPowerSource-1),1:s.numTech));
g.techbiomass(isnan(g.techbiomass))=0;

g.tb            =   gamsVarCreate('TB',g.techbiomass,s.techNames,f.feedNames,0,'set');

% % Which technologies are allowed on which sectors (TS(techNames2,sectorNames))
%%
g.techsectors   =   transpose(techData.data.techInputData(123:133,1:s.numTech));
g.techsectors(isnan(g.techsectors))=0;

g.ts            =   gamsVarCreate('TS',g.techsectors,s.techNames,s.sectorNames,0,'set');

% Which technologies are allowed on which fuel types (TS(techNames2,sectorNames))
%%
g.fuelTypeDef                 =   transpose(techData.data.techInputData(134:140,1:s.numTech));
g.fuelTypeDef(isnan(g.fuelTypeDef))=0;

g.fuelType      =   gamsVarCreate('fuelType',g.fuelTypeDef,s.techNames,s.fuelNames,0,'set');

g.tDiesel       =   gamsVarCreate('techDiesel',0,s.techNames(g.fuelTypeDef(:,1)==1),0,0,'set');

g.tEtOH         =   gamsVarCreate('techEtOH',0,s.techNames(g.fuelTypeDef(:,2)==1),0,0,'set');

g.tCH4          =   gamsVarCreate('techCH4fuel',0,s.techNames(g.fuelTypeDef(:,3)==1),0,0,'set');

g.tLNG          =   gamsVarCreate('techLNG',0,s.techNames(g.fuelTypeDef(:,4)==1),0,0,'set');

g.tH2           =   gamsVarCreate('techH2',0,s.techNames(g.fuelTypeDef(:,5)==1),0,0,'set');

g.tAviationFuel =   gamsVarCreate('techAviationFuel',0,s.techNames(g.fuelTypeDef(:,6)==1),0,0,'set');

g.tEV           =   gamsVarCreate('techEV',0,s.techNames(g.fuelTypeDef(:,7)==1),0,0,'set');
%%

%Marginal cost (OPEX), excluding feedstock inputs (added separately) [M€/PJ]
gamsTemp.costMarg           =  gamsVarCreate('costMarg',q.fuelMargCost,s.year,s.techNames,0,'parameter');

%Investment cost (CAPEX) [M€/GW]
gamsTemp.costInv            =  gamsVarCreate('costInv',q.plantInvCost,s.year,s.techNames,0,'parameter');

%Levelized investment cost [M€/GW]
gamsTemp.costInvLevel       =  gamsVarCreate('costInvLevel',q.plantInvCostLevel,s.year,s.techNames,0,'parameter');

%GHG emissions for feedstocks [kgCo2eq/GJ = ktCo2eq/PJ]
gamsTemp.ghgEmisFeed        =  gamsVarCreate('ghgEmisFeed',r.ghgCultivationTotGJfeed,s.year,f.feedNames,0,'parameter');

%GHG emissions from conversion [kgCo2eq/GJ = ktCo2eq/PJ]
gamsTemp.ghgEmisGateWheel   =  gamsVarCreate('ghgEmisGateWheel',q.fuelGHGemission,s.year,s.techNames,0,'parameter');

%GHG substitute reference development for each sector [kgCo2eq/GJ = ktCo2eq/PJ]
ghgRef                          =   q.referenceGHGemission.*[ones(s.runTime,1)';
    ones(s.runTime,1)';
    ones(s.runTime,1)';
    ones(s.runTime,1)';
    ones(s.runTime,1)';
    ones(s.runTime,1)';
    ones(s.runTime,1)';
    ones(s.runTime,1)';
    ones(s.runTime,1)';
    zeros(s.runTime,1)';
    zeros(s.runTime,1)']'; %No reference for intermediate markets for H2 and CH4, only for end markets (otherwise double counting)
gamsTemp.ghgRef             =  gamsVarCreate('ghgRef',ghgRef,s.year,s.sectorNames,0,'parameter');

%Power mix GHG emissions [kgCO2eq/kWh * [kWh/GJ]^-1 => kgCO2eq/GJ = ktCO2eq/PJ]
gamsTemp.powerMixEmis       =  gamsVarCreate('powerMixEmis',q.ghgEFPower./(3.6/1000),s.year,0,0,'parameter');

%GHG emissions transport to gate [kgCo2eq/GJ = ktCo2eq/PJ] - not yet feedstock specific
gamsTemp.ghgEmisT1          =  gamsVarCreate('ghgEmisT1',r.ghgTransport1GJfeed(:,1),s.year,0,0,'parameter');

%Negative residual load = excess electricity [PJ/timestep]
gamsTemp.residualLoad       =  gamsVarCreate('residualLoad',q.surplusPowerVar.*3.6,g.timeStepsIntraYear,s.year,0,'parameter');

% Positive residual load = demand for dispatchable power [PJ/timestep]
gamsTemp.posResLoad         =  gamsVarCreate('posResLoad',q.posResLoad.*3.6,g.timeStepsIntraYear,s.year,0,'parameter');

% Conversion efficiency [PJ_energy,main product per PJ_feed]
gamsTemp.convEta            =  gamsVarCreate('convEta',q.plantConvEta,s.year,s.techNames,0,'parameter');

% Conversion efficiency biomass specific [PJ_energy per PJ_feed]
gamsTemp.convEtaBiomSpec    =  gamsVarCreate('convEtaBiomSpec',q.convEtaBiomSpec,s.year,f.feedNames,s.techNames,'parameter');

% Capacity factor [dimensionless - full load hours per year divided by hours/year]
gamsTemp.capF               =  gamsVarCreate('capF',q.plantCapacityFactor,s.year,s.techNames,0,'parameter');

% Capacity of initial stock for first years of lifetime [GW]
gamsTemp.cap0               =  gamsVarCreate('cap0',q.cap0.*10^-3,s.year,s.techNames,0,'parameter');

% Demand [PJ]
gamsTemp.demand             =  gamsVarCreate('demand',g.Demand',s.year,s.sectorNames,0,'parameter');

% Passenger road vehicle km [[Mrd. vehicle-km]]
gamsTemp.vehicleKMroadTot   =  gamsVarCreate('vehicleKMroadTot',s.passengerVehicleKMtot.*10^-9,s.year,0,0,'parameter');

% Passenger road fuel economy baseline [PJ/Mrd. km for average ICEV]
gamsTemp.MJperKMavgICEV     =  gamsVarCreate('MJperKMavgICEV',s.MJperKMavgICEV,s.year,0,0,'parameter');

% relative fuel economy of fuel types %[frac compared to reference in each sector -> GJ/vehicle-km or tonne-km]
gamsTemp.relativeFuelEconomy=  gamsVarCreate('relativeFuelEconomy',s.relativeFuelEconomy,s.techNames,s.sectorNames,0,'parameter');

% Historic Vehicle Fuel Demand [PJ]
gamsTemp.historicFuelDemand =  gamsVarCreate('historicFuelDemand',s.historicICEVPJPerFuelType,s.year,s.fuelNames(1:3),0,'parameter');

%New ICEV fuel demand per year [share of vehicles]
gamsTemp.newVehicSharePass  =  gamsVarCreate('newVehicSharePass',s.newVehicSharePass,s.year,0,0,'parameter');

% Power price [Mio €/MWh]
% Which technologies belong to which aggregated sector? (TSagg(techNames,sectorAggNames))
g.techsectorsAgg            =   transpose(techData.data.techInputData(141:143,1:s.numTech));
g.techsectorsAgg(isnan(g.techsectorsAgg))=0;
gamsTemp.powerPrice         =  gamsVarCreate('powerPrice',10^-6.*(g.techsectorsAgg*s.powerPrice)',s.year,s.techNames,0,'parameter');

% Heat price [Mio €/MWh]
gamsTemp.heatPrice          =  gamsVarCreate('heatPrice',10^-6.*s.heatPrice',s.year,0,0,'parameter');

% Residue import maximum [PJ_biomass]
gamsTemp.resImportMax       =  gamsVarCreate('resImportMax',g.resImportMax',s.year,0,0,'parameter');

% Land demand [ha/PJ]
gamsTemp.landDmdPJ          =  gamsVarCreate('landDmdPJ',r.landReqGJFuel.*10^6,s.year,f.cropNames,0,'parameter');

% Maximal available land for cultivation [ha]
gamsTemp.landMax            =  gamsVarCreate('landMax',g.landMax,s.year,0,0,'parameter');

% land use initial [ha]
gamsTemp.feedLandUseInit    =  gamsVarCreate('cropLandUseInit',f.cropLandUseInit',f.cropNames,0,0,'parameter');

% lifetime of technologies [years]
gamsTemp.lifeT              =  gamsVarCreate('lifeT',q.plantLifeTime',s.techNames,0,0,'parameter');

% power input of technologies [MWh/PJ]
gamsTemp.powerInput         =  gamsVarCreate('powerInput',10^3.*q.powerInput',s.techNames,0,0,'parameter');

% heat input of technologies [MWh/PJ]
gamsTemp.heatInput          =  gamsVarCreate('heatInput',10^3.*q.heatInput',s.techNames,0,0,'parameter');

% Potential of biomass residues [PJ]
gamsTemp.bioResPot          =  gamsVarCreate('bioResPot',f.resPot',s.year,f.residueNames,0,'parameter');

% Potential of biomass residue import [PJ]
gamsTemp.bioResPotImport    =  gamsVarCreate('bioResPotImport',f.resPotImport',s.year,f.feedNames,0,'parameter');

% Biomass price (time, biomass, cats) [Mio€/PJ]
gamsTemp.biomassPrice       =  gamsVarCreate('feedPrice',[f.cropPriceGJ f.resPrice f.powerPrice],s.year,f.feedNames,g.cats,'parameter');

% Biomass price Import (time, biomass) [Mio€/PJ]
gamsTemp.biomassPriceImport =  gamsVarCreate('feedPriceImport',squeeze(gamsTemp.biomassPrice.val(:,:,3)),s.year,f.feedNames,0,'parameter');

% Process CO2 feedstock input (PtX) [t/GJ=Mt/PJ]
gamsTemp.CO2input           =  gamsVarCreate('CO2input',s.feed2ndCO2Amount,s.techNames,0,0,'parameter');

% CO2 feedstock price
gamsTemp.CO2price           =  gamsVarCreate('CO2price',s.co2price,s.year,0,0,'parameter');

% Maximal available CO2 as input
gamsTemp.CO2source          =  gamsVarCreate('CO2source',q.co2source,s.year,0,0,'parameter');

%MtCO2/MtCO2
gamsTemp.ghgRefCO2          =  gamsVarCreate('ghgRefCO2',s.ghgRefCO2,0,0,0,'scalar');

%PJ
gamsTemp.pwrMixMax          =  gamsVarCreate('pwrMixMax',s.powerMixMax,0,0,0,'scalar');

% Process H2 feedstock input (PtX) [GJ/GJ]
gamsTemp.H2input            =  gamsVarCreate('H2input',s.feed2ndH2in,s.year,s.techNames,0,'parameter');

%GHG target
gamsTemp.ghgTarget          =  gamsVarCreate('ghgTarget',1,0,0,0,'scalar');

%Time steps intra-year
g.d                         =  gamsVarCreate('d',0,g.timeStepsIntraYear,0,0,'set');

gamsTemp.dMax               =  gamsVarCreate('dMax',max(g.timeStepsIntraYear),0,0,0,'scalar');


% Goal function
gamsTemp.solveOption        =  gamsVarCreate('solveOption',0,0,0,0,'scalar');

% Heat byproduct (time, tech) [PJ/PJ]
heatByprodTemp=q.heatByprod;
heatByprodTemp(heatByprodTemp==0)=1; % replace 0 with 1 -> now one can easily switch the byproducts in GAMS
gamsTemp.heatByprod         =  gamsVarCreate('heatByprod',heatByprodTemp,s.year,s.techNames,0,'parameter');

%H2 max in all sectors
gamsTemp.H2Max              =  gamsVarCreate('H2Max',[zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    ones(s.runTime,1)';
    g.H2maxAviation;
    g.H2maxGoods;
    g.H2maxShipping;
    ones(s.runTime,1)';
    ones(s.runTime,1)']',s.year,s.sectorNames,0,'parameter');

%CH4 max in all sectors
gamsTemp.CH4Max              =  gamsVarCreate('CH4Max',[zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    g.CH4maxLand;
    zeros(s.runTime,1)';
    g.CH4maxGoods;
    g.CH4maxShipping;
    ones(s.runTime,1)';
    ones(s.runTime,1)']',s.year,s.sectorNames,0,'parameter');

%LCH4 max in all sectors
gamsTemp.LCH4Max              =  gamsVarCreate('LCH4Max',[zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    zeros(s.runTime,1)';
    g.LCH4maxLand;
    zeros(s.runTime,1)';
    g.LCH4maxGoods;
    g.LCH4maxShipping;
    ones(s.runTime,1)';
    ones(s.runTime,1)']',s.year,s.sectorNames,0,'parameter');

end