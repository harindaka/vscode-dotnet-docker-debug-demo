# Install the vsdbg debugger early to leverage caching
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS debugger
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip curl \
    && curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg


FROM mcr.microsoft.com/dotnet/sdk:9.0 AS startuphooks-build
WORKDIR /startuphooks
COPY ["./*.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet build -c Debug -o /startuphooks/build -p:AssemblyName=StartupHooks

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
ARG ARG_ENTRYPOINT_ASSEMBLY=DockerDebugApp.dll
COPY --from=debugger /vsdbg /vsdbg

ENV DOTNET_STARTUP_HOOKS=/startuphooks/StartupHooks.dll
WORKDIR /startuphooks
COPY --from=startuphooks-build /startuphooks/build .

ENV ENTRYPOINT_ASSEMBLY=${ARG_ENTRYPOINT_ASSEMBLY}
WORKDIR /app
ENTRYPOINT dotnet ${ENTRYPOINT_ASSEMBLY}
