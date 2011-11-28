using System;
using System.Timers;
using log4net;

namespace services
{
    public class ServiceHealthMonitor
    {
        readonly ILog _log = LogManager.GetLogger(typeof(ServiceHealthMonitor));
        readonly Timer _timer;

        public ServiceHealthMonitor(int interval = 15000)
        {
            _timer = new Timer(interval) { AutoReset = true };
            _timer.Elapsed += (sender, eventArgs) => _log.Info(string.Format("It is {0} an all is well", DateTime.Now));
        }

        public void Start()
        {
            _timer.Start();
        }
        public void Stop()
        {
            _timer.Stop();
        }

    }
}