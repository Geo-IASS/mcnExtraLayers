function y = vl_nnhuberloss(x, t, varargin)
%VL_NNHUBERLOSS computes the Huber Loss
%   Y = VL_NNHUBERLOSS(X, T) computes the Huber Loss (also known 
%   as the "smooth L1 loss" between an N x 1 array of inputs 
%   predictions. The output Y is a SINGLE scalar.
%
%   The Huber Loss between X and T is as:
%
%     Loss = sum(f(X - T) .* W)
%
%   where W is an aray of instance weights (described below) and f is 
%   the following function (using the Faster R-CNN definition):
%   
%          { 0.5 * sigma^2 * x^2,    if |x| < 1 / sigma^2
%   f(x) = {
%          { |x| - 0.5 / sigma^2,    otherwise.
%
%   DZDX = VL_NNHUBERLOSS(X, T, DZDY) computes the derivatives with 
%   respect to inputs X. DZDX and DZDY have the same dimensions
%   as X and Y respectively.  The derivative of the Huber Loss is 
%   computed using
%
%          { sigma^2 * x,      if |x| < 1 / sigma^2,
%  f'(x) = {
%          { sign(x),          otherwise.
%
%   VL_NNHUBERLOSS(..., 'option', value, ...) takes the following option:
%
%   `instanceWeights`:: 1
%    Weights the loss contribution of each input. This can be an N x 1 
%   array that weights each input individually, or a scalar (in which
%   case the same weight is applied to every input). 
%
% Copyright (C) 2016 Samuel Albanie, Hakan Bilen and Andrea Vedaldi
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

  opts.sigma = 1 ;
  opts.instanceWeights = ones(size(x)) ;
  [opts, dzdy] = vl_argparsepos(opts, varargin) ;

  delta = x - t ;
  absDelta = abs(delta) ;
  sigma2 = opts.sigma ^ 2 ;
  linearRegion = (absDelta > 1. / sigma2) ;

  if isempty(dzdy)
    absDelta(linearRegion) = absDelta(linearRegion) - 0.5 / sigma2 ;
    absDelta(~linearRegion) = 0.5 * sigma2 * absDelta(~linearRegion) .^ 2 ;
    y = opts.instanceWeights(:)' * absDelta(:) ;
  else
    delta(linearRegion) = sign(delta(linearRegion));
    delta(~linearRegion) = sigma2 * delta(~linearRegion) ;
    y = opts.instanceWeights .* delta .* dzdy{1} ;
  end
