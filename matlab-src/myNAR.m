function [ Y_hat ] = myNAR( X, feedbackDelays, hiddenLayerSize, RATIO, HORIZON_array, trainFcn)
% Solve an Autoregression Time-Series Problem with a NAR Neural Network
% Script generated by NTSTOOL
% Created Thu Jan 16 10:22:32 SGT 2014
%
% This script assumes this variable is defined:
%
%   scaled_data - feedback time series.

% check if trainFcn exist
% by default is trainlm
if ~exist('trainFcn','var')
    trainFcn='trainlm';
end

if ~exist('HORIZON_array','var')
    HORIZON_array=1;
end


targetSeries = tonndata(X,false,false);

% Create a Nonlinear Autoregressive Network
% feedbackDelays = 1:48;
% hiddenLayerSize = 24;
net = narnet(feedbackDelays,hiddenLayerSize);

% Choose Feedback Pre/Post-Processing Functions
% Settings for feedback input are automatically applied to feedback output
% For a list of all processing functions type: help nnprocess
net.inputs{1}.processFcns = {'removeconstantrows','mapminmax'};
net.outputs{2}.processFcns = {'removeconstantrows','mapminmax'};

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer states.
% Using PREPARETS allows you to keep your original time series data unchanged, while
% easily customizing it for networks with differing numbers of delays, with
% open loop or closed loop feedback modes.
[inputs,inputStates,layerStates,targets] = preparets(net,{},{},targetSeries);

% % Setup Division of Data for Training, Validation, Testing
% % For a list of all data division functions type: help nndivide
% net.divideFcn = 'dividerand';  % Divide data randomly
% net.divideMode = 'time';  % Divide up every value
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
net.divideFcn = 'divideblock';  % Divide data randomly
net.divideMode = 'time';  % Divide up every value
net.divideParam.trainRatio = RATIO(1);
net.divideParam.valRatio = RATIO(2);
net.divideParam.testRatio = RATIO(3);

% Choose a Training Function
% For a list of all training functions type: help nntrain
net.trainFcn = trainFcn;  % Levenberg-Marquardt

% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'mse';  % Mean squared error

% Don't show NN window
% net.trainParam.showWindow=0;

% Choose Plot Functions
% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform','plottrainstate','plotresponse', ...
  'ploterrcorr', 'plotinerrcorr'};


% Train the Network
[net,tr] = train(net,inputs,targets,inputStates,layerStates);

% Test the Network
outputs = net(inputs,inputStates,layerStates);

Y_hat(1,:)=outputs(tr.testInd);
% Multi-step forecasting
for H=2:max(HORIZON_array)
    Y_hat(H,:)=net (Y_hat(H-1,:), inputStates,layerStates);
end

Y_hat=cell2mat(Y_hat);
Y_hat=Y_hat';
% errors = gsubtract(targets,outputs);
% performance = perform(net,targets,outputs);
% 
% % Recalculate Training, Validation and Test Performance
% trainTargets = gmultiply(targets,tr.trainMask);
% valTargets = gmultiply(targets,tr.valMask);
% testTargets = gmultiply(targets,tr.testMask);
% trainPerformance = perform(net,trainTargets,outputs);
% valPerformance = perform(net,valTargets,outputs);
% testPerformance = perform(net,testTargets,outputs);

% % View the Network
% view(net);

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, plotresponse(targets,outputs)
%figure, ploterrcorr(errors)
%figure, plotinerrcorr(inputs,errors)

% Closed Loop Network
% Use this network to do multi-step prediction.
% The function CLOSELOOP replaces the feedback input with a direct
% connection from the outout layer.
% netc = closeloop(net);
% [xc,xic,aic,tc] = preparets(netc,{},{},targetSeries);
% yc = netc(xc,xic,aic);
% perfc = perform(net,tc,yc)
% 
% % Early Prediction Network
% % For some applications it helps to get the prediction a timestep early.
% % The original network returns predicted y(t+1) at the same time it is given y(t+1).
% % For some applications such as decision making, it would help to have predicted
% % y(t+1) once y(t) is available, but before the actual y(t+1) occurs.
% % The network can be made to return its output a timestep early by removing one delay
% % so that its minimal tap delay is now 0 instead of 1.  The new network returns the
% % same outputs as the original network, but outputs are shifted left one timestep.
% nets = removedelay(net);
% [xs,xis,ais,ts] = preparets(nets,{},{},targetSeries);
% ys = nets(xs,xis,ais);
% closedLoopPerformance = perform(net,tc,yc)
% end
