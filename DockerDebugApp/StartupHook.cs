using System.Diagnostics;
using System.Threading;

namespace DockerDebugApp
{
    public static class StartupHook
    {
        public static void Initialize()
        {
            Console.WriteLine("Waiting for debugger to attach...");
            while (!Debugger.IsAttached)
            {
                Thread.Sleep(100);
            }
            Console.WriteLine("Debugger attached!");
        }
    }
}
