% Store the channel ID for the moisture sensor channel.
channelID = 2529484;

% Provide the ThingSpeak alerts API key.  All alerts API keys start with TAK.
alertApiKey = 'TAKKaDa7OqRp4RRIpml';

% Set the address for the HTTTP call
alertUrl="https://api.thingspeak.com/alerts/send";

% webwrite uses weboptions to add required headers.  Alerts needs a ThingSpeak-Alerts-API-Key header.
options = weboptions("HeaderFields", ["ThingSpeak-Alerts-API-Key", alertApiKey ]);

% Set the email subject.
alertSubject = sprintf("Water been wasted!!");

% Read the recent data.
tapData = thingSpeakRead(channelID,'NumPoints',14,'Fields',1);
Volumedata=thingSpeakRead(channelID,'NumPoints',14,'Fields',2);
for i=1:1:14
      if(tapData(i,1)==0)
          check=0;
      end
end
for i=2:1:14
      if(Volumedata(i,1)<=1)
          for j=i:1:14
              disp(Volumedata(j,1));
              Volumedata(j,1)=Volumedata(i-1,1)+Volumedata(j,1);
              disp(Volumedata(j,1));

          end
      end 
end

data=[tapData Volumedata];

% Generate timestamps for the data

writeAPIKey = '5NUF6255U4UJ96SN';

% Write 10 values to each field of your channel along with timestamps
[Data,timestamps] = thingSpeakRead(channelID,'Fields',[1,2],NumPoints=14);
% thingSpeakWrite(channelID,data,'TimeStamp',timestamps,'WriteKey',writeAPIKey)

% Create timetable
timeStamps = datetime('now')-minutes(13):minutes(1):datetime('now');
timeStamps=timeStamps';
dataTable = timetable(timeStamps,tapData,Volumedata);

% Write 14 values to each field of your channel along with timestamps
thingSpeakWrite(channelID,dataTable,'WriteKey',writeAPIKey)
% Check to make sure the data was read correctly from the channel.
if (check==1)     
    alertBody = 'Tap running for more than 10 minutes. Please check if leaking or left running';
    try
    webwrite(alertUrl , "body", alertBody, "subject", alertSubject, options);
catch someException
    fprintf("Failed to send alert: %s\n", someException.message);
    end

end
disp(data);

 
 % Catch errors so the MATLAB code does not disable a TimeControl if it fails
