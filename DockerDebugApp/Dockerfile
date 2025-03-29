FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

# Install the vsdbg debugger and create startup hook
RUN mkdir -p /startuphook
RUN dotnet new classlib -n StartupHook -o /startuphook
WORKDIR /startuphook
RUN dotnet add package System.Runtime.Loader
RUN rm /startuphook/Class1.cs
RUN echo 'using System.Diagnostics; using System.Runtime.Loader; using System.Threading; public static class StartupHook { public static void Initialize() { Console.WriteLine("Waiting for debugger to attach..."); while (!Debugger.IsAttached) { Thread.Sleep(100); } Console.WriteLine("Debugger attached!"); } }' > /startuphook/startup_hook.cs

RUN dotnet build -c Debug

WORKDIR /src

WORKDIR /src
COPY ["DockerDebugApp.csproj", "./"]
RUN dotnet restore "DockerDebugApp.csproj"
COPY . .
RUN dotnet build "DockerDebugApp.csproj" -c Debug -o /app/build


FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=build /app/build .

COPY --from=build /startuphook/bin/Debug/net9.0/StartupHook.dll /startuphook/startup_hook.dll
ENV DOTNET_STARTUP_HOOKS=/startuphook/startup_hook.dll

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip procps curl \
    && curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg

ENTRYPOINT ["dotnet", "DockerDebugApp.dll"]
