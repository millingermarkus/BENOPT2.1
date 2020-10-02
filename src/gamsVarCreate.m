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
% Creation of GAMS variables
%

function gamsVarOut   =   gamsVarCreate(name,inputVar,x,y,z,type)
% gamsVarOut  =   gamsVarIn;
% gamsVarOut(end+1)  =   setfield(name,name);
% inputVar
if contains(type,'param')
    if isnumeric(x)
        x   =   strsplit(num2str(x));
    end
    if isnumeric(y)
        y   =   strsplit(num2str(y));
    end
    if isnumeric(z)
        z   =   num2str(z);
    end
    gamsVarOut.name = name;
    gamsVarOut.type = 'parameter';
    gamsVarOut.form = 'full';
    gamsVarOut.val  = inputVar;
    
    if isequal(size(y),[1 1])  %if y is not a vector, make uels one dimensional
        gamsVarOut.uels = {x};
    elseif isequal(size(z),[1 1]) %if z is not a vector, make uels two dimensional
        gamsVarOut.uels = {x, y};
    else
        gamsVarOut.uels = {x, y, z};
    end

elseif contains(type,'set')
    gamsVarOut.name           =   name;
    gamsVarOut.type           =   'set';
    if isequal(size(inputVar),[1 1])==0
        gamsVarOut.val        =   inputVar;
    end
    
        if isequal(size(y),[1 1])  %if y is not a vector, make uels one dimensional
            gamsVarOut.uels = {x};
        elseif isequal(size(z),[1 1]) %if z is not a vector, make uels two dimensional
            gamsVarOut.uels = {x, y};
            gamsVarOut.form = 'full';
        else
            gamsVarOut.uels = {x, y, z};
            gamsVarOut.form = 'full';
        end
    
    
elseif contains(type,'scalar')
    gamsVarOut.name = name;
    gamsVarOut.type = 'parameter';
    gamsVarOut.val  = inputVar;
end


end
