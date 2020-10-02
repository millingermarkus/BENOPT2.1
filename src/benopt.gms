*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*%     BENOPT (BioENergy OPTimisation model)
*%     Copyright (C) 2012-2020 Markus Millinger, Matthias Jordan
*%
*%     This program is free software: you can redistribute it and/or modify
*%     it under the terms of the GNU General Public License as published by
*%     the Free Software Foundation, either version 3 of the License, or
*%     (at your option) any later version.
*%
*%     This program is distributed in the hope that it will be useful,
*%     but WITHOUT ANY WARRANTY; without even the implied warranty of
*%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*%     GNU General Public License for more details.
*%
*%     You should have received a copy of the GNU General Public License
*%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
*%
*% Contact: markus.millinger@ufz.de
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


*$set matout "'matsol.gdx', prd, cost, costAnnual, inst, feedUse, feedUseImport, TS, cap, ghgAbatement, residualLoadUse, CO2use, costTech, ghgAbateTech, prdDaily, dispatchPrd, returnstat";

$gdxin matdata.gdx

SET
*stat                     Solve status /solvestat,modelstat/
stat                     Solve status /modelstat/

market                   energy markets
$loadR market
marketCONV(market)                                                               /CONVel,CONVth/
passenger(market)                                                                /Passenger/
ship(market)                                                                     /Marine/
aviation(market)                                                                 /Aviation/
goods(market)                                                                    /Freight/
CH4market(market)                                                                /CH4market/
H2market(market)                                                                 /H2market/
shipGoods(market)                                                                /Marine,Freight/

fuel                     fuel type options
$loadR fuel
fuelConventional(fuel)                                                           /Diesel,EtOH,CH4/

tech                     technology options
$loadR tech
techImport(tech)                                                                 /Import/

techDiesel(tech)         tech options diesel
$loadR techDiesel

techEtOH(tech)           tech options ethanol
$loadR techEtOH

techCH4fuel(tech)        tech options methane fuel
$loadR techCH4fuel

techLNG(tech)            tech options LNG fuel
$loadR techLNG

techH2(tech)             tech options H2 fuel
$loadR techH2

techAviationFuel(tech)   tech options aviation fuel
$loadR techAviationFuel

techEV(tech)             tech options battery electric vehicle
$loadR techEV


techCONVth(tech)         technlogies in the sector CONVth                        /Biogas,GUD,KWK_l,KWK_m,KWK_HKW/
techCH4in(tech)          technologies that require methane                       /BioCH4_el,GUD,GasTurbine,LCH4,CH4/
techH2in(tech)           technologies that require H2                            /PtG-CH4,PtL,FCEV,FuelCell/
techInter(tech)          technologies that require intermediate CH4 or H2        /BioCH4_el,GUD,Gasturbine,LCH4,CH4,PtG-CH4,PtL,FCEV,FuelCell/
techPel(tech)            Pellet technologies                                     /PelletK_GBD,PelletK_GHD/

feed                  feed options
$loadR feed

feedResidue(feed)  feed options residues
$loadR feedResidue

feedCrop(feed)     feed options crop based
$loadR feedCrop

powerSource(feed)     feedstock power options
$loadR powerSource

powerMix(feed)        feedstock power mix
$loadR powerMix

powerRes(feed)        feedstock power residue options
$loadR powerRes

cat                      feedstock price categories
$loadR cat

year                     global year time                                        /2020*2050/
t(year)                  model year time points                                  /2020*2050/
mediumterm(year)         medium term (2030)                                      /2020*2030/
hour                     hours in a year                                         /1*8760/
h(hour)                  model hours in a year points                            /1*8760/
*day                      days in a year                                          /1*365/
d                        model time steps intra year
$loadR d

TS(tech,market)          Technologies used on markets
$loadR TS

fuelType(tech,fuel)      Fuel type outputs from conversion options
$loadR fuelType

TB(tech,feed)         feed used in technologies
$loadR TB
;

