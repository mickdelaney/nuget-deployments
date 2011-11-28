using Topshelf;

namespace services
{
    public static class Program
    {
        static void Main(string[] args)
        {
            HostFactory.Run(x =>
            {
                x.Service<ServiceHealthMonitor>(s =>
                {
                    s.SetServiceName("Health");
                    s.ConstructUsing(name => new ServiceHealthMonitor());
                    s.WhenStarted(tc => tc.Start());
                    s.WhenStopped(tc => tc.Stop());
                });

                x.RunAsLocalSystem();

                x.SetDescription("nuget services host - TopShelf");
                x.SetDisplayName("nuget Services");
                x.SetServiceName("nuget Services");
            }); 


        }
    }
}
