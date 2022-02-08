clear all; clc
pkg load symbolic
fn='OctLatexDoc';  	% Put the name (WITHOUT extension) of your symolic/Latex script
SHOW=false;			% true->shows (false->doesn't show) the produced Latex code 

%==========================================================================
% INITIALIZATION
fin=[fn '.m'];
fout=[fn '.tex'];

fid1=fopen(fin,'r');
fid2=fopen(fout,'w');

%==========================================================================
% RUN YOUR SYMBOLIC/LATEX SCRIPT
run([fn '.m'])

%==========================================================================
% GENERATE LATEX

qS=whos;
qj=0;
for qi=1:length(qS)
	if OLContains(qS(qi).class,'sym')>0
		qj=qj+1;
		qRepCom(qj).str=['latex(' qS(qi).name ')'];
		qRepCom(qj).str= ['tline=strrep(tline,''latex(' qS(qi).name ')'',latex(' qS(qi).name '));'];
	end
	if OLContains(qS(qi).class,'double')>0 && qS(qi).size==[1 1]
		qj=qj+1;
		qRepCom(qj).str=['num2str(' qS(qi).name ')'];
		qRepCom(qj).str= ['tline=strrep(tline,''num2str(' qS(qi).name ')'',num2str(' qS(qi).name '));'];
	end
	if OLContains(qS(qi).name,'FIG')>0
		qj=qj+1;
		qRepCom(qj).str=['figure(' qS(qi).name '-inc)'];
		qRepCom(qj).str= ['tline=strrep(tline,''figure(' qS(qi).name '-inc)'',',['''' qS(qi).name '-inc'''] ');'];
	end
end
qRepLen=qj;

str1="";
while ~feof(fid1)
    tline = fgetl(fid1);
    qn=length(tline);
    if qn>1
        aa=tline(1:2);
        if aa=='%%'
            str1=[str1 newline tline(3:qn)];
        end
    end
end

tline=str1;
for qj=1:qRepLen
	eval(qRepCom(qj).str);
end
tline=strrep(tline,'\','\\');
if SHOW; disp(tline); end
fprintf(fid2,tline);

fclose(fid1);
fclose(fid2);

system(['pdflatex ' fout])