SCALARS
rampF                    capacity expansion ramp per year                        /0.5/
rampC                    constant capacity expansion ramp per year               /100/
rampMinGW                minimum capacity expansion ramp per year [GW]           /0.03/
rampC_GW                 constant capacity expansion ramp per year [GW]          /3/
rampMin                  minimum capacity expansion ramp per year [PJ]           /1/
rampMinVehicles          minimum vehicle expansion ramp per year [PJ]            /0.2/
landF                    land use expansion ramp per year                        /0.5/
rampFvehicles            vehicle fuel type expansion per year                    /0.25/
landMin                  minimum land use expansion per year [ha]                /5000/
lifeTvehicles            Vehicle life time                                       /14/
ghgTarget                GHG target [ktCO2eq]
dMax                     number of time steps intra year
ghgRefCO2                GHG reference for input CO2 (ktCO2eq per MtCO2 - 1000 or zero)
pwrMixMax                Maximum power usage from mix for EVs and H2 production (PJ)
solveOption              solveoption (1=costMin 0=ghgMax)
;

PARAMETERS
landMax(year)                                    arable land limit [ha]
demand(year,market)                              demand matrix [PJ]
costInv(year,tech)                               investment cost [MioEuro per GW]
costInvLevel(year,tech)                          investment cost levelized [MioEuro per GW]
costMarg(year,tech)                              marginal cost  [Mio EUR per PJ]
capF(year,tech)                                  capacity factor development [frac]
cap0(year,tech)                                  initial capacity (continuously decommissioned) [GW]
landDmdPJ(year,feedCrop)                      Land demand (ha per PJ_crop)
cropLandUseInit(feedCrop)                     Feed land use initial [ha]
convEta(year,tech)                               Energetic conversion efficiency crop to main energy carrier (PJ_energy per PJ_crop)
convEtaBiomSpec(year,feed,tech)               Energetic conversion efficiency crop to main energy carrier (PJ_energy per PJ_crop) for each feed type
bioResPot(year,feedResidue)                   feed residue potential (PJ feed)
bioResPotImport(year,feed)                    feed residue potential (PJ feed)
resImportMax(year)                               Maximal residual feed import (PJ)
feedPrice(year,feed,cat)                   feed price (MioEuro per PJ feed)
feedPriceImport(year,feed)                 feed price import (Mio EUR per PJ feed)
heatByprod(year,tech)                            Heat byproduct per unit of main product (PJ per PJ)
lifeT(tech)                                      capacity lifetime for each technology
powerPrice(year,tech)                            power price for each sector (Mio EUR per MWh)
heatPrice(year)                                  heat price development (Mio EUR per MWh)
powerInput(tech)                                 power input (MWh per PJ)
heatInput(tech)                                  heat input (MWh per PJ)
CO2input(tech)                                   CO2 feedstock input (Mt per PJ)
CO2price(year)                                   CO2 feedstock price (Mio EUR per Mt)
H2input(year,tech)                               H2 feedstock input (PJ per PJ)
H2Max(year,market)                               Maximal H2 share development in each sector
CH4Max(year,market)                              Maximal CH4 share development in each sector
LCH4Max(year,market)                             Maximal LCH4 (LNG) share development in each sector
CO2source(year)                                  CO2 feedstock maximum source (Mt)
ghgEmisFeed(year,feedCrop)                    ktCO2eq per PJ
ghgEmisT1(year)                                  ktCO2eq per PJ
ghgEmisGateWheel(year,tech)                      ktCO2eq per PJ
powerMixEmis(year)                               ktCO2eq per PJ
ghgRef(year,market)                              ktCO2eq per PJ
historicFuelDemand(year,fuel)                    Fuel demand development constraint based on past fleet
*newICEVPJ(year)                                  yearly new ICEV fuel demand (PJ)
newVehicSharePass(year)                          share of new vehicles yearly in the passenger road sector
residualLoad(d,year)                             residualLoad
posResLoad(d,year)                               positive residual load = demand for dispatchable power
vehicleKMroadTot                                 total vehicle km in passenger road sector
MJperKMavgICEV                                   fuel economy baseline passenger road sector
relativeFuelEconomy(tech,market)                 relative fuel economy between fuels in passenger road sector
*vehicleCostPerGJfuel(year,tech)                  average vehicle cost per GJ fuel input for each fuel tech (passenger road sector)
returnStat(stat);
;

