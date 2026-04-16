# Analyse & Gegenüberstellung: k3s vs. Talos + Hetzner Cloud Terraform Module

> **Stand**: April 2026 | **Quellen**: Offizielle Dokumentationen, GitHub-Repos, Releases, Issues

---

## Teil 1: k3s vs. Talos Linux – Allgemeiner Vergleich

### Architektur-Philosophie

| Aspekt | k3s | Talos Linux |
|--------|-----|-------------|
| **Typ** | Lightweight Kubernetes-Binary | Immuates, API-gesteuertes Kubernetes-Betriebssystem |
| **Läuft auf** | Bestehendem Linux (Ubuntu, Debian, RHEL, etc.) | Ersetzt das OS komplett (bare metal / VM) |
| **Root Filesystem** | Beschreibbar (traditionell) | Read-only SquashFS (immutable) |
| **Konfiguration** | CLI-Flags, Config-Files, Env-Vars | Deklarative Machine Config (YAML) via gRPC-API |
| **Management** | SSH, systemd, traditionelle Linux-Tools | `talosctl` CLI + API (**kein SSH, keine Shell**) |
| **Package Manager** | Host-OS Package Manager | Keiner – immutables Image |
| **Binary/OS-Größe** | < 100 MB Binary | < 100 MB OS + Partitionen |

### Hochverfügbarkeit (HA)

| Aspekt | k3s | Talos Linux |
|--------|-----|-------------|
| **Datastore-Optionen** | SQLite (Single), **etcd**, MySQL, PostgreSQL, MariaDB | **Nur etcd** |
| **Min. HA-Nodes** | 2+ (externe DB) oder 3+ (embedded etcd) | 3+ (nur ungerade Zahlen: 1, 3 oder 5) |
| **etcd Quorum** | Unterstützt etcd UND SQL | Nur etcd (2-Nodes sind *schlechter* als 1!) |
| **Upgrade-Sicherheit** | Manuelle Koordination nötig | **Automatischer Quorum-Schutz** – Talos verhindert gleichzeitige CP-Upgrades |
| **LB für API** | Empfohlen, aber manuell | Floating IP / Alias IP / External LB, integriert |

### Sicherheit

| Aspekt | k3s | Talos Linux |
|--------|-----|-------------|
| **OS-Typ** | Traditionell (mutabel) | Immuable Linux (read-only) |
| **Shell-Zugang** | SSH verfügbar | **Kein SSH** – nur API |
| **Config Drift** | Möglich | **Unmöglich** – immutable |
| **Attack Surface** | Volles Linux OS + K3s | Minimal (nur Kubernetes-Komponenten) |
| **Secure Boot** | Abhängig vom Host-OS | **Native Unterstützung** |
| **Kernel Hardening** | Standard Linux | **KSPP zwingend enforced** (slab_nomerge, pti=on, etc.) |
| **CIS Benchmark** | Ja (v1.9, v1.10, v1.11) | Kein formaler Benchmark, aber aligned |

### Ressourcen-Bedarf

| Rolle | k3s | Talos Linux |
|-------|-----|-------------|
| **Control Plane Min.** | 2 CPU / 2 GB RAM | 2 CPU / 2 GiB RAM |
| **Worker Min.** | 1 CPU / **512 MB** RAM | 1 CPU / **1 GiB** RAM |
| **Control Plane Empfohlen** | 2-4 CPU / 4 GB RAM | 4 CPU / 4 GiB RAM |
| **Worker Empfohlen** | 1-2 CPU / 1 GB RAM | 2 CPU / 2 GiB RAM |
| **OS Disk** | OS-abhängig (SSD empfohlen) | 10 GiB Min., 100 GiB empfohlen |

### Mitgelieferte Features ("Batteries Included")

| Komponente | k3s | Talos Linux |
|-----------|-----|-------------|
| **CoreDNS** | ✅ Bundled | ✅ Bundled |
| **Ingress Controller** | ✅ Traefik (bundled) | ❌ Selber deployen |
| **LoadBalancer** | ✅ ServiceLB (bundled) | ❌ Selber deployen |
| **Network Policy** | ✅ Kube-router (bundled) | CNI-abhängig |
| **Storage Provisioner** | ✅ Local-path (bundled) | ❌ Selber deployen |
| **Metrics Server** | ✅ Bundled | ❌ Selber deployen |
| **CNI** | ✅ Flannel (default) | ✅ Flannel (default), Cilium/Calico support |
| **Image Registry Mirror** | ✅ Spegel (P2P, bundled) | ❌ Selber deployen |
| **Container Runtime** | Containerd 2.0 | Containerd 2.0 |

### Upgrade-Mechanismus

| Aspekt | k3s | Talos Linux |
|--------|-----|-------------|
| **Methode** | Manuell (Binary) oder automatisiert (system-upgrade-controller) | **API-gesteuert** (`talosctl upgrade`) |
| **Rollback** | Manuell (`--rollback` Flag) | **Automatisch** (A/B Image Scheme) + manuell |
| **Dual-Boot** | Nein | **Ja** (A/B Image Scheme) |
| **K8s Upgrade** | Zusammen mit Binary | **Separat vom OS-Upgrade** |
| **CP-Sicherheit** | Manuelle Koordination | **Automatischer Quorum-Schutz** |

