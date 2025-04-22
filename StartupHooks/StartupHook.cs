using System;
using System.Diagnostics;
using System.Runtime.Loader;
using System.Threading;
using System.Reflection;

public static class StartupHook
{
    private enum EntryAssemblyType
    {
        ProjectSource,
        TestHost,
        Other
    }

    private sealed record EntryAssemblyInfo(EntryAssemblyType Type, int ProcessId, string AssemblyName);
    
    public static void Initialize()
    {
        // Try GetEntryAssembly (most reliable)
        var entryAssemblyInfo = GetEntryAssemblyInfo();
        Console.WriteLine($"[StartupHook] EntryAssembly: {entryAssemblyInfo.AssemblyName}");
        if (entryAssemblyInfo.Type == EntryAssemblyType.TestHost)
        {
            Console.WriteLine($"[StartupHook] Test Host: {entryAssemblyInfo.AssemblyName}, Process: {entryAssemblyInfo.ProcessId}.");
        }
        else if (entryAssemblyInfo.Type == EntryAssemblyType.ProjectSource)
        {
            Console.WriteLine($"[StartupHook] Project Assembly: {entryAssemblyInfo.AssemblyName}, Process: {entryAssemblyInfo.ProcessId}.");
        }
        else if (entryAssemblyInfo.Type == EntryAssemblyType.Other)
        {
            Console.WriteLine($"[StartupHook] Skipping Entry Assembly: {entryAssemblyInfo.AssemblyName}, Process: {entryAssemblyInfo.ProcessId}.");
            return;
        }
        
        Console.WriteLine($"[StartupHook][{entryAssemblyInfo.AssemblyName}]: Waiting for debugger to attach...");

        // Start a background thread to monitor debugger detachment
        ThreadPool.QueueUserWorkItem(_ =>
        {
            bool wasAttached = Debugger.IsAttached;
            while (true)
            {
                Thread.Sleep(100);
                if (wasAttached && !Debugger.IsAttached)
                {
                    Console.WriteLine($"[StartupHook][{entryAssemblyInfo.AssemblyName}]: Debugger detached, shutting down...");
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

        Console.WriteLine($"[StartupHook][{entryAssemblyInfo.AssemblyName}]: Debugger attached!");
    }

    private static EntryAssemblyInfo GetEntryAssemblyInfo()
    {
        int pid = Process.GetCurrentProcess().Id;
        string entryAssemblyName = Assembly.GetEntryAssembly()?.GetName().Name ?? string.Empty;
        var assemblyType = entryAssemblyName switch
        {
            "" => EntryAssemblyType.Other,  // EntryAssembly is null e.g. dotnet-cli
            var name when name.Equals("dotnet", StringComparison.OrdinalIgnoreCase) => EntryAssemblyType.Other,
            var name when name.Equals("vstest.console", StringComparison.OrdinalIgnoreCase) => EntryAssemblyType.Other,
            var name when name.Equals("testhost", StringComparison.OrdinalIgnoreCase) => EntryAssemblyType.TestHost,
            _ => EntryAssemblyType.ProjectSource  // Anything else — likely project assembly
        };

        return new EntryAssemblyInfo(assemblyType, pid, entryAssemblyName);
    }
}
