FROM swiftdocker/swift

RUN apt-get update && \
    apt-get install -y openssl libssl-dev && \
    apt-get clean

WORKDIR /App/

ADD ./Package.swift /App/
RUN swift package fetch

ADD ./Sources /App/Sources
ADD ./Tests /App/Tests

CMD ["swift", "test"]