FROM microsoft/azure-cli:2.0.47

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