$loadR costMarg, costInv, costInvLevel, capF, cap0, demand, landDmdPJ, landMax, cropLandUseInit, convEta, convEtaBiomSpec, bioResPot
$loadR bioResPotImport, feedPrice, feedPriceImport, resImportMax, heatByprod, lifeT, powerPrice, powerInput
$loadR heatInput, heatPrice, ghgEmisFeed, ghgEmisT1, ghgEmisGateWheel, powerMixEmis, ghgRef, historicFuelDemand
$loadR residualLoad, CO2input, H2input, CO2source, CO2price, ghgTarget, dMax, H2Max, CH4Max, LCH4Max, ghgRefCO2
$loadR newVehicSharePass, pwrMixMax, vehicleKMroadTot, MJperKMavgICEV, relativeFuelEconomy, posResLoad, solveOption
*newICEVPJ, vehicleCostPerGJfuel,

$gdxin

FREE VARIABLES
cost                                             Total system cost (M EUR)
costAnnual                                       Total system cost (M EUR annually)
costImportAnnual                                 Total system cost import fuel and power (annual)
prodMinusImportAnnual                            Total production minus imports (annual)
ghgAbatement                                     Total GHG abatement (ktCO2eq)
ghgAbateTech(year,tech)                          technology GHG abatement (ktCO2eq per year)

POSITIVE VARIABLES
inst(year,tech)                                  new installed capacity [GW]
deco(year,tech)                                  capacity decommission [GW]
cap(year,tech)                                   capacity [GW]
capNew(year,tech)                                endogenously installed standing capacity [GW]
prd(year,tech,market)                            production      (PJ)
prdDaily(year,d,tech,market)                     dispatchable power production (PJ)
feedUse(year,tech,feed,cat)                      feed used (PJ)
residualLoadUse(d,year)                          residualLoad use
dispatchPrd(d,year)                              dispatchable power production
CO2use(year)                                     CO2 used (Mton)
powerUseDaily(year,d,tech,feed)                  power used daily (PJ)
feedUseImport(year,tech,feed)                    feed import used (PJ)
transportFuelDemand(year,market,fuel)            total transport fuel demand development
newVehicles(year,market,fuel)                    new vehicle fuel demand development (PJ)
vehiclePark(year,market,fuel)                    vehicle park demand per fuel (PJ)
decomVehicles(year,market,fuel)                  vehicle fuel type decommission (PJ)
costTech(year,tech)                              technology cost incl CAPEX and OPEX (M EUR per year)
capFout(year,tech)                               capacity factor resulting from prd per cap
;

* Capacity in starting year and installations ramps
cap.fx('2020',tech)                                                              = cap0('2020',tech);
inst.up(year,tech)                                                               = rampC_GW;
inst.fx('2020',tech)                                                             = 0;
capNew.fx('2020',tech)                                                           = 0;

vehiclePark.fx('2020',passenger,fuel)                                          = historicFuelDemand('2020',fuel);
*vehiclePark.fx('2020',market,fuel) $(not passenger(market))                      = 0;
newVehicles.up(year,passenger,fuel)                                            = rampC;
newVehicles.fx('2020',market,fuel)                                               = 0;

*forbids certain Technologies on certain markets
prd.fx(year,tech,market) $ (not TS(tech,market))=0;
prd.fx(year,tech,"CONVth")=0;

*prd.fx('2020',techH2,market)=0;
*prd.fx('2020',techLNG,market)=0;
prd.fx('2020',techCH4fuel,market) $ (not passenger(market))=0;

*forbids certain technologies to use certain feed
feedUse.fx(year,tech,feed,cat) $ (not TB(tech,feed))=0;
feedUseImport.fx(year,tech,feed) $ (not TB(tech,feed))=0;
powerUseDaily.fx(year,d,tech,feed) $ (not TB(tech,feed))=0;


*Sets deco=0 before any lifetime reduction happens
deco.fx(t,tech) $ (ord(t)<=(lifeT(tech)))=0;


EQUATION
capexp                   capacity expansion
capexpnew                new installed standing capacity

capdeco                  capacity decommission
prdLim                   production limit
prdCH4inter              production limit for CH4
prdH2inter               production limit for CH4
instRamp                 installation ramp limit
prdRamp                  production ramp limit
prdRamp2                  production ramp limit

prdfeed               feed use for production
bioResLim                feed residue limitation - seperated into card(cat) categories for pricing of feed potential
CO2Lim1                   CO2 feedstock source limitation
CO2Lim2                   CO2 feedstock source limitation

powerResLim              surplus power available is more than used surplus power in each time point
powerResLim2             connects the feed matrix (which sets dependecies) to powerRes
powerResLim3             sum of all surplus power use equals the used surplus power
powerResLimDay           capacity limitation of power use in each time point

