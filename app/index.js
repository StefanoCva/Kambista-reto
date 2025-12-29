const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;
const NAMESPACE = process.env.NAMESPACE || "kambista-dev";
const SERVICE_NAME = process.env.SERVICE_NAME || "hello-service";
const VERSION = process.env.VERSION || "v1";

// Función helper para loguear en JSON estructurado
function log(severity, message, extra = {}) {
  const entry = {
    severity,               // INFO, ERROR, WARNING, etc.
    message,                // Mensaje principal
    serviceContext: {
      service: SERVICE_NAME,
      version: VERSION,
    },
    labels: {
      namespace: NAMESPACE,
    },
    time: new Date().toISOString(),
    ...extra,
  };

  // Cloud Logging lee lo que sale por stdout
  console.log(JSON.stringify(entry));
}

// Middleware para loguear todas las requests HTTP
app.use((req, res, next) => {
  const start = Date.now();

  res.on("finish", () => {
    const latencyMs = Date.now() - start;

    log("INFO", "http_request", {
      httpRequest: {
        requestMethod: req.method,
        requestUrl: req.originalUrl,
        status: res.statusCode,
        userAgent: req.get("user-agent"),
        remoteIp: req.ip,
        latency: `${latencyMs}ms`,
      },
    });
  });

  next();
});

// Endpoint principal
app.get("/", (req, res) => {
  log("INFO", "handling root path /");

  res.json({
    message: "Hello Kambista 🚀",
    namespace: NAMESPACE,
    path: "/",
  });
});

// Endpoint de salud (útil si luego quieres probes)
app.get("/healthz", (req, res) => {
  log("INFO", "health check OK");
  res.json({ status: "ok" });
});

// Inicio del servidor
app.listen(PORT, () => {
  log("INFO", `Server listening on port ${PORT}`);
});
