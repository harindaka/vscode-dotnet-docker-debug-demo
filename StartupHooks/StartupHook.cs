using System;
using System.Diagnostics;
using System.Runtime.Loader;
using System.Threading;
using System.Reflection;

public static class StartupHook
{
    public static void Initialize()
    {
        var assemblyName = Assembly.GetEntryAssembly()?.FullName ?? string.Empty;
        Console.WriteLine($"[{assemblyName}]: Waiting for debugger to attach...");

        // Start a background thread to monitor debugger detachment
        ThreadPool.QueueUserWorkItem(_ =>
        {
            bool wasAttached = Debugger.IsAttached;
            while (true)
            {
                Thread.Sleep(100);
                if (wasAttached && !Debugger.IsAttached)
                {
                    Console.WriteLine($"[{assemblyName}]: Debugger detached, shutting down...");
                    Environment.Exit(0);
                }
                wasAttached = Debugger.IsAttached;
            }
        });

        // Wait for debugger
        while (!Debugger.IsAttached)
        {
            Thread.Sleep(100);
        }

        Console.WriteLine($"[{assemblyName}]: Debugger attached!");
    }
}
