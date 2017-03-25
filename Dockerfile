FROM swiftdocker/swift:3.0.2

RUN apt-get update && \
    apt-get install -y openssl libssl-dev

WORKDIR /App/

ADD ./Package.swift /App/
RUN swift package fetch

ADD ./Sources /App/Sources
ADD ./Tests /App/Tests

ADD cert.pem /opt/ssl/cert.pem
ADD key.pem /opt/ssl/key.pem
ADD ca.pem /opt/ssl/ca.pem

CMD ["swift", "test"]