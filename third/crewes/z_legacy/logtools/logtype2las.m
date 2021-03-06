function [mnem,name]=logtype2las(itype)
% [mnem,name]=logtype2las(itype)
% 
% Convert a numeric logtype, as generated by LAS2LOGTYPE, to a 4 letter 
% las mnemonic identifying a log.
% The master list of possible numeric logtypes is to be found in
% the source for las2logtype.m
% Calling the function with no arguments returns a matrix of the 
% currently supported mnemonics, and a matrix of the corresponiong long
% names, one per line. Each mnemonic is 4 chars.
%
% As of Dec 7, 1995, these were:
% -1 ... unknown or un-specified
% 0  ... p-wave sonic
% 1  ... bulk density
% 2  ... formation denisty
% 3  ... apparent density
% 4  ... gamma ray
% 5  ... spontaneous potential
% 6  ... caliper
% 7  ... s-wave sonic
% 8  ... neutron porosity
% 9  ... apparent porosity
% 10 ... porosity density ???
% 11 ... porosity effective
% 12 ... porosity total
% 13 ... focussed resistivity
% 14 ... medium induction
% 15 ... deep induction
% 16 ... SFL resistivity
% 17 ... mel caliper
% 18 ... micronormal
% 19 ... microinverse
% 20 ... porosity density (SS)
% 21 ... Poissons ratio
% 22 ... VP/VS ratio
% 23 ... Youngs Modulus
% 24 ... Lames Lamda Constant
% 25 ... Lames Rigidity
% 26 ... Bulk Modulus
% 27 ... P-wave velocity
% 28 ... S-wave velocity
% 29 ... S-wave from array sonic
% 30 ... P-wave from array sonic
% 31 ... Gamma ray density
% 32 ... Gamma ray porosity
% 33 ... Photoelectric cross section
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.

% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by
% its 'AUTHOR' (identified above) and the CREWES Project.  The CREWES
% project may be contacted via email at:  crewesinfo@crewes.org
%
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) This SOFTWARE may be used by any individual or corporation for any purpose
%    with the exception of re-selling or re-distributing the SOFTWARE.
%
% 2) The AUTHOR and CREWES must be acknowledged in any resulting publications or
%    presentations
%
% 3) This SOFTWARE is provided "as is" with no warranty of any kind
%    either expressed or implied. CREWES makes no warranties or representation
%    as to its accuracy, completeness, or fitness for any purpose. CREWES
%    is under no obligation to provide support of any kind for this SOFTWARE.
%
% 4) CREWES periodically adds, changes, improves or updates this SOFTWARE without
%    notice. New versions will be made available at www.crewes.org .
%
% 5) Use this SOFTWARE at your own risk.
%
% END TERMS OF USE LICENSE
ntypes=35;
names_mtx=32*ones(ntypes,30);
mnem_mtx=32*ones(ntypes,4);
iitype=-1;
mnem_mtx(iitype+2,:)='UNKN';
name='Unknown';
names_mtx(iitype+2,1:length(name))=name;
iitype=0;
mnem_mtx(iitype+2,:)='SON ';
name='P-wave Sonic';
names_mtx(iitype+2,1:length(name))=name;
iitype=1;
mnem_mtx(iitype+2,:)='RHOB';
name='Bulk Density';
names_mtx(iitype+2,1:length(name))=name;
iitype=2;
mnem_mtx(iitype+2,:)='RHGF';
name='Formation Density';
names_mtx(iitype+2,1:length(name))=name;
iitype=3;
mnem_mtx(iitype+2,:)='RHGA';
name='Apparent Density';
names_mtx(iitype+2,1:length(name))=name;
iitype=4;
mnem_mtx(iitype+2,:)='GRC ';
name='Gamma Ray';
names_mtx(iitype+2,1:length(name))=name;
iitype=5;
mnem_mtx(iitype+2,:)='SP  ';
name='Spontaneous Potential';
names_mtx(iitype+2,1:length(name))=name;
iitype=6;
mnem_mtx(iitype+2,:)='CALI';
name='Caliper';
names_mtx(iitype+2,1:length(name))=name;
iitype=7;
mnem_mtx(iitype+2,:)='SSON';
name='S-wave Sonic';
names_mtx(iitype+2,1:length(name))=name;
iitype=8;
mnem_mtx(iitype+2,:)='NPHI';
name='Neutron Porosity';
names_mtx(iitype+2,1:length(name))=name;
iitype=9;
mnem_mtx(iitype+2,:)='PHIA';
name='Apparent Porosity';
names_mtx(iitype+2,1:length(name))=name;
iitype=10;
mnem_mtx(iitype+2,:)='PHID';
name='Porosity Density';
names_mtx(iitype+2,1:length(name))=name;
iitype=11;
mnem_mtx(iitype+2,:)='PHIE';
name='Porosity Effective';
names_mtx(iitype+2,1:length(name))=name;
iitype=12;
mnem_mtx(iitype+2,:)='PHIT';
name='Porosity Total';
names_mtx(iitype+2,1:length(name))=name;
iitype=13;
mnem_mtx(iitype+2,:)='SFLU';
name='Focussed Resistivity';
names_mtx(iitype+2,1:length(name))=name;
iitype=14;
mnem_mtx(iitype+2,:)='ILM ';
name='Medium Induction';
names_mtx(iitype+2,1:length(name))=name;
iitype=15;
mnem_mtx(iitype+2,:)='ILD ';
name='Deep Induction';
names_mtx(iitype+2,1:length(name))=name;
iitype=16;
mnem_mtx(iitype+2,:)='SFLR';
name='SFL Resistivity';
names_mtx(iitype+2,1:length(name))=name;
iitype=17;
mnem_mtx(iitype+2,:)='UNVI';
name='Mel Caliper';
names_mtx(iitype+2,1:length(name))=name;
iitype=18;
mnem_mtx(iitype+2,:)='MNOR';
name='Micro Normal';
names_mtx(iitype+2,1:length(name))=name;
iitype=19;
mnem_mtx(iitype+2,:)='MINV';
name='Micro Inverse';
names_mtx(iitype+2,1:length(name))=name;
iitype=20;
mnem_mtx(iitype+2,:)='DPSS';
name='Porosity Density SS';
names_mtx(iitype+2,1:length(name))=name;
iitype=21;
mnem_mtx(iitype+2,:)='POIS';
name='Poissons Ratio';
names_mtx(iitype+2,1:length(name))=name;
iitype=22;
mnem_mtx(iitype+2,:)='VPVS';
name='VP/VS Ratio';
names_mtx(iitype+2,1:length(name))=name;
iitype=23;
mnem_mtx(iitype+2,:)='YNGM';
name='Youngs Modulus';
names_mtx(iitype+2,1:length(name))=name;
iitype=24;
mnem_mtx(iitype+2,:)='LMDA';
name='Lames Lamda';
names_mtx(iitype+2,1:length(name))=name;
iitype=25;
mnem_mtx(iitype+2,:)='RIDG';
name='Lames Rigidity';
names_mtx(iitype+2,1:length(name))=name;
iitype=26;
mnem_mtx(iitype+2,:)='BMOD';
name='Bulk Modulus';
names_mtx(iitype+2,1:length(name))=name;
iitype=27;
mnem_mtx(iitype+2,:)='VP  ';
name='P-wave Velocity';
names_mtx(iitype+2,1:length(name))=name;
iitype=28;
mnem_mtx(iitype+2,:)='VS  ';
name='S-wave Velocity';
names_mtx(iitype+2,1:length(name))=name;
iitype=29;
mnem_mtx(iitype+2,:)='ASSW';
name='S-wave array sonic';
names_mtx(iitype+2,1:length(name))=name;
iitype=30;
mnem_mtx(iitype+2,:)='ASPW';
name='P-wave array sonic';
names_mtx(iitype+2,1:length(name))=name;
iitype=31;
mnem_mtx(iitype+2,:)='GRD ';
name='Gamma ray density';
names_mtx(iitype+2,1:length(name))=name;
iitype=32;
mnem_mtx(iitype+2,:)='GRP ';
name='Gamma ray porosity';
names_mtx(iitype+2,1:length(name))=name;
iitype=33;
mnem_mtx(iitype+2,:)='PEF ';
name='Photoelectric cross section';
names_mtx(iitype+2,1:length(name))=name;
if(nargin==1)
 if(itype>ntypes-2)
		itype=-1;
	end
	mnem=mnem_mtx(itype+2,:);
	mnem=char(mnem);
	name=names_mtx(itype+2,:);
	name=char(name);
	return;
else
	mnem=mnem_mtx;
	mnem=char(mnem);
	name=names_mtx;
	name=char(name);
	return
end