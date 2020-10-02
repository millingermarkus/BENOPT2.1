%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BENOPT (BioENergy OPTimisation model)
%     Copyright (C) 2012-2020 Markus Millinger, Philip Tafarte
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
% Scaling of capacity factor of solar PV and on- and offshore wind

function [genDataScaled,capFacInst]    =   scalingCapFacVRE(capData,genData,capFac)

if capData==0 %to avoid division by zero
    capData=0.00001*ones(8760,1);
end

ScaleFactor             =   1;
capFacVar               =   sum(genData./capData)/length(genData);
capFacInst              =   genData./capData;

while capFacVar < capFac
    index                   =   capFacInst<1;
    genData(index)          =   min(genData(index).*ScaleFactor,capData(index));
    ScaleFactor             =   ScaleFactor+0.001;
    capFacInst              =   genData./capData;
    capFacVar               =   sum(genData./capData)/length(genData);
end

genDataScaled               =   genData;
end