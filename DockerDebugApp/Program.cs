// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, Docker Debug World!");

// Add a loop to make it easier to attach the debugger
Console.WriteLine("Press Ctrl+C to exit");
int counter = 0;
while (true)
{
    counter++;
    Console.WriteLine($"Counter: {counter}");
    
    // Good place to set a breakpoint
    if (counter % 10 == 0)
    {
        Console.WriteLine($"Counter reached multiple of 10: {counter}");
    }
    
    Thread.Sleep(1000); // Sleep for 1 second
}
