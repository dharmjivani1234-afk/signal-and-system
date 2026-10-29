
clc;
clear;
close all;

fm = 1;                   % Signal frequency
t = 0:0.001:3;             % Time
x = sin(2*pi*fm*t);        % Original signal

%% 1. Sampling and Reconstruction

fsList = [10 20 50 100];

figure;

for i = 1:length(fsList)

    fs = fsList(i);

    ts = 0:1/fs:3;         % Sampling time
    xs = sin(2*pi*fm*ts); % Sampled signal

    % Sinc reconstruction
    xr = zeros(size(t));

    for k = 1:length(ts)

        z = fs*(t-ts(k));

        % Normalized sinc function (no toolbox required)
        s = ones(size(z));
        index = (z ~= 0);
        s(index) = sin(pi*z(index))./(pi*z(index));

        xr = xr + xs(k)*s;
    end

    % Calculate reconstruction error
    err = sqrt(mean((x-xr).^2));

    subplot(2,2,i);
    plot(t,x,'b','LineWidth',1.5);
    hold on;
    stem(ts,xs,'r.');
    plot(t,xr,'k--');
    grid on;

    title(['Sampling Frequency = ',num2str(fs),' Hz']);
    xlabel('Time (seconds)');
    ylabel('Amplitude');
   

    fprintf('fs = %g Hz, Error = %.4f\n',fs,err);

end

sgtitle('Sampling and Sinc Reconstruction');

%% 2. Aliasing Gallery

fsList = [1.8 1.5 1.2 1.0 0.8 0.6 0.4];

figure;

fprintf('\nAliasing Results\n');
fprintf('fs (Hz)    Alias (Hz)    Error\n');

for i = 1:length(fsList)

    fs = fsList(i);

    % Calculate exact signed alias frequency
    fa = mod(fm + fs/2,fs) - fs/2;

    % Generate alias signal
    xa = sin(2*pi*fa*t);

    % Calculate alias error
    err = sqrt(mean((x-xa).^2));

    % Sample the original signal
    ts = 0:1/fs:3;
    xs = sin(2*pi*fm*ts);

    subplot(4,2,i);
    plot(t,x,'b','LineWidth',1.3);
    hold on;
    plot(t,xa,'r--','LineWidth',1.3);
    stem(ts,xs,'k.');
    grid on;

    title(['fs = ',num2str(fs), ...
           ' Hz, Alias = ',num2str(abs(fa),'%.2f'),' Hz']);
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    

    fprintf('%.2f        %.3f        %.3f\n', ...
            fs,abs(fa),err);

end

sgtitle('Aliasing Gallery');

%% 3. Alias Frequency and Error Graph

fsSweep = 0.2:0.01:1.99;

aliasFreq = zeros(size(fsSweep));
aliasError = zeros(size(fsSweep));

for i = 1:length(fsSweep)

    fs = fsSweep(i);

    fa = mod(fm + fs/2,fs) - fs/2;
    aliasFreq(i) = abs(fa);

    xa = sin(2*pi*fa*t);
    aliasError(i) = sqrt(mean((x-xa).^2));

end

figure;

subplot(2,1,1);
plot(fsSweep,aliasFreq,'b');
grid on;
xlabel('Sampling Frequency (Hz)');
ylabel('Alias Frequency (Hz)');
title('Alias Frequency vs Sampling Frequency');

subplot(2,1,2);
plot(fsSweep,aliasError,'r');
grid on;
xlabel('Sampling Frequency (Hz)');
ylabel('Alias Error');
title('Alias Error vs Sampling Frequency');

fprintf('\nNyquist Rate = %.1f Hz\n',2*fm);
