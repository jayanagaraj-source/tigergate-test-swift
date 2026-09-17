# FIXTURE: insecure Dockerfile for IaC scanning. Do not build for real use.
FROM swift:latest

# VULN: secrets baked into image layers
ENV AWS_SECRET_ACCESS_KEY=not-a-real-aws-secret-for-scanner-testing
ARG DB_PASSWORD=Pr0dDbP4ssw0rd!

# VULN: remote ADD, curl | sh, no pinning, apt cache left behind
ADD https://example.com/install.sh /tmp/install.sh
RUN apt-get update && apt-get install -y curl sudo netcat
RUN curl -sSL https://example.com/bootstrap.sh | sh
RUN chmod -R 777 /app || true

WORKDIR /app
COPY . .

# VULN: SSH exposed, runs as root, no HEALTHCHECK
EXPOSE 22 8080
USER root
CMD ["sh", "-c", "echo tigergate-test-swift"]
