# Dockerfile using Ubuntu Linux
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        cups \
        cups-bsd \
        cups-client \
        cups-pdf \
        cups-filters \
        libcups2-dev \
        libgutenprint-dev \
        libgutenprint-doc \
        libgutenprintui2-1 \
        ghostscript \
        brlaser \
        printer-driver-hpcups \
        avahi-daemon \
        inotify-tools \
        python3 \
        python3-dev \
        build-essential \
        wget \
        rsync \
        python3-cups \
    && rm -rf /var/lib/apt/lists/*

# Expose port 631
EXPOSE 631

# Volumes for configuration and services
VOLUME /config
VOLUME /services

# Add scripts and make executable
ADD root /
RUN chmod +x /root/*

# Run script
CMD ["/root/run_cups.sh"]

# Adjust cupsd.conf as needed
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/IdleExitTimeout/#IdleExitTimeout/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf
