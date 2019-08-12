function Xout = kaVirtualSignalBetaDiv(X,posAlpha,b)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Input :
%% X : 2 channels actual signal (FFT representation) :
%% 2 (channel) x freq x frames x source
%% posAlpha : Vector of microphone position
%%  1 x # of virtual mic
%% b : beta divergence parameter : scalar
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[MICNUM,FRMNUM,BINNUM,SRCNUM] = size(X);
% X=permute(X,[3 2 1 4]);

% Initialize
nVirSignal=length(posAlpha);
Xout=zeros(nVirSignal,FRMNUM,BINNUM,SRCNUM);
vPhase=Xout;
vAmp=Xout;
printtime=false;

% Error
if MICNUM ~= 2
    error('Please input 2 channels signal.')
end

% Difference of phase between 2 real signals
% ���M���̈ʑ���
xPhase = angle(X); % �ʑ��p
xAmp=abs(X); % �U��
phaseDiff = diff(xPhase,1,1); % ����ɑ΂��č������Ƃ�
phaseDiff = mod(phaseDiff, 2*pi); % 2*pi + k �� k�Ɠ��`�ł���A0<theta<2*pi�ōl���Ă���
phaseDiff = phaseDiff - 2*pi*(phaseDiff > pi); % 0 to 2*pi �� -pi to pi ��
% 2���M���̈ʑ�����-pi����pi�͈̔͂ŕ\���ꂽ

% Calc phase and amplitude
for n = 1:nVirSignal
    %keyboard;
    % Xout(:,:,n,:) = exp(((1-posAlpha(n)) * log(abs(X(:,:,1,:))) + posAlpha(n) * log(abs(X(:,:,2,:))) ...
    % + (1i * (XPhase(:,:,1,:) + phaseDiff * posAlpha(n)))));
    vPhase(n,:,:,:)=xPhase(1,:,:,:) + phaseDiff * posAlpha(n); % �ʑ��͐�`���
    if b==1
        % beta = 1 -> Log domain interpolation
        vAmp(n,:,:,:)=exp(((1-posAlpha(n))*log(xAmp(1,:,:,:)))+(posAlpha(n)*log(xAmp(2,:,:,:))));
    % b�_�C�o�[�W�F���X�̌v�Z
    elseif b==-inf
        if posAlpha(n)==0
            vAmp(n,:,:,:)=xAmp(1,:,:,:);
        elseif posAlpha(n)==1
            vAmp(n,:,:,:)=xAmp(2,:,:,:);
        else
            vAmp(n,:,:,:)=min(xAmp(1,:,:,:),xAmp(2,:,:,:));
        end
    elseif b==inf
        
        if  posAlpha(n)==0
            vAmp(n,:,:,:)=xAmp(1,:,:,:);
        elseif posAlpha(n)==1
            vAmp(n,:,:,:)=xAmp(2,:,:,:);
        else
            vAmp(n,:,:,:)=max(xAmp(1,:,:,:),xAmp(2,:,:,:));
        end
    else
        % otherwise
        vAmp(n,:,:,:)=(((1-posAlpha(n))*(xAmp(1,:,:,:).^(b-1)))...
            + (posAlpha(n)*(xAmp(2,:,:,:).^(b-1)))).^(1/(b-1));
    end % switching by beta value
end % loop of channels
Xout=vAmp.*exp(1i*vPhase);

% nan �� inf ��0��
tS=isnan(Xout)+isinf(Xout);
Xout(tS~=0)=0;

end