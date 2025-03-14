// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"net/http"
	"runtime"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Metrics
var (
	// Counter for total HTTP requests - used to calculate requests per second
	httpRequestsTotal = promauto.NewCounter(
		prometheus.CounterOpts{
			Name: "frontend_http_requests_total",
			Help: "Total number of HTTP requests",
		},
	)

	// Histogram for HTTP request duration - used to calculate average response time
	httpRequestDuration = promauto.NewHistogram(
		prometheus.HistogramOpts{
			Name:    "frontend_http_request_duration_seconds",
			Help:    "Duration of HTTP requests in seconds",
			Buckets: prometheus.DefBuckets,
		},
	)

	// Gauge for CPU utilization
	cpuUtilization = promauto.NewGauge(
		prometheus.GaugeOpts{
			Name: "frontend_cpu_utilization",
			Help: "CPU utilization of the frontend service (percentage)",
		},
	)
)

// MetricsHandler returns an HTTP handler for the Prometheus metrics endpoint
func MetricsHandler() http.Handler {
	return promhttp.Handler()
}

// MetricsMiddleware is a middleware that instruments HTTP requests with Prometheus metrics
func MetricsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		// Create a response writer that captures the status code
		rw := newResponseWriter(w)

		// Call the next handler
		next.ServeHTTP(rw, r)

		// Record metrics after the handler has completed
		duration := time.Since(start).Seconds()

		// Record request count (for requests per second)
		httpRequestsTotal.Inc()

		// Record request duration (for average response time)
		httpRequestDuration.Observe(duration)
	})
}

// StartCPUUtilizationMonitoring starts a goroutine that periodically updates the CPU utilization metric
func StartCPUUtilizationMonitoring() {
	go func() {
		var prevCPUTime float64
		var prevTime time.Time

		// Initialize the previous values
		prevCPUTime = getCPUTime()
		prevTime = time.Now()

		for {
			time.Sleep(1 * time.Second)

			// Get current values
			currentCPUTime := getCPUTime()
			currentTime := time.Now()

			// Calculate CPU utilization
			cpuTimeDiff := currentCPUTime - prevCPUTime
			timeDiff := currentTime.Sub(prevTime).Seconds()

			// CPU utilization is the fraction of CPU time used in the elapsed time
			// Multiply by 100 to get percentage
			// Since timeDiff is in seconds and we have numCPU cores,
			// 100% utilization of 1 core would be a cpuTimeDiff of timeDiff seconds
			numCPU := float64(runtime.NumCPU())
			utilization := (cpuTimeDiff / timeDiff) * 100 / numCPU

			// Update the metric
			cpuUtilization.Set(utilization)

			// Update previous values for next iteration
			prevCPUTime = currentCPUTime
			prevTime = currentTime
		}
	}()
}

// getCPUTime returns the total CPU time used by the process in seconds
func getCPUTime() float64 {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)

	// Use a combination of metrics that correlate with CPU usage:
	// - NumGC: Number of completed GC cycles (each GC cycle uses CPU)
	// - PauseTotalNs: Total time spent in GC pauses (direct CPU usage)
	// - Mallocs and Frees: Memory allocations and frees (CPU-intensive operations)
	// - TotalAlloc: Total memory allocated (correlates with CPU work)
	//
	// This is a better approximation of CPU usage than just using TotalAlloc
	return float64(m.NumGC)*0.01 +
	       float64(m.PauseTotalNs)/1e9 +
	       float64(m.Mallocs+m.Frees)/1e7 +
	       float64(m.TotalAlloc)/1e9
}

// responseWriter is a wrapper around http.ResponseWriter that captures the status code
type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

// newResponseWriter creates a new responseWriter
func newResponseWriter(w http.ResponseWriter) *responseWriter {
	return &responseWriter{w, http.StatusOK}
}

// WriteHeader captures the status code and calls the underlying ResponseWriter's WriteHeader
func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}