### Community & Kommerzieller Support

| Aspekt | k3s | Talos Linux |
|--------|-----|-------------|
| **GitHub Stars** | **32.766** | 10.249 |
| **Forks** | 2.642 | 810 |
| **Contributors** | 280 | 40+ |
| **Lizenz** | Apache 2.0 | MPL-2.0 (Core) + BSL-1.1 (Omni) |
| **Firma** | **SUSE/Rancher** | **Sidero Labs** |
| **Kommerzieller Support** | SUSE Enterprise Subscriptions | Sidero Labs: $10/Monat (Hobby) bis $100/Node/Monat (Enterprise) |
| **SLAs** | Über SUSE verfügbar | Startup/Enterprise/Edge-Pläne mit SLAs |
| **Air-gapped Support** | Community-Guides | Enterprise-Pläne inkludieren Air-gapped |
| **Support-Zeitraum** | Mehrere Minor-Versionen | 18 Monate Release-Support |

### Fazit k3s vs. Talos

| Kriterium | Gewinner | Begründung |
|-----------|----------|------------|
| **Ressourceneffizienz** | 🏆 k3s | 512 MB RAM für Worker |
| **Sicherheit** | 🏆 Talos | Immutable, kein SSH, API-only, Secure Boot |
| **Batteries Included** | 🏆 k3s | Ingress, LB, Storage, Metrics vorinstalliert |
| **Automatisches Rollback** | 🏆 Talos | A/B Image Scheme |
| **Community-Größe** | 🏆 k3s | 3x mehr Stars, 7x mehr Contributors |
| **Enterprise Support** | 🤝 Gleichwertig | SUSE vs. Sidero Labs |
| **Bare Metal / Edge** | 🏆 Talos | Nativ für Bare Metal designed |
| **Einfachheit (Setup)** | 🏆 k3s | Ein Binary, läuft überall |
| **Config Drift Prävention** | 🏆 Talos | Immutable OS |

---

## Teil 2: Hetzner Cloud Terraform Module – Gegenüberstellung

> **WICHTIG**: Beide Module nutzen **Talos Linux** als Basis – nicht k3s!

### Übersicht

