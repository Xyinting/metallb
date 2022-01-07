FROM --platform=linux/arm64 golang:1.16-alpine as builder

ARG TARGETOS
ARG TARGETARCH
RUN go env -w GOPROXY=https://goproxy.cn,direct
ENV FLAG="go.universe.tf/metallb/internal/version"

RUN apk update && \
    apk upgrade && \
    apk add git
RUN mkdir -p /go/src/go.universe.tf
RUN cd /go/src/go.universe.tf \
    && git clone -b v0.11 https://github.com/metallb/metallb.git
WORKDIR /go/src/go.universe.tf/metallb
RUN export commit="$(git rev-parse --short HEAD)" \
    && export branch="$(git rev-parse --abbrev-ref HEAD)" \
    && CGO_ENABLED=0 go build -a -o controller_bin -ldflags \
    "-X ${FLAG}.gitCommit=${commit} -X ${FLAG}.gitBranch=${branch}" \
    ./controller

FROM --platform=linux/arm64 alpine:latest

COPY --from=builder /go/src/go.universe.tf/metallb/controller_bin /controller

# When running as non root and building in an environment that `umask` masks out
# '+x' for others, it won't be possible to execute. Make sure all can execute,
# just in case
RUN chmod a+x /controller

ENTRYPOINT ["/controller"]