powerMixLim              power mix limit for hydrogen production

bioResLimImport          import feed residue limitation
landUse                  total land use limit
landUse2                 land use categorization for prizing
ImportLimit              ImportLimit for Importfeed

landUseInit              Land use initially
landUseRes               Land Use may maximal be increased by factor landF

demLim                   Demand limit
demLimCONVth             Demand limit for CONVth
demLimCONVel             Demand limit for CONVel
demLimPass               Demand limit for passenger road sector (vehicle-km)
*demLimFreight            Demand limit for freight transport
demLimH2                 Demand limit for H2 in each sector
demLimCH4                Demand limit for CH4 in each sector
demLimLCH4               Demand limit for LCH4 in each sector

demLimPowerDispatch1      Demand limit for dispatchable power
demLimPowerDispatch      Demand limit for dispatchable power
demLimPowerDispatch2     Demand limit for dispatchable power
demLimPowerDispatch3     Demand limit for dispatchable power
demLimPowerDispatch4     Demand limit for dispatchable power

fuelLimitDiesel          Demand limit for fuels (passenger)
fuelLimitEtOH            Demand limit for fuels (passenger)
fuelLimitCH4             Demand limit for fuels (passenger)
fuelLimitH2              Demand limit for fuels (passenger)
fuelLimitEV              Demand limit for fuels (passenger)

vehicleExpRamp           Vehicle fuel type expansion ramp
vehicleParkDev           Total fuel type vehicle park development
decomVehiclesDev         Vehicle decommissioning
newVehicleLimit

vehicleExpRampAllCH4
vehicleExpRampAllLNG
vehicleExpRampAllH2

costTechEq               technology cost incl. feed and levelized investment yearly (M EUR)
GHGabateTechEq           technology GHG abatement yearly (ktCO2eq)

totCost                  total cost
totCostAnnual            total cost (annual)
totGHGabate              total GHG abatement

ghgLim                   ghg target
;

capexp(t+1,tech)..                       cap(t+1,tech)                           =E=   cap(t,tech)+inst(t+1,tech)-cap0(t,tech)+cap0(t+1,tech)-deco(t+1,tech);
capexpnew(t+1,tech)..                    capNew(t+1,tech)                        =E=   capNew(t,tech)+inst(t+1,tech)-deco(t+1,tech);

capdeco(t+lifeT(tech),tech)..            deco(t+lifeT(tech),tech)                =E=   inst(t,tech);
*prdLim(t,tech)..                         cap(t,tech)*capF(t,tech)       =G=   sum(market,prd(t,tech,market));
prdLim(t,tech)..                         cap(t,tech)*capF(t,tech)*8760*3.6/1000       =G=   sum(market,prd(t,tech,market));


prdCH4inter(t)..             sum((CH4market,tech),prd(t,tech,CH4market))         =E=   sum((market,techCH4in),prd(t,techCH4in,market)/convEta(t,techCH4in));
*prdH2inter(t)..              sum((H2market,tech),prd(t,tech,H2market))           =E=   sum((market,techH2in),prd(t,techH2in,market)/convEta(t,techH2in))
*                                                                                         +sum((market,tech),prd(t,tech,market)*H2input(t,tech));
prdH2inter(t)..              sum((H2market,tech),prd(t,tech,H2market))           =E=   sum((market,tech),prd(t,tech,market)*H2input(t,tech));

instRamp(t+1,tech)..                     inst(t+1,tech)                          =L=   rampMinGW+rampF*cap(t,tech);
prdRamp(t+1,tech,market)..               prd(t+1,tech,market)                    =L=   rampMin+(1+rampF)*prd(t,tech,market);
prdRamp2(t+1,tech)..                     sum(market,prd(t+1,tech,market))        =L=   rampMin+(1+rampF)*sum(market,prd(t,tech,market));
*prdRamp2(t+1,techLNG)..                  sum(ship,prd(t+1,tech,market))        =L=   rampMin+(1+rampF)*sum(market,prd(t,tech,market));


prdfeed(t,tech)$ (not techInter(tech)) ..   sum(market,prd(t,tech,market))    =E=   sum((feed,cat),feedUse(t,tech,feed,cat)*convEtaBiomSpec(t,feed,tech))
                                                                                           +sum(feed,feedUseImport(t,tech,feed)*convEtaBiomSpec(t,feed,tech));

