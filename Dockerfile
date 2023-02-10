FROM debian:bookworm

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
        wget xxd jpegoptim python3-pdm \
        libgl1 libglib2.0 `# opencv`

WORKDIR /root
COPY BlurDetection2/pyproject.toml BlurDetection2/pdm.lock .
RUN pdm install --no-self --no-lock
COPY BlurDetection2/blur_detection blur_detection
COPY BlurDetection2/process.py .

COPY --chmod=755 evaluering.sh .
ENTRYPOINT ["pdm", "run", "./evaluering.sh"]
CMD ["/data"]
