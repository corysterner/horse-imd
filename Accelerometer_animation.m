
%a = arduino('com9', 'uno'); %create arduino connection

scale = 200; %(±3g) for ADXL337, 200 (±200g) for ADXL377
micro_is_5V = true; % Set to true if using a 5V microcontroller such as the Arduino Uno, false if using a 3.3V microcontroller, this affects the interpretation of the sensor data
%create figure and subplots
clf
figure(1)
plots = gobjects(3,1,1);
plots(1) = subplot(3,1,1);
h(1) = animatedline('MaximumNumPoints',1000);
title('X');
plots(2) = subplot(3,1,2);
h(2) = animatedline('MaximumNumPoints',1000, 'Color', 'r');
title('Y');
plots(3) = subplot(3,1,3);
title('Z');
h(3) = animatedline('MaximumNumPoints',1000, 'Color', 'b');
xlim(plots, [0 10]);
ylim(plots, [-10 10]);
sgtitle('Scaled Accelerometer Data');

t = timer('TimerFcn', 'stat=false;', 'StartDelay',30);%makes while loop non-infinite
start(t);

stat = true;
refreshRate = 0.005;
count = 0;
scaled = zeros(3);
tic
while(stat)
  %Get raw accelerometer data for each axis
  rawX = readVoltage(a, 'A0');
  rawY = readVoltage(a, 'A1');
  rawZ = readVoltage(a, 'A2');
  
  
  %Scale accelerometer ADC readings into common units
  %Scale map depends on if using a 5V or 3.3V microcontroller
  if micro_is_5V % Microcontroller runs off 5V
    scaled(1) = mapf(rawX, 0, 3.3, scale*-1, scale); % 3.3/5 * 1023 =~ 675
    scaled(2) = mapf(rawY, 0, 3.3, scale*-1, scale);
    scaled(3) = mapf(rawZ, 0, 3.3, scale*-1, scale);
  else % Microcontroller runs off 3.3V
    scaled(1) = mapf(rawX, 0, 1, -scale, scale);
    scaled(2) = mapf(rawY, 0, 1, -scale, scale);
    scaled(3) = mapf(rawZ, 0, 1, -scale,  scale);
  end
  %Plot the scaled data vs time on 3 seperate graphs
  count = toc; %Time elapsed
  for i = 1:3
    plots(i);
    addpoints(h(i), count, scaled(i));
  end
  if(count > 9.4)
      xlim(plots, [count - 9.4, count + .6])
  end
          
  
  drawnow limitrate
  pause(refreshRate)
end

function scaled = mapf(x, in_min, in_max, out_min, out_max)
  scaled = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
end

function stop()
    stat = false;
end