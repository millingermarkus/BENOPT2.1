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
% Function for setting the country specific data
%

function [f,g,s] = setCountryData(techData,countryID,powerDataCountry,s,f,g)
s.countryNames              =   techData.textdata.countryData(1,3:end);
indexCountry                =   find(contains(s.countryNames,{countryID}));

s.discountRateInvest        =   techData.data.countryData(1,indexCountry);
s.labourCostStart           =   techData.data.countryData(2,indexCountry); %€/h

s.windOnShoreInit           =   techData.data.countryData(11,indexCountry);
s.windOnShoreEnd            =   techData.data.countryData(12,indexCountry);
s.windOffShoreInit          =   techData.data.countryData(13,indexCountry);
s.windOffShoreEnd           =   techData.data.countryData(14,indexCountry);
s.solarPVInit               =   techData.data.countryData(15,indexCountry);
s.solarPVEnd                =   techData.data.countryData(16,indexCountry);
s.demandPowerInit           =   techData.data.countryData(17,indexCountry);
s.demandPowerEnd            =   techData.data.countryData(18,indexCountry);
s.powerStorageInit          =   techData.data.countryData(19,indexCountry);
s.powerStorageEnd           =   techData.data.countryData(20,indexCountry);
s.powerStorageMaxInit       =   techData.data.countryData(21,indexCountry);
s.powerStorageMaxEnd        =   techData.data.countryData(22,indexCountry);
s.RENMustRun                =   techData.data.countryData(23,indexCountry); %Hydro average over year
s.MustRun                   =   techData.data.countryData(24,indexCountry); %Must-run electricity generation capacity

s.capFacPVInit              =   techData.data.countryData(25,indexCountry); %kWh/kWp
s.capFacPVEnd               =   techData.data.countryData(26,indexCountry); %kWh/kWp
s.capFacWindOnShoreInit     =   techData.data.countryData(27,indexCountry); %kWh/kWp
s.capFacWindOnShoreEnd      =   techData.data.countryData(28,indexCountry); %kWh/kWp
s.capFacWindOffShoreInit    =   techData.data.countryData(29,indexCountry); %kWh/kWp
s.capFacWindOffShoreEnd     =   techData.data.countryData(30,indexCountry); %kWh/kWp

g.landUseInit               =   techData.data.countryData(31,indexCountry);
g.landUseEnd                =   techData.data.countryData(32,indexCountry);

s.literPetrolPer100KMstart  =   techData.data.countryData(41,indexCountry);  %liter petrol per 100 km on average in 2018
s.personKMInit              =   techData.data.countryData(42,indexCountry);
s.personKMEnd               =   techData.data.countryData(43,indexCountry);
s.totalVehicles             =   techData.data.countryData(44,indexCountry).*10^6;
s.EVstart                   =   techData.data.countryData(45,indexCountry).*10^6;

g.demandStart               =   techData.data.countryData(51:51+s.numSectors-1,indexCountry);
g.demandEnd                 =   techData.data.countryData(71:71+s.numSectors-1,indexCountry);

%Power price & heat price for required input
for i=1:3
    s.powerPrice(i,:)       =   linspace(techData.data.countryData(99+i,indexCountry),techData.data.countryData(106+i,indexCountry),s.runTime).*10^3.*10^-2'; %[ct/kWh -> €/MWh]
end
s.heatPrice                 =   linspace(techData.data.countryData(103,indexCountry),techData.data.countryData(109,indexCountry),s.runTime).*10^3.*10^-2; %[ct/kWh -> €/MWh]

s.plantCap                  =   techData.data.techInputData(198+indexCountry,1:end);%*10^6;

f.cropYieldFMlow            =   techData.data.feedstockInputData(40+indexCountry,1:end); %GJ/tFM
f.cropYieldFMhigh           =   techData.data.feedstockInputData(70+indexCountry,1:end); %GJ/tFM
f.cropLandUseInit           =   techData.data.feedstockInputData(100+indexCountry,1:end); % [ha]

% Residue potential data [PJ_feed]
f.resPot                    =   techData.data.countryData(120:120+f.numResidue-1,indexCountry).*ones(1,s.runTime); %PJ_feed
f.resPotImport              =   ...
    techData.data.countryData(140:140+f.numResidue+f.numCrop-1,indexCountry).*ones(1,s.runTime);

% Residue price start [€/GJ]
f.resPriceIniMin            =   techData.data.countryData(170:170+f.numResidue-1,indexCountry);
f.resPriceIniMax            =   techData.data.countryData(190:190+f.numResidue-1,indexCountry);

g.resImportMax              =   techData.data.countryData(202,indexCountry).*ones(1,s.runTime);

s.ghgEFPowerData            =   techData.data.countryData(210:213,indexCountry)'; %kgCO2eq/kWh

s.powerLoad                 =   powerDataCountry{:,contains(powerDataCountry.Properties.VariableNames,join([countryID,'_load_actual_entsoe_power_statistics']))};
s.PVcap                     =   powerDataCountry{:,contains(powerDataCountry.Properties.VariableNames,join([countryID,'_solar_cap']))};
if isempty(s.PVcap)==1 %if the data does not exist for the country/year, use the given initial capacity as approximation (the set weather year should not be too far off the capacity year for this to work properly)
    s.PVcap                 =   s.solarPVInit.*ones(8760,1)*1000; %GW->MW
end
s.PVgen                     =   powerDataCountry{:,contains(powerDataCountry.Properties.VariableNames,join([countryID,'_solar_gen']))};
s.WindOnCap                 =   powerDataCountry{:,contains(powerDataCountry.Properties.VariableNames,join([countryID,'_wind_onshore_cap']))};
if isempty(s.WindOnCap)==1
    s.WindOnCap             =   s.windOnShoreInit.*ones(8760,1)*1000; %GW->MW
end
s.WindOnGen                 =   powerDataCountry{:,contains(powerDataCountry.Properties.VariableNames,join([countryID,'_wind_onshore_gen']))};
s.WindOffCap                =   powerDataCountry{:,contains(powerDataCountry.Properties.VariableNames,join([countryID,'_wind_offshore_cap']))};
if isempty(s.WindOffCap)==1
    s.WindOffCap            =   s.windOffShoreInit.*ones(8760,1)*1000; %GW->MW
end
s.WindOffGen                =   powerDataCountry{:,contains(powerDataCountry.Properties.VariableNames,join([countryID,'_wind_offshore_gen']))};
if isempty(s.WindOffGen)==1
    s.WindOffGen            =   10^-6*ones(8760,1);
end

%The number of historic passenger vehicles in each fuel type
%(Diesel,Hybrid (excl. Plug-in-hybrid),Plug-in-Hybrid,Battery electric/Fuel
%cell,Natural gas (incl. LPG),Flex-Fuel,Petrol)
s.fuelTypePassengerVehicles =   techData.data.countryData(90:96,indexCountry);%data.vehicleMarket(20:50,14:20);

end