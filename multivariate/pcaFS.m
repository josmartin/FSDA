function out=pcaFS(Y,varargin)
%pcaFS performs Principal Component Analysis (PCA) on raw data.
%
%<a href="matlab: docsearchFS('pcaFS')">Link to the help function</a>
%
%   The main differences with respect to MATLAB function pca are:
%   1) accepts an input X also as table;
%   2) produces in table format the percentage of the variance explained
%      single and cumulative of the various components and the associated
%      scree plot in order to decide about the number of components to
%      retain.
%   3) returns the loadings in table format and shows them graphically.
%   4) provides guidelines about the automatic choice of the number of
%       components;
%   5) returns the communalities for each variable with respect to the
%       first k principal components in table format;
%   6) retuns the orthogonal distance ($OD_i$) of each observation to the PCA subspace.
%   For example, if the subspace is defined by the first two principal
%   components, $OD_i$ is computed as: 
%   \[
%   OD_i=|| z_i- V_{(2)} V_{(2)}' z_i ||
%   \]
%   where z_i is the i-th row of the original centered data matrix and
%   $V_{(2)}=(v_1 v_2)$ is the matrix of size px2 containing the first two
%   eigenvectors of $Z'Z/(n-1)$. The observations with large $OD_i$ are not well
%   represented in the space of the principal components.
%   7)  returns the score distance SD_i of each observation. For in the
%   case the subspace if the subspace is defined by the first two principal
%   components, $OD_i$ is computed as: 
%   \[
%   SD_i=\sqrt{(z_i'v_1)^2/l_1+ (z_i'v_2)^2/l_2 } 
%   \]
%  and $l_1$ and $l_2$ are the first two eigenvalues of $Z'Z/(n-1)$
%   8) calls app biplotFS which enables to obtain an interactive biplot in
%      which points, rowslabels or arrows can be shown or hidden. This app
%      also gives the possibility of controlling the length of the arrows
%      and the position of the row points through two interactive slider
%      bars. In the app it is also possible to color row points depending
%      on the orthogonal distance ($OD_i$) of each observation to the PCA
%      subspace. If optional input argument bsb or bdp is specified it is
%      possible to have in the app two tabs which enable the user to select
%      the breakdown point of the analysis of the subset size to use in the
%      svd. The units which are declared as outliers or the units outside
%      the subset are shown in the plot with filled circles.
%
%
%  Required input arguments:
%
% Y :           Input data. 2D array or table.
%               n x v data matrix; n observations and v variables. Rows of
%               Y represent observations, and columns represent variables.
%               Missing values (NaN's) and infinite values (Inf's) are
%               allowed, since observations (rows) with missing or infinite
%               values will automatically be excluded from the
%               computations.
%                Data Types - single|double
%
%  Optional input arguments:
%
%      bsb       : units forming subset on which to perform PCA. vector.
%                  Vector containing the list of the untis to use to
%                  compute the svd. The other units are projected in the
%                  space of the first two PC. bsb can be either a numeric
%                  vector of length m (m<=n) containin the list of the
%                  units (e.g. 1:50) or a logical vector of length n
%                  containing the true for the units which have to be used
%                  in the calculation of svd. For example bsb=true(n,1),
%                  bsb(13)=false; excludes from the svd unit number 13.
%                  Note that if bsb is supplied bdp must be empty.
%                 Example - 'bsb',[2 10:90 93]
%                 Data Types - double or logical 
%
%         bdp :  breakdown point. Scalar.
%               It measures the fraction of outliers the algorithm should
%               resist. In this case any value greater than 0 but smaller
%               or equal than 0.5 will do fine. Note that if bdp is
%               supplied bsb must be empty.
%                 Example - 'bdp',0.4
%                 Data Types - double
%
%    standardize : standardize data. boolean. Boolean which specifies
%               whether to standardize the variables, that is we operate on
%               the correlation matrix (default) or simply remove column
%               means (in this last case we operate on the covariance
%               matrix).
%                   Example - 'standardize',false
%                   Data Types - boolean
%
%      plots     : plots on the screen. Scalar. If plots is 1 (default) it is
%                   possible to show on the screen the scree plot of the
%                   variance explained, the plot of the loadings for the
%                   first two PCs.
%                   Example - 'plots',0
%                   Data Types - double
%
%     biplot     : launch app biplotFS. Scalar. If biplot is 1
%                   (default) app biplotFS is automatically launched. With
%                   this app it is possible to show in a dynamic way the
%                   rows points (PC coordinates), the arrows, the row
%                   labels and control with a scrolling bar the length of
%                   the arrows and the spread of row points.
%                   Example - 'biplot',0
%                   Data Types - double
%
%
%  dispresults   : show the results in the command window. If dispresults
%                   is true, the percentage of variance explained together
%                   with the loadings and the criteria for deciding the
%                   number of components to retain is shown in the command
%                   window.
%                   Example - 'dispresults',false
%                    Data Types - char
%
%  NumComponents : the number of components desired. Specified as a
%                  scalar integer $k$ satisfying $0 < k \leq v$. When
%                  specified, pcaFS returns the first $k$ columns of
%                  out.coeff and out.score. If NumComponents is not
%                  specified pcaFS returns the minimum number of components
%                  which cumulatively enable to explain a percentage of
%                  variance which is equal at least to $0.95^v$. If this
%                  threshold is exceeded already by the first PC, pcaFS
%                  still returns the first two PCs.
%                   Example - 'NumComponents',2
%                    Data Types - char
%
%
% Output:
%
%
%         out:   structure which contains the following fields
%
%out.Rtable = v-by-v correlation matrix in table format.
%
% out.explained = v \times 3 matrix containing respectively
%                1st col = eigenvalues;
%                2nd col = Explained Variance (in percentage)
%                3rd col = Cumulative Explained Variance (in percentage)
%
%out.explainedT = the same as out.explained but in table format.
%
%out.coeff=  v-by-NumComponents matrix containing the ordered eigenvectors
%           of the correlation (covariance matrix) in table format.
%            First column is referred to first eigenvector ...
%            Note that out.coeff'*out.coeff= I_NumComponents.
%
%out.coeffT = the same as out.coeff but in table format.
%
%out.loadings=v-by-NumComponents matrix containing the correlation
%             coefficients between the original variables and the first
%             NumComponents principal components.
%
%out.loadingsT = the same as out.loadings but in table format.
%
% out.score= the principal component scores. The rows of out.score
%            correspond to observations, columns to components. The
%            covariance matrix of out.score is $\Lambda$ (the diagonal
%            matrix containing the eigenvalues of the correlation
%            (covariance matrix).
%
% out.scoreT = the same as outscore but in table format.
%
% out.communalities = matrix with v-by-2*NumComponents-1 columns.
%               The first NumComponents columns contain the communalities
%               (variance extracted) by the the first NumComponents
%               principal components. Column NumComponents+1 contains the
%               communalities extracted by the first two principal
%               components. Column NumComponents+2 contains the
%               communalities extracted by the first three principal
%               components...
%
%  out.communalitiesT= the same as out.communalities but in table format.
%
% See also: pca, biplotFS
%
% References:
%
%
% Copyright 2008-2023.
% Written by FSDA team
%
%<a href="matlab: docsearchFS('pcaFS')">Link to the help function</a>
%
%$LastChangedDate::                      $: Date of the last commit

% Examples:


%{
    % Use of pcaFS with creditrating dataset.
    creditrating = readtable('CreditRating_Historical.dat','ReadRowNames',true);
    % Use all default options
    out=pcaFS(creditrating(1:100,1:6))
%}

%{
    %% use of pcaFS on the ingredients dataset.
    load hald
    % Operate on the covariance matrix.
    out=pcaFS(ingredients,'standardize',false,'biplot',0);
%}


%% Beginning of code
[n,v]=size(Y);
plots=1;
standardize=true;
biplot=1;
dispresults=true;
NumComponents=[];
bdp='';
bsb='';

if nargin>1
    options=struct('plots',plots, ...
        'standardize',standardize,'biplot', biplot,...
        'dispresults',dispresults,'NumComponents',NumComponents,...
        'bdp',bdp,'bsb',bsb);

    UserOptions=varargin(1:2:length(varargin));
    if ~isempty(UserOptions)


        % Check if number of supplied options is valid
        if length(varargin) ~= 2*length(UserOptions)
            error('FSDA:pcaFS:WrongInputOpt','Number of supplied options is invalid. Probably values for some parameters are missing.');
        end

        % Check if all the specified optional arguments were present
        % in structure options
        % Remark: the nocheck option has already been dealt by routine
        % chkinputR
        inpchk=isfield(options,UserOptions);
        WrongOptions=UserOptions(inpchk==0);
        if ~isempty(WrongOptions)
            disp(strcat('Non existent user option found->', char(WrongOptions{:})))
            error('FSDA:pcaFS:NonExistInputOpt','In total %d non-existent user options found.', length(WrongOptions));
        end
    end


    % Write in structure 'options' the options chosen by the user
    for i=1:2:length(varargin)
        options.(varargin{i})=varargin{i+1};
    end

    plots=options.plots;
    standardize=options.standardize;
    biplot=options.biplot;
    dispresults=options.dispresults;
    NumComponents=options.NumComponents;
    bdp=options.bdp;
    bsb=options.bsb;
end

if istable(Y)
    varnames=Y.Properties.VariableNames;
    rownames=Y.Properties.RowNames;
    Y=table2array(Y);
else
    varnames=cellstr(num2str((1:v)','Y%d'));
    rownames=cellstr(num2str((1:n)','%d'));
end

if ~isempty(bdp) && ~isempty(bsb)
    error('FSDA:pcaFS:WrongInputOpt','just one between bsb and bdp has to be supplied');
end

if ~isempty(bdp)
    outMCD=mcd(Y,'bdp',bdp,'conflev',1-0.01/n);
    % bsb=outMCD.outliers
    bsb=true(n,1);
    bsb(outMCD.outliers)=false;
    robust=true;
elseif ~isempty(bsb)
    if ~islogical(bsb)
        bsbini=false(n,1);
        bsbini(bsb)=true;
        bsb=bsbini;
    end
    robust=true;
else
    bsb=true(n,1);
    robust=false;
end
Ybsb=Y(bsb,:);
nbsb=size(Ybsb,1);

center=mean(Ybsb);
if standardize==true
    dispersion=std(Ybsb);
    % Create matrix of standardized data
    Z=(Y-center)./dispersion;
else
    % Create matrix of deviations from the means
    Z=Y-center;
end

% [~,S,loadings]=svd(Z./sqrt(n-1),0);
% Z=(Y-mean(Y))*loadings;

Ztable=array2table(Z,'RowNames',rownames,'VariableNames',varnames);


% Correlation (Covariance) matrix in table format
Zbsb=Z(bsb,:);
R=cov(Zbsb);
Rtable=array2table(R,'VariableNames',varnames,'RowNames',varnames);

sigmas=sqrt(diag(R));

% svd on matrix Z.
[~,Gamma,V]=svd(Zbsb,'econ');
Gamma=Gamma/sqrt(nbsb-1);

% \Gamma*\Gamma = matrice degli autovalori della matrice di correlazione
La=Gamma.^2;
la=diag(La);

%% Explained variance
sumla=sum(la);
explained=[la 100*(la)/sumla 100*cumsum(la)/sumla];
namerows=cellstr([repmat('PC',v,1) num2str((1:v)')]);
namecols={'Eigenvalues' 'Explained_Variance' 'Explained_Variance_cum'};
explainedT=array2table(explained,'RowNames',namerows,'VariableNames',namecols);
if isempty(NumComponents)
    NumComponents=find(explained(:,3)>100*0.95^v,1);
    if NumComponents==1
        disp('The first PC already explains more than 0.95^v variability')
        disp('In what follows we still extract the first 2 PCs')
        NumComponents=2;
    end
end

% labels of the PCs
pcnames=cellstr(num2str((1:NumComponents)','PC%d'));

V=V(:,1:NumComponents);
La=La(1:NumComponents,1:NumComponents);
VT=array2table(V,'RowNames',varnames','VariableNames',pcnames);


%% Loadings
loadings=V*sqrt(La)./sigmas;
loadingsT=array2table(loadings,'RowNames',varnames','VariableNames',pcnames);


%% Principal component scores
score=Z*V;
scoreT=array2table(score,'RowNames',rownames,'VariableNames',pcnames);


%% Communalities
commun=loadings.^2;
labelscum=cellstr([repmat([pcnames{1} '-'],NumComponents-1,1) char(pcnames{2:end})]);
communcum=cumsum(loadings.^2,2);
communwithcum=[commun communcum(:,2:end)];
varNames=[pcnames; labelscum];
if verLessThanFS('9.7')
    varNames=matlab.lang.makeValidName(varNames);
end
communwithcumT=array2table(communwithcum,'RowNames',varnames,...
    'VariableNames',varNames);

%% Orthogonal distance to PCA subspace based on k PC
Res=Z-score*V';
orthDist=sqrt(sum(Res.^2,2));


%% Score distance in PCA subspace of dimension k
larow=diag(La)';
scoreDist=sqrt(sum(score.^2./larow,2));


out=struct;
out.Rtable=Rtable;
out.explained=explained;
out.explainedT=explainedT;
out.coeff=V;
out.coeffT=VT;
out.loadings=loadings;
out.loadingsT=loadingsT;
out.communalities=communwithcum;
out.communalitiesT=communwithcumT;
out.score=score;
out.scoreT=scoreT;
out.orthDist=orthDist;
out.scoreDist=scoreDist;

if dispresults == true
    format bank
    if standardize == true
        disp('Initial correlation matrix')
    else
        disp('Initial covariance matrix')
    end
    disp(Rtable)

    disp('Explained variance by PCs')
    disp(explainedT)

    disp('Loadings = correlations between variables and PCs')
    disp(loadingsT)

    disp('Communalities')
    disp(communwithcumT)
    format short
end

if plots==1

    %% Explained variance through Pareto plot
    figure('Name','Explained variance')
    [h,axesPareto]=pareto(explained(:,1),namerows);
    % h(1) refers to the bars h(2) to the line
    h(1).FaceColor='g';
    linelabels = string(round(100*h(2).YData/sumla,2));
    text(axesPareto(2),h(2).XData,h(2).YData,linelabels,...
        'Interpreter','none');
    xlabel('Principal components')
    ylabel('Explained variance (%)')

    %% Plot loadings
    xlabels=categorical(varnames,varnames);
    figure('Name','Loadings')

    for i=1:NumComponents
        subplot(NumComponents,1,i)
        b=bar(xlabels, loadings(:,i),'g');
        title(['Correlations with PC' num2str(i)])
        xtips=b(1).XData;
        ytips=b(1).YData;
        % The alternative instructions below only work from MATLAB
        % 2019b
        %   xtips = b.XEndPoints;
        %   ytips = b.YEndPoints;
        barlabels = string(round(loadings(:,i),2));
        text(xtips,ytips,barlabels,'HorizontalAlignment','center',...
            'VerticalAlignment','bottom')
        title(['Correlations  with PC' num2str(i)])
    end
end
if biplot==1
    if robust==true
    biplotAPP(Ztable,'standardize',standardize,'bsb',bsb)
    else
    biplotAPP(Ztable,'standardize',standardize)
    end
end

end

%FScategory:MULT-Multivariate