bioResLim(t,feedResidue,cat)..        bioResPot(t,feedResidue)/card(cat)   =G=   sum(tech,feedUse(t,tech,feedResidue,cat));
bioResLimImport(t,feed)..             bioResPotImport(t,feed)              =G=   sum(tech,feedUseImport(t,tech,feed));

CO2Lim1(t)..                              CO2use(t)                              =E=   sum((tech,market),prd(t,tech,market)*CO2input(tech));
CO2Lim2(t)..                              CO2source(t)                           =G=   CO2use(t);



powerResLim(d,t)..                       residualLoad(d,t)                       =G=   residualLoadUse(d,t);
powerResLim2(t,powerRes)..               sum((tech,cat),feedUse(t,tech,powerRes,cat)) =E=   sum((d,tech),powerUseDaily(t,d,tech,powerRes));
powerResLim3(d,t)..                      residualLoadUse(d,t)                    =E=   sum((tech,powerRes),powerUseDaily(t,d,tech,powerRes));
powerResLimDay(t,d,tech,powerRes)..      cap(t,tech)*8760*3.6/1000/dMax          =G=   powerUseDaily(t,d,tech,powerRes)*convEta(t,tech);


demLimPowerDispatch1(d,t)..              posResLoad(d,t)                         =G=   dispatchPrd(d,t);
demLimPowerDispatch(t,d,tech)..          cap(t,tech)*8760*3.6/1000/dMax                        =G=   prdDaily(t,d,tech,'CONVel');
*demLimPowerDispatch(t,d,tech)..          cap(t,tech)/dMax                        =G=   prdDaily(t,d,tech,'CONVel');
demLimPowerDispatch3(d,t)..              dispatchPrd(d,t)                        =E=   sum((tech),prdDaily(t,d,tech,'CONVel'));
demLimPowerDispatch2(t)..                demand(t,"CONVel")                      =G=   sum((tech,d),prdDaily(t,d,tech,'CONVel'));
demLimPowerDispatch4(t,tech)..           prd(t,tech,"CONVel")                    =E=   sum(d,prdDaily(t,d,tech,'CONVel'));


*powerResLimDay(t,d,tech,powerRes)..      cap(t,tech)*(capF(t,tech)/dMax)/convEta(t,tech)  =G=   powerUseDaily(t,d,tech,powerRes);

powerMixLim(t)..                         pwrMixMax                               =G=   sum((tech,powerMix,cat),feedUse(t,tech,powerMix,cat));

landUse(t)..                             landMax(t)                              =G=   sum((tech,feedCrop,cat),landDmdPJ(t,feedCrop)*feedUse(t,tech,feedCrop,cat));
landUse2(t,feedCrop,cat)..            landMax(t)/card(cat)                    =G=   sum(tech,landDmdPJ(t,feedCrop)*feedUse(t,tech,feedCrop,cat));
ImportLimit(t)..                         resImportMax(t)                         =G=   sum((tech,feed),feedUseImport(t,tech,feed));

landUseInit(feedCrop)..               cropLandUseInit(feedCrop)            =G=   sum((tech,cat),landDmdPJ('2020',feedCrop)*feedUse('2020',tech,feedCrop,cat));
landUseRes(t+1,feedCrop)..            sum((tech,cat),landDmdPJ(t+1,feedCrop)*feedUse(t+1,tech,feedCrop,cat))  =L=   landMin+(1+landF)*sum((tech,cat),landDmdPJ(t,feedCrop)*feedUse(t,tech,feedCrop,cat));



demLim(t,market) $ (not (marketCONV(market) and CH4market(market) and H2market(market)))..
     demand(t,market)   =G=   sum(tech,relativeFuelEconomy(tech,market)*prd(t,tech,market)*heatByprod(t,tech));


