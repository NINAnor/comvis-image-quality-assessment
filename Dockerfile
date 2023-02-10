FROM debian:bookworm

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
        wget xxd jpegoptim python3-pdm \
        libgl1 libglib2.0 `# opencv`

WORKDIR /root
RUN wget -qO - https://github.com/frafra/BlurDetection2/archive/refs/heads/improved.tar.gz | \
        tar xz --strip-components=1
RUN pdm install --no-self --no-lock

COPY --chmod=755 evaluering.sh .
ENTRYPOINT ["pdm", "run", "./evaluering.sh"]
CMD ["/data"]
