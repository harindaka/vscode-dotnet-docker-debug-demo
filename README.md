# Dotnet Docker Debug Demo

This repository demonstrates how to debug .NET applications in VS Code using docker containers with the help of the .Net startup hooks feature.

## Project Structure

```plaintext
.
├── .docker/                 # Docker-related scripts and configurations
│   ├── debugger-build.bat   # Script to build the debugger Docker image
│   ├── debugger-dockerfile  # Dockerfile for the debugger container
│   ├── debugger-run.bat     # Script to run the debugger container
│   ├── solution-build.bat   # Script to build the solution
│   ├── nuget/               # NuGet package cache
│   └── pid/                 # Directory for storing process ID files
├── .vscode/                 # VS Code configuration files
│   ├── launch.json          # Debugging configurations
│   └── tasks.json           # Build and task configurations
├── ConsoleApp/              # Demo console application
├── StartupHooks/            # Startup hook implementation
├── UnitTests/               # Demo Unit tests project
├── DotnetDockerDebugDemo.sln # Solution file
```

## Features

- **VS Code Launch Configurations with Docker Support**: Includes VS Code launch configurations which allow running and debugging .net projects using docker.
- **Startup Hooks**: Implements a custom startup hook that waits for a debugger to attach and monitors debugger detachment and automatically exits the application when it is detached.
- **Debug Unit Tests in a Container**: Contains a unit test project to demo debugging inside a container.

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/)
- [Visual Studio Code](https://code.visualstudio.com/)

### Building the Solution

To build the solution, use the default build task in Visual Studio Code:

1. Open the Command Palette (`Ctrl+Shift+P` on Windows) and select `Tasks: Run Build Task`.
2. Choose the `solution-build` task to build the solution.

### Running the Application

To run the application with debugging enabled:

1. Open the `Run and Debug` view in Visual Studio Code (`Ctrl+Shift+D` on Windows).
2. Select the `Debug ConsoleApp` configuration from the dropdown menu.
3. Click the green play button to start debugging.

### Debugging Unit Tests

To debug unit tests:

1. Open the `Run and Debug` view in Visual Studio Code (`Ctrl+Shift+D` on Windows).
2. Select the `Debug UnitTests` configuration from the dropdown menu.
3. Click the green play button to start debugging the unit tests.

### Concurrent Debugging

To debug both the Console App and Unit Tests projects at the same time:

1. Open the `Run and Debug` view in Visual Studio Code (`Ctrl+Shift+D` on Windows).
2. Select the `Debug All` configuration from the dropdown menu.
3. Click the green play button to start debugging both projects.

## How It Works

1. **Debugging**: When you start debugging, the VS Code launch configuration will run the following steps / tasks
   1. Build the solution in Docker
   2. Build the debugger image (this step builds the startup hook and sets it up along with vsdbg inside the image)
   3. Run the previously built project assembly inside its own container (debugger image)
   4. Startup hook halts the process until the debugger attaches
   5. Attach VS Code debugger to the correct dotnet process inside the debugger container
   6. When debugger is detached, the startup hook will exit the app causing the container to stop and be removed
2. **Startup Hook**: The `StartupHook` class in `StartupHooks/StartupHook.cs` initializes when the application starts. It identifies the entry assembly, writes the process ID to a file, and waits for a debugger to attach. A background thread monitors debugger detachment and shuts down the application when it is detached.
3. **Process Selection for Debugging**: For the typical console app or asp.net projects, there will only be one process with the name `dotnet` inside the container. Thus VS Code will identify this process to attach the debugger using the `"processName": "dotnet"` setting specified in the launch configuration. However for unit tests, `dotnet test` spawns additional `vstest` and `testhost` processes. Due to this there will usually be 3 processes with the process name set to `dotnet`. This makes it difficult to automate the process of letting VS Code know which `dotnet` process to attach the debugger to. To solve this, the startup hook will probe the correct `testhost` process and output its process id and wait for the debugger to attach. VS Code will then prompt the developer to select the correct process when debugging unit tests (at which point the previously output process id is the correct one to select in order to start debugging).

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## Acknowledgments

- [Microsoft Documentation on Startup Hooks](https://learn.microsoft.com/en-us/dotnet/core/dependency-loading/startup-hooks)
- [Docker Documentation](https://docs.docker.com/)