*demLim(t,market) $ (not marketCONV(market)).. demand(t,market)                 =G=   sum(tech,prd(t,tech,market)*heatByprod(t,tech));
*demLimFreight(t,market) $ (goods(market))..   demand(t,market)                   =G=   sum(tech,relativeFuelEconomy(tech)*prd(t,tech,market));
*demLimMaritime(t,market) $ (ship(market))..   demand(t,market)                   =G=   sum(tech,relativeFuelEconomy(tech)*prd(t,tech,market));
demLimPass(t,market) $ (passenger(market))..  vehicleKMroadTot(t)                =G=   sum(tech,relativeFuelEconomy(tech,market)*prd(t,tech,market)*heatByprod(t,tech)/MJperKMavgICEV(t));
demLimCONVth(t)..                             demand(t,"CONVth")                 =G=   sum(techCONVth,prd(t,techCONVth,"CONVel")*heatByprod(t,techCONVth));
demLimCONVel(t)..                             demand(t,"CONVel")                 =G=   sum(tech,prd(t,tech,"CONVel"))+prd(t,"BioCH4_el","INDth")+prd(t,"Gasif_s","HHth");


*demLimPass(t,market) $ (passenger(market))..  demand(t,market)                   =G=   sum(tech,fuelEconomy(tech)*prd(t,tech,market)*heatByprod(t,tech));

vehicleExpRamp(t+1,passenger,fuel)..   newVehicles(t+1,passenger,fuel)           =L=   rampMinVehicles+rampFvehicles*vehiclePark(t,passenger,fuel);

vehicleParkDev(t+1,passenger,fuel)..   vehiclePark(t+1,passenger,fuel)           =E=   vehiclePark(t,passenger,fuel)+newVehicles(t+1,passenger,fuel)
                                                                                       -historicFuelDemand(t,fuel)+historicFuelDemand(t+1,fuel)-decomVehicles(t+1,passenger,fuel);
decomVehiclesDev(t+lifeTvehicles,passenger,fuel)..    decomVehicles(t+lifeTvehicles,passenger,fuel)   =E=   newVehicles(t,passenger,fuel);

newVehicleLimit(t,passenger)..   sum(fuel,newVehicles(t,passenger,fuel))         =L=   newVehicSharePass(t)*MJperKMavgICEV(t)*vehicleKMroadTot(t);

fuelLimitDiesel(t,passenger)..    sum(techDiesel(tech), prd(t,tech,passenger))   =L=     sum(fuel,vehiclePark(t,passenger,'Diesel'));
fuelLimitEtOH(t,passenger)..      sum(techEtOH(tech),   prd(t,tech,passenger))   =L=     sum(fuel,vehiclePark(t,passenger,'EtOH'));
fuelLimitCH4(t,passenger)..       sum(techCH4fuel(tech),prd(t,tech,passenger))   =L=     sum(fuel,vehiclePark(t,passenger,'CH4'));
fuelLimitH2(t,passenger)..        sum(techH2(tech),     prd(t,tech,passenger))   =L=     sum(fuel,vehiclePark(t,passenger,'H2'));
fuelLimitEV(t,passenger)..        sum(techEV(tech),     prd(t,tech,passenger))   =L=     sum(fuel,vehiclePark(t,passenger,'Electric'));

demLimH2(t,market)..                          demand(t,market)*H2Max(t,market)   =G=     sum(techH2,prd(t,techH2,market));
demLimCH4(t,market)..                         demand(t,market)*CH4Max(t,market)  =G=     sum(techCH4fuel,prd(t,techCH4fuel,market));
demLimLCH4(t,market)..                        demand(t,market)*LCH4Max(t,market) =G=     sum(techLNG,prd(t,techLNG,market));


vehicleExpRampAllH2(t+1,market) $ (not H2market(market))..  sum(techH2, prd(t+1,techH2,market))  =L=   rampMin+(1+rampFvehicles)*sum(techH2, prd(t,techH2,market));
vehicleExpRampAllLNG(t+1,market)..  sum(techLNG, prd(t+1,techLNG,market))           =L=   rampMin+(1+rampFvehicles)*sum(techLNG, prd(t,techLNG,market));
vehicleExpRampAllCH4(t+1,market) $ (not passenger(market) or CH4market(market))..  sum(techCH4fuel, prd(t+1,techCH4fuel,market))           =L=   rampMin+(1+rampFvehicles)*sum(techCH4fuel, prd(t,techCH4fuel,market));

costTechEq(t,tech)..                      costTech(t,tech)     =E=   sum(market,(costMarg(t,tech)+powerInput(tech)*powerPrice(t,tech)+heatInput(tech)*heatPrice(t)+CO2input(tech)*CO2price(t))*prd(t,tech,market))
                                                      + capNew(t,tech)*costInvLevel(t,tech)
