function [ modos its ] = myEEMD( x,Nstd,NR,MaxIter )
% EEMD was introduced in 
% Wu Z. and Huang N.
% "Ensemble Empirical Mode Decomposition: A noise-assisted data analysis method". 
% Advances in Adaptive Data Analysis. vol 1. pp 1-41, 2009.
%--------------------------------------------------------------------------
% The present EEMD implementation was used in
% M.E.TORRES, M.A. COLOMINAS, G. SCHLOTTHAUER, P. FLANDRIN,
%  "A complete Ensemble Empirical Mode decomposition with adaptive noise," 
%  IEEE Int. Conf. on Acoust., Speech and Signal Proc. ICASSP-11, pp. 4144-4147, Prague (CZ)
%
% Requires EMD_EEMD toolbox
% emd functions
%
%  OUTPUT
%   modos: contain the obtained modes in a matrix with the rows being the modes
%   its: contain the iterations needed for each mode for each realization
%
%  INPUT
%  x: signal to decompose
%  Nstd: noise standard deviation
%  NR: number of realizations
%  MaxIter: maximum number of sifting iterations allowed.

if ~exist('EMD_EEMD', 'dir')
    % add to path
    addpath('../EMD_EEMD');
end

% creat a collection of gaussian noise, same length of x, NR realizations
wi=Nstd.*randn(length(x), NR); 

% normalize input signal
xstd=std(x); % std of input signal
x=x/xstd; % normalize

% preallocation
MAXIMF=20;
mode=zeros(MAXIMF*NR, length(x)); % 100 is big for each realization
ort=zeros(NR,1);
its=zeros(NR, MaxIter);
IMF_count=zeros(NR,1);
% iterate on realizations
for i=1:NR
    xi=x+wi(:,i); % corrupt the input signal
    [ith_mode, ort(i), ith_iter]=emd(xi,'MAXITERATIONS',MaxIter); % EMD
    IMF_count(i)=size(ith_mode,1); % IMF count in each realizations
    % check if it exceeds MAXIMF
    if IMF_count(i)>MAXIMF
        disp('MAXIMF violated, please increase');
        break;
    end
    its(i,1:length(ith_iter))=ith_iter; % save iteration
    mode((i-1)*MAXIMF+(1:IMF_count(i)),:)=ith_mode; % save IMFs
    
end
max_IMF_count=max(IMF_count); % max IMFs

modos=zeros(max_IMF_count, length(x)); % mean of iterations

for i=1:max_IMF_count % calculate means
    NR_series=1:NR;
    modos(i,:)=mean(mode((NR_series-1)*MAXIMF+i,:),1);
end
if(max_IMF_count==1)
    its=0;
else
    its(:,max_IMF_count-1:end)=[];
end
modos=modos*xstd; % reverse back from normalization
end    


% desvio_estandar=std(x); % std of input signal
% x=x/desvio_estandar; % normalize
% xconruido=x+Nstd*randn(size(x)); % corrupt the input signal
% [modos, o, it]=emd(xconruido,'MAXITERATIONS',MaxIter);
% modos=modos/NR;
% iter=it;
% if NR>=2
%     for i=2:NR
%         xconruido=x+Nstd*randn(size(x));
%         [temp, ort, it]=emd(xconruido,'MAXITERATIONS',MaxIter);
%         temp=temp/NR;
%         lit=length(it);
%         [p liter]=size(iter);
%         if lit<liter
%             it=[it zeros(1,liter-lit)];
%         end;
%         if liter<lit
%             iter=[iter zeros(p,lit-liter)];
%         end;
%         
%         iter=[iter;it];
%         
%         [filas columnas]=size(temp);
%         [alto ancho]=size(modos);
%         diferencia=alto-filas;
%         if filas>alto
%             modos=[modos; zeros(abs(diferencia),ancho)];
%         end;
%         if alto>filas
%             temp=[temp;zeros(abs(diferencia),ancho)];
%         end;
%         
%         modos=modos+temp;
%     end;
% end;
% its=iter;
% modos=modos*desvio_estandar;


% end

