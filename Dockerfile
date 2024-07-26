FROM steamcmd/steamcmd:ubuntu-24

# Define environment variables
ENV STEAMAPPID=380870
ENV USER=zomboiduser
ENV TZ=America/Sao_Paulo

# Set the timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      dos2unix \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch to root user to perform system modifications
USER root

# Create the app directory and set ownership
RUN mkdir -p /app \
    && useradd -m -s /bin/bash $USER \
    && chown -R $USER:$USER /app

# Switch to the non-root user
USER $USER

# Install the Project Zomboid Server from Steam
RUN steamcmd +force_install_dir /app +login anonymous +app_update $STEAMAPPID validate +quit

# Set working directory
WORKDIR /app

# Copy entrypoint script and ensure it has execute permissions
COPY --chown=$USER:$USER ./scripts /app/scripts
RUN chmod +x /app/scripts/*

# Expose necessary ports
EXPOSE 16261-16262/udp \
       27015/tcp

# Set the entrypoint script
ENTRYPOINT ["/app/scripts/entrypoint.sh"]