*                                                      + vehicleCostPerGJfuel(t,tech)
                                                      + sum((feed,cat),feedUse(t,tech,feed,cat)*feedPrice(t,feed,cat))
                                                      + sum(feed,feedUseImport(t,tech,feed)*feedPriceImport(t,feed));
*                                                      + sum((market),prd(t,tech,market)*H2input(time,tech));

totCost..                                cost     =E=   sum((t,tech,market),(costMarg(t,tech)+powerInput(tech)*powerPrice(t,tech)+heatInput(tech)*heatPrice(t)+CO2input(tech)*CO2price(t))*prd(t,tech,market))
                                                      + sum((t,tech),capNew(t,tech)*costInvLevel(t,tech))
                                                      + sum((t,tech,feed,cat),feedUse(t,tech,feed,cat)*feedPrice(t,feed,cat))
                                                      + sum((t,tech,feed),feedUseImport(t,tech,feed)*feedPriceImport(t,feed));
*                                                      + sum((t,techPel,feed,cat),feedUse(t,techPel,feed,cat)*5);

GHGabateTechEq(t,tech)..                  ghgAbateTech(t,tech)  =E=     sum(market,prd(t,tech,market)*(ghgRef(t,market)*relativeFuelEconomy(tech,market)-ghgEmisGateWheel(t,tech)))
                                                         -       sum((feedCrop,cat),feedUse(t,tech,feedCrop,cat)*(ghgEmisFeed(t,feedCrop)+ghgEmisT1(t)))
                                                         -       sum((feedResidue,cat),feedUse(t,tech,feedResidue,cat)*ghgEmisT1(t))
                                                         -       sum((powerMix,cat),feedUse(t,tech,powerMix,cat)*powerMixEmis(t))
                                                         -       sum((market),prd(t,tech,market)*CO2input(tech)*ghgRefCO2);

totGHGabate..                        ghgAbatement  =E=     sum((t,tech,market),prd(t,tech,market)*(ghgRef(t,market)*relativeFuelEconomy(tech,market)-ghgEmisGateWheel(t,tech)))
                                                         -       sum((t,tech,feedCrop,cat),feedUse(t,tech,feedCrop,cat)*(ghgEmisFeed(t,feedCrop)+ghgEmisT1(t)))
                                                         -       sum((t,tech,feedResidue,cat),feedUse(t,tech,feedResidue,cat)*ghgEmisT1(t))
                                                         -       sum((t,tech,powerMix,cat),feedUse(t,tech,powerMix,cat)*powerMixEmis(t))
                                                         -       sum((t,tech,market),prd(t,tech,market)*CO2input(tech)*ghgRefCO2);

ghgLim..                             ghgAbatement  =G=   ghgTarget;


totCostAnnual(t)..                       costAnnual(t)  =E=   sum((tech,market),(costMarg(t,tech)+powerInput(tech)*powerPrice(t,tech)+heatInput(tech)*heatPrice(t))*prd(t,tech,market))
                                                      + sum((tech),costInvLevel(t,tech)*cap(t,tech))
                                                      + sum((tech,feed,cat),feedUse(t,tech,feed,cat)*feedPrice(t,feed,cat))
                                                      + sum((tech,feed),feedUseImport(t,tech,feed)*feedPriceImport(t,feed));
*                                                      + sum((techPel,feed,cat),feedUse(t,techPel,feed,cat)*5);

MODEL benopt /all/

*this option terminates the solver after X seconds
option Reslim=45000;
*option iterlim = 10000
option LP=cplex;
*set epmrk /0.3/;
*set epopt /1e-005/;
*set epper /1e-004/
*set feasopt /1/
*turning off scaling
* this creates a option file on the fly
*$onecho > cplex.opt
*scaind=-1
*$offecho
* this tells GAMS to use the option file
*benopt.optfile=1;

if (solveOption=1,
         SOLVE benopt using lp minimizing cost;
elseif solveOption=0,
         SOLVE benopt using lp maximizing ghgAbatement;
);


*returnStat('solvestat') = benopt.solvestat;
returnStat('modelstat') = benopt.modelstat;


Display prd.l,inst.l,deco.l,cap.l,cost.l,feedUse.l,deco.l,feedUseImport.l,
newVehicles.l,vehiclePark.l,CO2use.l,powerUseDaily.l,residualLoadUse.l,prdDaily.l,dispatchPrd.l,returnStat;

*execute_unload %matout%;
