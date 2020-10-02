# BENOPT
BENOPT is a deterministic, recursive, bottom-up, perfect foresight, linear optimisation model for modelling cost-optimal and/or GHG abatement optimal allocation of renewable energy carriers across power, heat and transport sectors. The sectors are further divided into sub-sectors. The model has an up to hourly resolution, which can be aggregated depending on the task. The model has been developed in Matlab and GAMS and requires both installed. The CPLEX solver is used as a standard for solving the LP problem, but other LP solvers may work as well.

The model includes modules for crop price developments (based on the premise that farmers want to achieve the same profit regardless of the crop grown), automatic GHG emission and cost calculations based on input-output, opex and capex data, and it has been hard coupled with a VRE module. Some 30+ technologies with 20+ biomass residues and crop types, which can be used across 10+ sub-sectors enable a myriad of biomass pathway options, which can be easily extended. PtX based on the power mix or excess electricity is included with numerous usage pathways, such as hydrogen, EVs or heat pumps. The whole pathway from source to end use service is captured across all energy sectors, allowing a systems perspective. Thanks to short run-times, extensive sensitivity analyses can be performed.

The model is developed for:
* System modelling across energy and bioeconomy sectors with a high detail on biomass crops and conversion pathways, as well as on power-to-X/electrofuels.
* Analysis throughout the entire biomass and renewable energy carrier supply chain, using a systems perspective

Main research question assessed:
* What role could/should biomass and other renewable energy options play within the energy system transformation process in order to achieve climate targets in the most cost- and GHG-optimal way, and how can conflicting targets be quantified?

Two goal functions can be used or combined: greenhouse gas (GHG) abatement or cost minimisation for fulfilling set energetic or GHG targets. In combination, pareto analyses can be performed.

BENOPT contains sectors for transport (road passenger, road goods, shipping and aviation), power and heat (industry, household and commercial). The model functions on a yearly resolution (with the exception of surplus power usage, which can be broken down to an hourly resolution) and is not spatially explicit. Detailed input-output, capex and opex data are integrated for feedstocks, conversion and supply, which allows detailed cost analyses and combined with relevant emission factors also GHG analyses.

The models are also used to investigate the sensitivity of the developments by means of various methods (Monte Carlo, SOBOL), on which a large number of parameters have an influence, especially in the complex area of biomass use.

Running
=======
`main.m` is the main file of the model, where data is read, variables set and from which the other modules are called and the optimization module in GAMS is executed. Data can be changed in the excel file and some variables are set and can be changed in 'setData.m'.

Licence
=======

Copyright 2017-2020 Markus Millinger, Philip Tafarte, Matthias Jordan, Frazer Musonda


This program is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either `version 3 of the
License <LICENSE.txt>`, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
`GNU General Public License <LICENSE.txt>` for more details.
