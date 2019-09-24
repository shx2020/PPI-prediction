function [predictions,src_scores] = WSRC( trnX ,trnY ,tstX , lambda)

% weighted SRC����min_{alpha} ||diag(w)alpha||_1 
%           s.t. ||x-Dalpha||_2^2 <= lambda

% Input:
% trnX [dim * num ] - each column is a training sample��ÿ����ѵ������
% trnY [ 1  * num ] - training label ����ǩ��һ��
% tstX
% tstY

% Output:
% rate             - Recognition rate of test sample ׼ȷ��
% predictlabel     - predict label of test sample

ntrn = size( trnX , 2 );  % ѵ��������
ntst = size( tstX , 2 );  % ����������
nClass = length( unique(trnY) );  % �����

% normalize �й�һ��
for i = 1 : ntrn
    trnX(:,i) = trnX(:,i) / norm( trnX(:,i) ) ;  % norm����
end
for i = 1 : ntst
    tstX(:,i) = tstX(:,i) / norm( tstX(:,i) ) ;
end

sigma = 1.5;
W = SimilarityMatrix( trnX , tstX , sigma ) ;  % ѵ�������Ͳ������������ƶȾ�������ѵ�����������ǲ�����������ΪȨ�ؾ���
% W = SimilarityMatrix( trnX , tstX ) ;

% classify
param.lambda = lambda ; % not more than 20 non-zeros coefficients
% param.numThreads=2;   % number of processors/cores to use; the default choice is -1
% and uses all the cores of the machine
param.mode = 1 ;        % penalized formulation
param.verbose = false ;
A = mexLassoWeighted( tstX , trnX , W , param ) ;
% [rate predictlabel] = Decision_Residual( trnX ,trnY ,tstX , tstY , A) ;

K=full(A);           
Trainlabels=trnY';   
Test=tstX';          
Train=trnX';          
K=K';                

uniqlabels=unique(Trainlabels);  % ȥ���������ظ���Ԫ��,ʣ[-1;1]
c=max(size(uniqlabels));         % ��ǩ����2
for i=1:c
    R=Test-K(:,find(Trainlabels==uniqlabels(i)))*Train(find(Trainlabels==uniqlabels(i)),:);  % 583*240
    src_scores(:,i)=sqrt(sum(R.*R,2));  
end
[maxval,indices]=min(src_scores'); % src_scores'��2*583��maxval������Сֵ��indices������Сֵ���к�
predictions=uniqlabels(indices);  
src_scores=src_scores(:,2);
