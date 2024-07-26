FROM steamcmd/steamcmd:ubuntu-24

ENV STEAMAPPID=380870
ENV USER=zomboiduser
ENV TZ=America/Sao_Paulo

# Set the timezone to America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
      dos2unix \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER root

# Create the app directory and set the owner to the non-root user
RUN mkdir -p /app && useradd -m -s /bin/bash zomboiduser && chown -R zomboiduser:zomboiduser /app

# Switch to the new user
USER ${USER}

# Install the latest version of Project Zomboid Server from Steam
RUN steamcmd +force_install_dir /app +login anonymous +app_update ${STEAMAPPID} validate +quit

WORKDIR /app

# Copy the entrypoint script and ensure it has execute permissions
COPY --chown=zomboiduser:zomboiduser ./scripts /app/scripts
RUN chmod +x /app/scripts/*

# Expose ports
EXPOSE 16261-16262/udp \
       27015/tcp

ENTRYPOINT ["/app/scripts/entrypoint.sh"]
