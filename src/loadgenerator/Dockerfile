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
  && apt-get install -y wget g++ \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --prefix="/install" -r requirements.txt

FROM base

# Note: libstdc++ is already included in the base image, no need to install it separately
# RUN apt-get update \
#   && apt-get install -y libstdc++ \
#   && rm -rf /var/lib/apt/lists/*

WORKDIR /loadgen

COPY --from=builder /install /usr/local

# Add application code.
COPY locustfile.py .

# enable gevent support in debugger
ENV GEVENT_SUPPORT=True

# Use shell form for ENTRYPOINT to allow environment variable substitution and redirection
ENTRYPOINT ["sh", "-c", "locust --host=\"http://${FRONTEND_ADDR}\" --headless -u \"${USERS:-10}\" -r \"${RATE:-1}\" 2>&1"]
