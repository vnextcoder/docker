FROM microsoft/aspnet:1.0.0-beta5

WORKDIR /app
RUN ["dnu", "restore"]
ADD . /app
ADD Startup.cs /app/
#COPY NuGet.config ~/.config/NuGet/NuGet.Config
ADD project.json /app/
ADD wwwroot /app/wwwroot

EXPOSE 5000
ENTRYPOINT ["dnx", "web"]
