fromHz = 44100;
toHz = 44100;

fromBits = 24;
toBits = 16;

fromDir = 'audio_converted2';
toDir = 'audio_xcorr_addsub';


fromFiles = dir(strcat(fromDir, '/*.wav'));

for file = fromFiles'
    fileName = strcat(fromDir, '/', file.name)
    data = wavread(fileName);

	[acor, lag] = xcorr(data(:, 1), data(:, 2));
	[~, I] = max(abs(acor));
	lagDiff = lag(I);

	if lagDiff < 0
		R = data(-lagDiff:end, 2);
		dim = length(R);
		L = data(1:dim, 1);
	elseif lagDiff > 0
		L = data(-lagDiff:end, 1);
		dim = length(L);
		R = data(1:dim, 2);
	else
		L = data(:, 1);
		R = data(:, 2);
	end

	wavwrite([L+R, L-R], toHz, toBits, strcat(toDir, '/', file.name));
end
