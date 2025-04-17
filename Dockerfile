FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

# Install the vsdbg debugger and create startup hook
WORKDIR /startuphooks
COPY ["./StartupHooks/StartupHooks.csproj", "./"]
RUN dotnet restore "StartupHooks.csproj"
COPY ./StartupHooks .
RUN dotnet build "StartupHooks.csproj" -c Debug -o /startuphooks/build

WORKDIR /src
COPY ["./DockerDebugApp/DockerDebugApp.csproj", "./"]
RUN dotnet restore "DockerDebugApp.csproj"
COPY . .
RUN dotnet build "DockerDebugApp.csproj" -c Debug -o /app/build


FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /startuphooks
COPY --from=build /startuphooks/build .

ENV DOTNET_STARTUP_HOOKS=/startuphooks/StartupHooks.dll

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip procps curl \
    && curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg

WORKDIR /app
COPY --from=build /app/build .

ENTRYPOINT ["dotnet", "DockerDebugApp.dll"]
