using System;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Devices.Client;
using Newtonsoft.Json;

namespace Mod02
{
    class Program
    {
        // Contains methods that a device can use to send messages to and receive from an IoT Hub.
        private static DeviceClient _deviceClient;

        // The device connection string to authenticate the device with your IoT hub.
        // Note: in real-world applications you would not "hard-code" the connection string
        // It could be stored within an environment variable, passed in via the command-line or
        // stored securely within a TPM module.
        private static readonly string _connectionString = "HostName=demo1207.azure-devices.net;DeviceId=device01;SharedAccessKey=53PrkR4o2p3UDyAG8IyTEPQa6EY+RwchhurQYsK8fqE=";

        private static void Main(string[] args)
        {
            Console.WriteLine("IoT Hub C# Simulated Cave Device. Ctrl-C to exit.\n");

            // Connect to the IoT hub using the MQTT protocol
            _deviceClient = DeviceClient.CreateFromConnectionString(_connectionString, TransportType.Mqtt);
            SendDeviceToCloudMessagesAsync();
            Console.ReadLine();
        }

        private static async void SendDeviceToCloudMessagesAsync()
        {
            // Create an instance of our sensor
            var sensor = new EnvironmentSensor();

            while (true)
            {
                // read data from the sensor
                var currentTemperature = sensor.ReadTemperature();
                var currentHumidity = sensor.ReadHumidity();

                var messageString = CreateMessageString(currentTemperature, currentHumidity);

                // create a byte array from the message string using ASCII encoding
                var message = new Message(Encoding.ASCII.GetBytes(messageString));

                // Add a custom application property to the message.
                // An IoT hub can filter on these properties without access to the message body.
                message.Properties.Add("temperatureAlert", (currentTemperature > 30) ? "true" : "false");

                // Send the telemetry message
                await _deviceClient.SendEventAsync(message);
                Console.WriteLine("{0} > Sending message: {1}", DateTime.Now, messageString);

                await Task.Delay(1000);
            }
        }

        private static string CreateMessageString(double temperature, double humidity)
        {
            // Create an anonymous object that matches the data structure we wish to send
            var telemetryDataPoint = new
            {
                temperature = temperature,
                humidity = humidity
            };

            // Create a JSON string from the anonymous object
            return JsonConvert.SerializeObject(telemetryDataPoint);
        }
    }

    // INSERT EnvironmentSensor class below here
}