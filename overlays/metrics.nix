# Use unstable packages for metrics
final: prev: {
  inherit (final.pkgs-unstable)
    prometheus
    prometheus-node-exporter
    grafana
    grafanaPlugins;
}
