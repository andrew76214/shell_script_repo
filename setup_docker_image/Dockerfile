# docker-compose down --rmi all --volumes --remove-orphans
# docker-compose up --build -d

# Use the latest Ubuntu base image
FROM ubuntu:latest

# Set environment variables
ENV ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive

# Update the system and install required tools
RUN apt-get update && \
    apt-get install -y wget bzip2 curl openssh-server libpam-google-authenticator && \
    apt-get clean

# Install Miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/miniconda3 && \
    rm /tmp/miniconda.sh && \
    echo "export PATH=/opt/miniconda3/bin:$PATH" > /etc/profile.d/miniconda.sh

# Add Miniconda to PATH
ENV PATH="/opt/miniconda3/bin:$PATH"

# Initialize Conda
RUN conda init bash

# Create a basic user
RUN useradd -m -s /bin/bash devuser && \
    echo "devuser:password123" | chpasswd && \
    mkdir -p /home/devuser/.ssh && \
    chown -R devuser:devuser /home/devuser/.ssh

# Configure SSH
RUN mkdir /run/sshd && \
    echo 'root:password' | chpasswd && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "Port 22" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AllowUsers devuser" >> /etc/ssh/sshd_config && \
    echo "ChallengeResponseAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AuthenticationMethods publickey,keyboard-interactive" >> /etc/ssh/sshd_config && \
    echo "UsePAM yes" >> /etc/ssh/sshd_config

# Set up Google Authenticator for devuser
RUN echo "auth required pam_google_authenticator.so" >> /etc/pam.d/sshd && \
    su - devuser -c "google-authenticator -t -d -f -r 3 -R 30 -W --qr-mode=NONE" < /dev/null

# Expose port 22
EXPOSE 22

# Set working directory
WORKDIR /app

# Switch to non-root user
USER devuser

# Start SSH service
CMD ["/usr/sbin/sshd", "-D"]
