ARG ENTRYPOINT_ASSEMBLY

# Install the vsdbg debugger early to leverage caching
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS debugger
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip curl \
    && curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS startuphooks-build
ARG REL_STARTUP_HOOKS_PATH=./StartupHooks

WORKDIR /startuphooks
COPY ["${REL_STARTUP_HOOKS_PATH}/*.csproj", "./"]
RUN dotnet restore
COPY ${REL_STARTUP_HOOKS_PATH} .
RUN dotnet build -c Debug -o /startuphooks/build

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS app-build
ARG REL_PROJECT_PATH
ARG ENTRYPOINT_ASSEMBLY
WORKDIR /src
COPY ["${REL_PROJECT_PATH}/*.csproj", "./"]
RUN dotnet restore
COPY ${REL_PROJECT_PATH} .
RUN dotnet build -c Debug -o /src/build

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
ARG ENTRYPOINT_ASSEMBLY
COPY --from=debugger /vsdbg /vsdbg

ENV DOTNET_STARTUP_HOOKS=/startuphooks/StartupHooks.dll
WORKDIR /startuphooks
COPY --from=startuphooks-build /startuphooks/build .

WORKDIR /app
COPY --from=app-build /src/build .

ENV DOTNET_ENTRYPOINT=$ENTRYPOINT_ASSEMBLY

ENTRYPOINT dotnet "$DOTNET_ENTRYPOINT"
