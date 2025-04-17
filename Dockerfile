FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG REL_STARTUP_HOOKS_PATH=./StartupHooks
ARG REL_PROJECT_PATH

# Install the vsdbg debugger and create startup hook
WORKDIR /startuphooks
COPY ["${REL_STARTUP_HOOKS_PATH}/*.csproj", "./"]
RUN dotnet restore
COPY ${REL_STARTUP_HOOKS_PATH} .
RUN dotnet build -c Debug -o /startuphooks/build

WORKDIR /src
COPY ["${REL_PROJECT_PATH}/*.csproj", "./"]
RUN dotnet restore
COPY ${REL_PROJECT_PATH} .
RUN dotnet build -c Debug -o /src/build


FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip curl \
    && curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg

ENV DOTNET_STARTUP_HOOKS=/startuphooks/StartupHooks.dll
WORKDIR /startuphooks
COPY --from=build /startuphooks/build .

WORKDIR /app
COPY --from=build /src/build .

ENTRYPOINT ["dotnet", "DockerDebugApp.dll"]
