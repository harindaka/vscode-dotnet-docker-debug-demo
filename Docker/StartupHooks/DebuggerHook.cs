using System;
using System.Diagnostics;
using System.Runtime.Loader;
using System.Threading;

public static class StartupHook
{
    public static void Initialize()
    {
        Console.WriteLine("Waiting for debugger to attach...");
        
        // Set up handler to detect debugger detach
        Debugger.DebuggerDetached += (sender, e) => 
        {
            Console.WriteLine("Debugger detached, shutting down...");
            Environment.Exit(0);
        };
        
        // Wait for debugger
        while (!Debugger.IsAttached)
        {
            Thread.Sleep(100);
        }
        
        Console.WriteLine("Debugger attached!");
    }
}