| Aspekt | hcloud-k8s/terraform-hcloud-kubernetes | hcloud-talos/terraform-hcloud-talos |
|--------|---------------------------------------|-------------------------------------|
| **GitHub URL** | [Link](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes) | [Link](https://github.com/hcloud-talos/terraform-hcloud-talos) |
| **K8s Distribution** | **Talos Linux** | **Talos Linux** |
| **GitHub Stars** | **626** | 326 |
| **Forks** | 65 | 60 |
| **Contributors** | 19 | 17 |
| **Erstellt** | Älter (v3.x-Serie) | März 2024 |
| **Aktuelle Version** | **v3.30.2** | v3.2.3 |
| **Lizenz** | (nicht explizit genannt) | **MIT** |
| **Haupt-Maintainer** | M4t7e | Marcel Richter (@mrclrchtr) |
| **Offene Issues** | **18** | **13** |

### Hochverfügbarkeit (HA)

| Feature | hcloud-k8s | hcloud-talos |
|---------|------------|-------------|
| **HA Control Plane** | ✅ 3+ CP-Nodes empfohlen | ✅ 1, 3 oder 5 CP-Nodes |
| **Placement Groups** | ✅ Nodes auf verschiedenen Hosts | ✅ Nodes auf verschiedenen Hosts |
| **Embedded etcd** | ✅ In Talos integriert | ✅ In Talos integriert |
| **etcd Backup** | ✅ **Talos Backup** (S3-kompatibel) | ❌ Nicht integriert |
| **Cluster Autoscaler** | ✅ **Integriert** (Hetzner nodepools) | ❌ Nicht integriert |
| **Floating IP (Public VIP)** | ✅ | ✅ Für stabilen öffentlichen API-Endpunkt |
| **Private VIP (Alias IP)** | ❓ Nicht dokumentiert | ✅ `.100` im Node-Subnet |
| **KubePrism** | ❓ | ✅ Interner API-Proxy `127.0.0.1:7445` |
| **Multihoming** | ❓ | ✅ etcd + kubelet auf Public + Private IP |

**Bewertung HA**: 
- **hcloud-k8s** bietet mehr Out-of-the-box (Autoscaler, etcd Backup)
- **hcloud-talos** nutzt mehr Talos-spezifische Features (KubePrism, Multihoming, Alias IP)

### Private Cluster (nur Public IP für LB/Gateway)

| Feature | hcloud-k8s | hcloud-talos |
|---------|------------|-------------|
| **Nodes ohne Public IP** | ✅ **Unterstützt** (`talos_public_ipv4_enabled = false`) | ❌ **NICHT unterstützt** – alle Nodes brauchen Public IPs |
| **Nur LB mit Public IP** | ✅ **Möglich** | ❌ **Aktuell nicht möglich** |
| **Private Network Access** | ✅ `cluster_access = "private"` | ✅ Private Network vorhanden, aber Public IPs erforderlich |
| **Load Balancer intern** | ✅ `enable_public_interface` steuerbar | ❌ LB muss extern verwaltet werden |
| **Gateway-Modus** | ✅ | ❌ Offen als Issue [#447](https://github.com/hcloud-talos/terraform-hcloud-talos/issues/447) |
| **VPN Site-to-Site** | ❓ Nicht dokumentiert | ❌ Offen als Issue [#419](https://github.com/hcloud-talos/terraform-hcloud-talos/issues/419) |

**Bewertung Private Cluster**: 
- 🏆 **hcloud-k8s** ist klar führend – vollständige Private-Cluster-Unterstützung
- **hcloud-talos** hat hier eine signifikante Lücke (alle Nodes brauchen Public IPs)

### Mitgelieferte Features (Coupled / Bundled)

| Komponente | hcloud-k8s | hcloud-talos |
|-----------|------------|-------------|
| **Cilium CNI** | ✅ Default, mit WireGuard/IPSec Encryption | ✅ Default, mit WireGuard Encryption, KubeProxy-Replacement |
| **HCCM (Hetzner CCM)** | ✅ Integriert | ✅ Integriert |
| **Talos CCM** | ✅ Integriert | ✅ Integriert |
| **HCSI (Hetzner CSI)** | ✅ **Integriert** | ❌ **Nicht integriert** |
| **Longhorn** | ✅ **Optional integriert** | ❌ Nicht integriert |
| **Ingress NGINX** | ✅ Integriert (**⚠️ Deprecated, wird in v5 entfernt ~Q2/Q3 2026**) | ❌ Nicht integriert |
| **Cert Manager** | ✅ **Integriert** | ❌ Nicht integriert |
| **Cluster Autoscaler** | ✅ **Integriert** | ❌ Nicht integriert |
| **Metrics Server** | ✅ **Integriert** | ❌ Nicht integriert |
| **Prometheus Operator CRDs** | ✅ Integriert | ✅ Optional |
| **Talos Backup (etcd)** | ✅ **S3-kompatibel integriert** | ❌ Nicht integriert |
| **Gateway API** | ✅ Über Cilium | ❌ Offen als Issue |
| **Tailscale Extension** | ❓ | ✅ Optional als System Extension |
| **GitOps Handoff** | ❓ | ✅ Cilium + HCCM können nach Bootstrap deaktiviert werden (für ArgoCD/Flux) |
| **Custom Registries** | ❓ | ✅ Konfigurierbar |
| **Kernel Module Loading** | ❓ | ✅ Konfigurierbar |

**Bewertung Bundled Features**:
- 🏆 **hcloud-k8s** liefert deutlich mehr mit: CSI, Longhorn, Cert Manager, Autoscaler, Metrics, Backup, Ingress
- **hcloud-talos** ist minimalistischer, bietet dafür mehr Talos-spezifische Konfigurationsoptionen

### GitHub Issues – Kritische Erkenntnisse

#### hcloud-k8s/terraform-hcloud-kubernetes (18 offen)

| Issue | Typ | Schwere |
|-------|-----|---------|
| [#383](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/issues/383) | Bug: Network CIDR Auto-Calculation (/11 statt korrektem Bereich für K8s 1.33+) | ⚠️ Mittel |
| [#351](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/issues/351) | Bug: Deadlock bei neuen Worker-Nodes während `upgrade_kubernetes` | ⚠️ Mittel |
| [#367](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/issues/367) | Bug: Health Check Data Sources blockieren destroy/apply bei unreachable Cluster | ⚠️ Mittel |
| [#330](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/issues/330) | Bug: Etcd Member stuck als Learner beim Bootstrap | ⚠️ Mittel |
| [#321](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/issues/321) | Bug: Autoscaler Nodes im falschen Subnet in Shared Networks | 🔴 Hoch |
| [#278](https://github.com/hcloud-k8s/terraform-hcloud-kubernetes/issues/278) | Bug: Autoscaler Node wird beim Teardown nicht gelöscht | ⚠️ Mittel |

#### hcloud-talos/terraform-hcloud-talos (13 offen)

| Issue | Typ | Schwere |
|-------|-----|---------|
| [#447](https://github.com/hcloud-talos/terraform-hcloud-talos/issues/447) | Feature: Gateway/Private API Access Mode | 🔵 Feature Request |
| [#413](https://github.com/hcloud-talos/terraform-hcloud-talos/issues/413) | Feature: Public IPv4 vermeiden, über LB routen | 🔵 Feature Request |
| [#419](https://github.com/hcloud-talos/terraform-hcloud-talos/issues/419) | Feature: VPN Site-to-Site Support | 🔵 Feature Request |
| [#348](https://github.com/hcloud-talos/terraform-hcloud-talos/issues/348) | Frage: Highly-available Control Plane LB | 🔵 Frage |
| [#278](https://github.com/hcloud-talos/terraform-hcloud-talos/issues/278) | Feature: Cilium Value Override (7 Kommentare) | 🔵 Feature Request |
| [#60](https://github.com/hcloud-talos/terraform-hcloud-talos/issues/60) | Feature: In-place Upgrade via Talos Provider | 🔵 Feature Request |
| [#18](https://github.com/hcloud-talos/terraform-hcloud-talos/issues/18) | Feature: Multi-Region Cluster (6 Kommentare) | 🔵 Feature Request |

**Bewertung Issues**:
- **hcloud-k8s** hat mehr **Bug-Reports** (tatsächliche Probleme im Betrieb)
- **hcloud-talos** hat mehr **Feature Requests** (aktive Community-Wünsche)
- Beide Projekte reagieren aktiv auf Issues

### Roadmap & Geplante Features

#### hcloud-k8s Roadmap
| Feature | Status | Zeitraum |
|---------|--------|----------|
| Gateway API Support | ✅ Abgeschlossen | Abgeschlossen |
| Ingress NGINX Deprecation (v4) | ⚠️ Deprecated | ~Q1 2026 |
| Ingress NGINX Removal (v5) | 📅 Geplant | ~Q2/Q3 2026 |
| K8s 1.33+ CIDR Fix | 🔧 Offen | Offen |

#### hcloud-talos Roadmap
| Feature | Status | Zeitplan |
|---------|--------|----------|
| Gateway/Private API Access (#447) | 📋 In Diskussion | Offen |
| Public IPv4 Reduction (#413) | 📋 In Diskussion | Offen |
| VPN Site-to-Site (#419) | 📋 In Diskussion | Offen |
| Cilium Gateway API (#281) | 📋 In Diskussion | Offen |
| Multi-Region Support (#18) | 📋 In Diskussion | Offen |

**Bewertung Roadmap**:
- **hcloud-k8s** hat eine klarere Roadmap mit Zeitlinien
- **hcloud-talos** hat mehr offene Feature-Wünsche, aber weniger formale Planung

### Kommerzieller Support

| Aspekt | hcloud-k8s | hcloud-talos |
|--------|------------|-------------|
| **Kommerzieller Support** | ❌ Nein | ❌ Nein |
| **Funding** | GitHub Sponsors | GitHub Sponsors + Buy Me a Coffee |
| **SLA** | ❌ Kein SLA | ❌ Kein SLA – "Sponsorship ≠ Support Contract" |
| **Backing-Firma** | Keine (Community-Projekt) | Keine (Einzelentwickler, Octalog) |
| **Support-Kanäle** | GitHub Issues | GitHub Issues + GitHub Discussions |
| **Abhängigkeitsrisiko** | ⚠️ **Hoch** – 1 aktiver Haupt-Maintainer | ⚠️ **Hoch** – 1 Entwickler |

### LinkedIn / Marketing / Werbung

| Aspekt | hcloud-k8s | hcloud-talos |
|--------|------------|-------------|
| **LinkedIn-Präsenz** | ❌ Keine Company Page | ❌ Keine Company Page |
| **Aktives Marketing** | ❌ Keines | ❌ Keines |
| **Wachstum** | Organisch (GitHub only) | Organisch (GitHub only) |
| **Blog-Aktivität** | Community-Tutorials (z.B. OneUptime) | Keine bekannt |
| **Social Media** | Keine bekannt | Keine bekannt |

---

## Teil 3: Gesamtbewertung & Empfehlung

### Scoring-Matrix

| Kriterium | hcloud-k8s | hcloud-talos | Gewichtung |
|-----------|:----------:|:------------:|:----------:|
| **Hochverfügbarkeit** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Hoch |
| **Private Cluster** | ⭐⭐⭐⭐⭐ | ⭐⭐ | Sehr Hoch |
| **Bundled Features** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Mittel |
| **Cilium Integration** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Hoch |
| **HCCM Integration** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Hoch |
| **Reife & Stabilität** | ⭐⭐⭐⭐ | ⭐⭐⭐ | Hoch |
| **Community** | ⭐⭐⭐⭐ (626 Stars) | ⭐⭐⭐ (326 Stars) | Mittel |
| **Roadmap-Klarheit** | ⭐⭐⭐⭐ | ⭐⭐ | Niedrig |
| **Dokumentation** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Hoch |
| **GitOps-Tauglichkeit** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Hoch |
| **Kommerzieller Support** | ⭐ | ⭐ | Niedrig |
| **Talos-spezifische Features** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Mittel |
| **Wartungsaktivität** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Hoch |

### Empfehlung nach Use-Case

#### 🏆 hcloud-k8s/terraform-hcloud-kubernetes – Empfohlen für:

- **Private Cluster** – Vollständige Unterstützung, Nodes ohne Public IP
- **Komplett-Paket gesucht** – CSI, Longhorn, Cert Manager, Autoscaler, Backup alles integriert
- **Produktiv-Umgebungen** – Mehr Features = weniger manuelle Arbeit
- **Teams ohne tiefes Kubernetes-Wissen** – Mehr vorinstalliert, weniger Konfiguration

#### 🏆 hcloud-talos/terraform-hcloud-talos – Empfohlen für:

- **Maximale Talos-Ausnutzung** – KubePrism, Multihoming, Machine Config Patches, System Extensions
- **GitOps-Workflows** – Sauberer Bootstrap → Handoff an ArgoCD/Flux
- **Minimalistischer Ansatz** – Nur was nötig ist, alles andere selbst kontrollieren
- **ARM + x86 Mixed Workloads** – Explizite Architektur-Unterstützung
- **Entwickler mit tiefem Kubernetes-Verständnis**

### Risikoanalyse

| Risiko | hcloud-k8s | hcloud-talos |
|--------|------------|-------------|
| **Bus Factor** | 🔴 1 aktiver Maintainer (M4t7e) | 🔴 1 Entwickler (Marcel Richter) |
| **Private Cluster Blocker** | 🟢 Gelöst | 🔴 Offen (Issue #413, #447) |
| **Ingress NGINX Removal** | 🟡 v5 Breaking Change (~Q3 2026) | 🟢 Nicht relevant |
| **Multi-Region** | 🔴 Nicht unterstützt | 🔴 Nicht unterstützt |
| **IPv6 Dual Stack** | 🟡 Möglicherweise limitiert | 🔴 Talos unterstützt kein IPv6 Dual Stack |
| **Kommerzieller SLA** | 🔴 Nicht verfügbar | 🔴 Nicht verfügbar |

---

---

## Teil 4: Deep Dive – Cilium / Networking

### Cilium Version & Basiskonfiguration

| Einstellung | hcloud-k8s | hcloud-talos |
|-------------|------------|-------------|
| **Cilium Version** | **1.18.7** 🏆 | 1.16.2 |
| **IPAM Mode** | kubernetes | kubernetes |
| **Routing Mode** | native (konfigurierbar) | native (hardcodiert) |
| **Verschlüsselung** | ✅ **Default: WireGuard aktiviert**, IPSec optional | ❌ **Default: Deaktiviert**, nur WireGuard möglich |
| **BPF Masquerade** | ✅ Aktiviert (mit KubeProxy-Replacement) | ❌ **Deaktiviert** |
| **Datapath Mode** | Konfigurierbar (veth/netkit/netkit-l2) | Default (veth) |
| **k8sServiceHost** | KubePrism | KubePrism (`127.0.0.1`) |

### Gateway API

| Feature | hcloud-k8s | hcloud-talos |
|---------|------------|-------------|
| **Gateway API** | ✅ **Voll unterstützt** (deaktivierbar) | ❌ Nicht konfiguriert |
| **Proxy Protocol** | ✅ Aktivierbar | ❌ Nicht verfügbar |
| **ALPN Support** | ✅ | ❌ |
| **GatewayClass** | ✅ Automatisch erstellt | ❌ |

### KubeProxy-Replacement

| Feature | hcloud-k8s | hcloud-talos |
|---------|------------|-------------|
| **KubeProxy ersetzt** | ✅ Vollständig + BPF Masquerade | ⚠️ Teilweise (BPF Masquerade **deaktiviert**) |
| **Healthz Bind Addr** | ✅ `0.0.0.0:10256` | Nicht konfiguriert |
| **NoConntrack Rules** | ✅ Bei native routing | Nicht konfiguriert |

> **⚠️ WICHTIG**: hcloud-talos hat `bpf.masquerade = "false"` – das kann **Egress Gateway** und andere Features beeinträchtigen!

### Hubble Integration

| Feature | hcloud-k8s | hcloud-talos |
|---------|------------|-------------|
| **Hubble** | ✅ Verfügbar (deaktiviert default) | ❌ Deaktiviert, nicht konfiguriert |
| **Hubble Relay** | ✅ Verfügbar | ❌ Nicht verfügbar |
| **Hubble UI** | ✅ Verfügbar | ❌ Nicht verfügbar |

### Load Balancer Acceleration (XDP)

| Feature | hcloud-k8s | hcloud-talos |
|---------|------------|-------------|
| **LB Acceleration** | ✅ `"native"` (XDP) | ⚠️ `"best-effort"` bei Tailscale, sonst `"native"` |
| **Begründung hcloud-talos** | – | Tailscale unterstützt kein XDP → Fallback auf best-effort |

### Observability

| Feature | hcloud-k8s | hcloud-talos |
|---------|------------|-------------|
| **Prometheus Metrics** | ✅ `interval: "15s"` | ✅ (aber ServiceMonitor deaktiviert) |
| **ServiceMonitor** | ✅ Konfigurierbar | ❌ Deaktiviert |
| **Operator Metrics** | ✅ | ❌ Deaktiviert |

**Fazit Cilium**: 🏆 **hcloud-k8s** bietet eine deutlich reifere Cilium-Integration mit höherer Version, aktiver Verschlüsselung, Gateway API, Hubble und vollem KubeProxy-Replacement.

---

## Teil 5: Deep Dive – Private Cluster Architektur

### Funktionsweise: hcloud-k8s Private Cluster

```
                          ┌──────────────────────┐
                          │      Internet        │
                          └──────────┬───────────┘
                                     │ Public IP
                          ┌──────────▼───────────┐
                          │    Gateway VM        │
                          │  (NAT/Bastion/VPN)   │
                          │  Public: 203.0.x.x   │
                          │  Private: 10.0.0.2   │
                          └──────────┬───────────┘
                                     │
              ┌──────────────────────▼──────────────────────┐
              │     Hetzner Private Network (10.0.0.0/16)   │
              │     Gateway: 10.0.0.1 (Hetzner reserviert)  │
              │     Route: 0.0.0.0/0 → 10.0.0.2            │
              ├──────────┬──────────┬───────────────────────┤
              │ CP Subnet│ LB Subnet│ Worker Subnet         │
              │ 10.0.64  │ 10.0.96  │ 10.0.128+            │
              │ CP1 CP2  │ LB (priv)│ W1  W2  W3           │
              │ CP3      │          │                       │
              └──────────┴──────────┴───────────────────────┘
```

**Key Terraform-Konfiguration (hcloud-k8s)**:
```hcl
# Nodes ohne Public IP
talos_public_ipv4_enabled  = false
talos_public_ipv6_enabled  = false

# Private Network Access
cluster_access             = "private"

# Internet-Access via Gateway
talos_extra_routes         = ["0.0.0.0/0"]

# Load Balancer: nur privat
enable_public_interface    = false
```

### Funktionsweise: hcloud-talos – Warum Private Cluster NICHT möglich

**Problem**: `ipv4_enabled = true` ist **hardcodiert** in `server.tf`:
```hcl
# server.tf (hcloud-talos) – HARDCODED
public_net {
  ipv4_enabled = true  # ← Kann NICHT deaktiviert werden!
  ipv6_enabled = var.enable_ipv6
}
```

**Was fehlt** (laut Issues #413, #447):
1. Variable zum Deaktivieren von Public IPs
2. Netzwerk-Routing durch Gateway-VM
3. Talos Network Interface Anpassung (eth0/eth1 Swap)
4. Load Balancer mit privatem Interface only

### Hetzner Cloud Networking Architektur

| Aspekt | Detail |
|--------|--------|
| **Typ** | Layer 3 (IP) Routed Network |
| **Gateway** | Erste IP im Netzwerk (10.0.0.1) – von Hetzner reserviert |
| **Routing** | Eigene Routes möglich: `0.0.0.0/0 → 10.0.0.2` (Gateway-VM) |
| **Traffic** | Kostenlos zwischen Servern im selben Network |
| **Subnetze** | Mehrere Subnetze pro Network möglich |
| **Cloud Network** | Für Cloud-zu-Cloud (Empfohlen für K8s) |
| **vSwitch** | Layer 2, für Cloud+Dedicated Hybrid |

**Gateway-VM Setup (für Private Cluster)**:
```bash
# Auf der Gateway-VM (Debian/Ubuntu)
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth1 -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
```

**Fazit Private Cluster**: 🏆 **hcloud-k8s** ist die **einzige Option** für echte Private Cluster. hcloud-talos kann das aktuell nicht und es ist offen (Issue #447).

---

## Teil 6: Deep Dive – Upgrade-Prozesse

### ⚠️ MASSIVER UNTERSCHIED BEI UPGRADES

| Feature | hcloud-k8s | hcloud-talos |
|---------|------------|-------------|
| **Automatisches Talos OS Upgrade** | ✅ **Voll automatisiert** via `terraform_data` | ❌ **NICHT möglich** – `lifecycle { ignore_changes }` |
| **Automatisches K8s Upgrade** | ✅ **Voll automatisiert** via `talosctl upgrade-k8s` | ❌ **Manuell** – `talosctl upgrade-k8s` selbst ausführen |
| **Rolling Strategy** | ✅ Node-by-Node mit Health Checks | ❌ Manuell implementieren |
| **Health Checks zwischen Upgrades** | ✅ `talos_wait_for_health` integriert | ❌ Manuell |
| **etcd Quorum-Schutz** | ✅ Automatisch (1 CP nach dem anderen) | ❌ Manuell sicherstellen |
| **Config Changes (apply-config)** | ✅ `talos_machine_configuration_apply` Ressource | ❌ Manuell via `talosctl apply-config` |
| **A/B Rollback** | ✅ TalOS-Ebene (automatisch) | ✅ TalOS-Ebene (automatisch) |
| **Version Compatibility Matrix** | ✅ Im README dokumentiert | ❌ User muss selbst prüfen |

### Wie hcloud-k8s Upgrades macht

```
terraform apply (mit geänderter Version)
    │
    ├─ Phase 1: terraform_data.upgrade_control_plane
    │   ├─ CP Node 1 → talosctl upgrade → health check ✓
    │   ├─ CP Node 2 → talosctl upgrade → health check ✓
    │   └─ CP Node 3 → talosctl upgrade → health check ✓
    │
    ├─ Phase 2: terraform_data.upgrade_worker
    │   ├─ Worker 1 → talosctl upgrade → health check ✓
    │   ├─ Worker 2 → talosctl upgrade → health check ✓
    │   └─ ...
    │
    └─ Phase 3: terraform_data.upgrade_kubernetes
        └─ talosctl upgrade-k8s --to 1.35.0
```

**Key**: Alles passiert automatisch bei `terraform apply` – einfach Version ändern und apply!

### Wie hcloud-talos Upgrades macht (oder nicht macht)

```hcl
# server.tf (hcloud-talos) – DAS PROBLEM:
lifecycle {
  ignore_changes = [
    user_data,   # ← Talos Machine Config wird IGNORIERT
    image,       # ← Image-Änderungen werden IGNORIERT
    iso          # ← ISO-Änderungen werden IGNORIERT
  ]
}
```

**Folge**: Wenn man `talos_version` oder `kubernetes_version` ändert und `terraform apply` ausführt:
- Terraform erkennt **keine Änderungen** (wegen `ignore_changes`)
- **NICHTS passiert** automatisch
- User muss **manuell** `talosctl upgrade` und `talosctl upgrade-k8s` ausführen

**Manuelle Upgrade-Schritte für hcloud-talos**:
```bash
# 1. Talos OS Upgrade (jeden Node einzeln!)
talosctl upgrade --nodes 10.0.1.11 --image factory.talos.dev/.../v1.12.5
# Warten bis healthy...
talosctl upgrade --nodes 10.0.1.12 --image factory.talos.dev/.../v1.12.5
# Warten bis healthy...
# (für jeden Worker wiederholen)

# 2. Kubernetes Upgrade
talosctl upgrade-k8s --nodes 10.0.1.11 --to 1.35.0
```

### Upgrade Best Practices (für beide Module)

| Check | Beschreibung |
|-------|-------------|
| **Pre-Flight** | `kubectl get nodes` – alle Ready? `talosctl etcd status` – quorum OK? |
| **Backup** | `talosctl etcd snapshot` vor jedem Upgrade |
| **Canary** | Erst 1 CP Node upgraden, 24-48h beobachten |
| **Sequenz** | TalOS CP → K8s CP → TalOS Worker → K8s Worker |
| **Rollback** | A/B Scheme automatisch, manuell: `talosctl upgrade --image <old-version>` |

**Fazit Upgrades**: 🏆 **hcloud-k8s** gewinnt hier **deutlich** – voll automatisierte, sichere Upgrades mit Health Checks und etcd-Quorum-Schutz. hcloud-talos erfordert komplettes manuelles Upgrade-Management.

---

## Teil 7: Deep Dive – Risiko-Mitigation (Bus Factor = 1)

### Risiko-Bewertung

| Risiko | hcloud-k8s | hcloud-talos |
|--------|------------|-------------|
| **Aktiver Maintainer** | M4t7e (sehr aktiv) | Marcel Richter (aktiv) |
| **Beitragende** | 19 gesamt | 17 gesamt, 20 Forks |
| **Letzter Commit** | März 2026 ✅ | März 2026 ✅ |
| **Release-Frequenz** | Sehr hoch (v3.30.x) | Hoch (v3.2.x) |
| **Bus Factor** | ⚠️ ~1 (1 aktiver Haupt-Maintainer) | ⚠️ ~1 (aber 20 Contributors) |
| **Abandonment-Risiko** | Mittel (GitHub Sponsors) | Mittel (GitHub Sponsors + BMC) |

### Mitigation-Strategien

#### 1. Forking (Empfohlen)

```
Upstream Repo ──→ Euer Fork ──→ Produktion
     │                │
     │                ├─ Eigene Patches
     │                ├─ Security Fixes
     │                └─ Custom Extensions
     │
     └─ Wöchentlicher Sync (GitHub Actions)
```

**Terraform Module Source nach Fork**:
```hcl
module "kubernetes" {
  source = "git::https://github.com/euer-org/terraform-hcloud-kubernetes.git?ref=v3.30.2-fork.1"
}
```

**Was lokal anpassen vs. Upstream beitragen**:

| Lokal anpassen | Upstream beitragen |
|----------------|-------------------|
| Eigene CIDRs, Node Types | Bug Fixes |
| Firmen-spezifische Security | Security Vulnerabilities |
| Monitoring-Integration | Version Compatibility |
| Backup/DR Konfiguration | Dokumentation |
| GitOps Tooling | Performance |

#### 2. Sidero Labs Kommerzieller Support (Talos)

| Plan | Preis/Node/Monat | Min. Nodes | SLA |
|------|------------------|------------|-----|
| **Hobby** | $10 | – | Community |
| **Startup** | $25 | 10 | Business Hours |
| **Business** | $60 | 10 | SLA + Account Manager |
| **Enterprise** | $100 | 10 | 24/7, Private Slack |

**Beispiel**: 20 Nodes Business = $1.200/Monat

#### 3. Alternativen bei Module-Failure

| Alternative | Typ | Aufwand | Support |
|-------------|-----|---------|---------|
| **Eigenes Modul** (Talos Provider direkt) | Custom | 2-4 Wochen Initial | Self |
| **k3s + Custom TF** | Alternative | 1-2 Wochen | Community |
| **RKE2 auf Hetzner** | Enterprise | 1-2 Wochen | Rancher/SUSE |
| **Cloudfleet** | Managed | 1-2 Tage | Cloudfleet |
| **SysEleven MetaKube** | Managed (DACH) | 2-4 Wochen | SysEleven (BSI) |
| **Hetzner Managed K8s** | ❌ Nicht verfügbar | – | – |

#### 4. Break-Glass Procedure (Notfall-Plan)

```
┌─────────────────────────────────────┐
│ P0/P1 Incident erkannt              │
│ Normaler Prozess blockiert          │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ 2-Personen-Freigabe (5 Min)         │
│ On-Call Manager + Security Lead     │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ Emergency Credentials (5 Min)       │
│ Hardware Token aus Secure Cabinet   │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ Direkte Cluster-Operationen         │
│ talosctl upgrade/apply-config       │
│ hcloud API direkt                   │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ Credential Rotation (sofort danach) │
│ Post-Incident Review (24h)          │
└─────────────────────────────────────┘
```

#### 5. Automatisches Monitoring (GitHub Actions)

```yaml
# Wöchentlicher Check
- Upstream: Neue Releases verfügbar?
- Maintainer: Letzter Commit < 14 Tage?
- Issues: Kritische Bugs offen?
- Dependencies: Security Vulnerabilities?
```

### Empfohlene Gesamtstrategie

| Zeitraum | Aktion | Aufwand |
|----------|--------|---------|
| **Diese Woche** | Fork erstellen, Break-Glass Procedure, interne Doku | 2-3 Tage |
| **Nächstes Quartal** | Staging-Umgebung für Upgrade-Tests, Sidero Labs Support evaluieren | 1-2 Wochen |
| **Nächstes Jahr** | Bei sinkender Upstream-Aktivität: Eigenes Modul oder Managed Service evaluieren | Fallabhängig |

---

## Gesamtfazit (aktualisiert mit Deep Dives)

### Endgültige Scoring-Matrix

| Kriterium | hcloud-k8s | hcloud-talos | Kommentar |
|-----------|:----------:|:------------:|-----------|
| **Cilium Integration** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Version 1.18.7 vs 1.16.2, Gateway API, Hubble |
| **Private Cluster** | ⭐⭐⭐⭐⭐ | ⭐ | Voll unterstützt vs. gar nicht möglich |
| **Upgrade-Automatisierung** | ⭐⭐⭐⭐⭐ | ⭐⭐ | Vollautomatisch vs. komplett manuell |
| **Hochverfügbarkeit** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Autoscaler, Backup, mehr Features |
| **Bundled Features** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | CSI, Longhorn, Cert Manager, etc. |
| **Talos-spezifisch** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | KubePrism, Multihoming, GitOps Handoff |
| **Community** | ⭐⭐⭐⭐ | ⭐⭐⭐ | 626 vs 326 Stars |
| **Dokumentation** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Sehr ausführlich vs. gut |
| **Einfachheit** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Mehr Features vs. sauberer Bootstrap |

### KLARE EMPFEHLUNG

**🏆 hcloud-k8s/terraform-hcloud-kubernetes** ist in fast allen Belangen überlegen:

1. **Private Cluster**: Voll unterstützt vs. nicht möglich
2. **Upgrades**: Voll automatisiert vs. komplett manuell
3. **Cilium**: Aktuellere Version, Gateway API, Hubble, Verschlüsselung
4. **Features**: CSI, Longhorn, Cert Manager, Autoscaler, Backup integriert
5. **Reife**: Älteres Projekt, mehr Stars, mehr Releases

**hcloud-talos nur wählen wenn**:
- Du **maximale Kontrolle** über jeden Component willst
- Du **GitOps-first** (ArgoCD/Flux) als Strategie hast und nur Bootstrap brauchst
- Du **Tailscale** als Mesh VPN nutzen willst (besser integriert)
- Du **ARM + x86 Mixed** Workloads hast

---

## Anhang: Quellen

- k3s Dokumentation: https://docs.k3s.io/
- Talos Linux Dokumentation: https://docs.siderolabs.com/talos/v1.10/
- k3s GitHub: https://github.com/k3s-io/k3s (32.766 Stars)
- Talos GitHub: https://github.com/siderolabs/talos (10.249 Stars)
- hcloud-k8s Module: https://github.com/hcloud-k8s/terraform-hcloud-kubernetes (626 Stars)
- hcloud-talos Module: https://github.com/hcloud-talos/terraform-hcloud-talos (326 Stars)
- Sidero Labs Support: https://www.siderolabs.com/pricing/
- SUSE K3s Support Matrix: https://www.suse.com/suse-k3s/support-matrix/
- Hetzner Cloud Network Docs: https://docs.hetzner.com/cloud/networks/
- Talos Upgrade Docs: https://docs.siderolabs.com/talos/v1.10/configure-your-talos-cluster/lifecycle-management/
