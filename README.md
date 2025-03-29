# Docker Debug App

This is a .NET 9 console application configured for debugging in a Docker container using vsdbg and VSCode.

## Prerequisites

- Docker installed and running
- Visual Studio Code with C# extension installed
- .NET 9 SDK installed

## How to Debug

1. Open the project folder in VSCode
2. Set breakpoints in your code (e.g., on line 2 in Program.cs)
3. Press F5 or select "Run > Start Debugging"
   - This will automatically:
     - Build the Docker image
     - Start the container
     - Attach the debugger to the application

4. The application will pause at the beginning, waiting for the debugger to attach
5. Once the debugger attaches, the application will continue and hit your breakpoints

## How It Works

- The Dockerfile sets up a .NET 9 container, installs the vsdbg debugger, and creates a startup hook
- The startup hook makes the application wait for the debugger to attach before proceeding
- The launch.json configures VSCode to automatically run the setup tasks and connect to the container
- The tasks.json provides tasks for building and running the Docker container with debugging enabled
- The DOTNET_STARTUP_HOOKS environment variable tells .NET to use our startup hook

## Stopping the Container

To stop the container, run:

```bash
docker stop dockerdebugapp
```

## Project Structure

- `Program.cs` - Main application code
- `Dockerfile` - Docker configuration
- `.vscode/launch.json` - VSCode debugging configuration
- `.vscode/tasks.json` - VSCode tasks configuration
