# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM --platform=$BUILDPLATFORM python:3.12-slim AS base

FROM base AS builder

RUN apt-get update \
    && apt-get install -y g++ \
    && rm -rf /var/lib/apt/lists/*

# get packages
COPY requirements.txt .
# Install grpcio separately with --no-build-isolation to avoid hanging
RUN pip install grpcio==1.59.2 --no-build-isolation
RUN pip install -r requirements.txt

FROM base
# Enable unbuffered logging
ENV PYTHONUNBUFFERED=1

# Note: libstdc++ is already included in the base image, no need to install it separately
# RUN apt-get update \
#   && apt-get install -y libstdc++ \
#   && rm -rf /var/lib/apt/lists/*

# get packages
WORKDIR /recommendationservice

# Grab packages from builder
COPY --from=builder /usr/local/lib/python3.12/ /usr/local/lib/python3.12/

# Add the application
COPY . .

# set listen port
ENV PORT="8080"
EXPOSE 8080

ENTRYPOINT ["python", "recommendation_server.py"]
