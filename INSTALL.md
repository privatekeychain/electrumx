<!-- TOC -->

- [1. docker构建](#1-docker构建)

<!-- /TOC -->

# 1. docker构建

```bash
rm ./latest.tar.gz
git archive -o ./latest.tar.gz HEAD
docker build -t electrumx-pkc:latest .
```
