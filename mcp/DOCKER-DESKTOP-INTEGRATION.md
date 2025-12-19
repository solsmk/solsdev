# Docker Desktop Integration

*How to manage SolsDev MCP Gateway through Docker Desktop*

---

## Overview

The SolsDev MCP Gateway runs as a Docker container that you can fully manage through Docker Desktop's GUI.

---

## Viewing in Docker Desktop

### 1. Open Docker Desktop

After starting the gateway:

```bash
./mcp/scripts/start-gateway.sh
```

### 2. Navigate to Containers

1. Open **Docker Desktop**
2. Click **Containers** in the left sidebar
3. Find **solsdev-mcp-gateway**

### 3. Container Information

You'll see:

```
┌─────────────────────────────────────────────────────────┐
│ solsdev-mcp-gateway                                      │
├─────────────────────────────────────────────────────────┤
│ Status:   Running (healthy)                              │
│ Image:    docker/mcp-gateway:latest                      │
│ Port:     8811 → 8811                                    │
│ Created:  2 minutes ago                                  │
└─────────────────────────────────────────────────────────┘
```

---

## Container Actions (Docker Desktop GUI)

### View Logs

1. Click on **solsdev-mcp-gateway** container
2. Click **Logs** tab
3. See real-time gateway logs

**OR** use CLI:
```bash
./mcp/scripts/logs.sh -f
```

### Inspect Container

1. Click **Inspect** tab
2. View:
   - **Environment variables** (from .env.mcp)
   - **Volumes** (workspace mount)
   - **Network** (solsdev-mcp-network)
   - **Resources** (memory/CPU usage)

### Terminal Access

1. Click **Exec** tab
2. Opens terminal inside container
3. Useful for debugging

**OR** use CLI:
```bash
docker exec -it solsdev-mcp-gateway sh
```

### Stop/Start/Restart

Using Docker Desktop buttons:
- **Stop** - Gracefully stop gateway
- **Start** - Start stopped gateway
- **Restart** - Restart gateway

**OR** use CLI:
```bash
./mcp/scripts/stop-gateway.sh
./mcp/scripts/start-gateway.sh
```

---

## Container Details

### What's Running

```
Container: solsdev-mcp-gateway
├── Image: docker/mcp-gateway:latest
├── Port: 8811:8811 (SSE transport)
├── Network: solsdev-mcp-network
├── Volumes:
│   ├── /var/run/docker.sock (Docker socket)
│   ├── ./mcp → /mcp (config)
│   └── ~/.docker/mcp → /home/mcp/.docker/mcp (credentials)
└── Health Check: http://localhost:8811/health
```

### Environment Variables (Visible in Docker Desktop)

From your `.env.mcp`:

```
MCP_LOG_LEVEL=info
MCP_WORKSPACE=/home/neno/Code/solsdev
MEDUSA_BACKEND_URL=http://localhost:9000
STRAPI_URL=http://localhost:1337
NEXT_PUBLIC_URL=http://localhost:3000
# ... etc
```

### Volumes (Visible in Docker Desktop)

```
Type: bind
Source: /home/neno/Code/solsdev/mcp
Target: /mcp
Mode: read-only

Type: bind
Source: /var/run/docker.sock
Target: /var/run/docker.sock
Mode: read-write
```

---

## Network Configuration

### View Network in Docker Desktop

1. Click **Networks** in left sidebar
2. Find **solsdev-mcp-network**
3. See connected containers

### Network Details

```
Name: solsdev-mcp-network
Driver: bridge
Subnet: 172.18.0.0/16
Gateway: 172.18.0.1

Connected Containers:
- solsdev-mcp-gateway (172.18.0.2)
```

---

## Resource Monitoring

### Real-time Stats in Docker Desktop

1. Click on **solsdev-mcp-gateway**
2. View **Stats** tab:
   - CPU usage
   - Memory usage
   - Network I/O
   - Disk I/O

### Resource Limits

Set in `mcp/config.yaml`:

```yaml
resources:
  default_memory: 512Mb
  default_cpus: 1.0
  max_memory: 2Gb
  max_cpus: 2.0
```

View actual usage:
```bash
docker stats solsdev-mcp-gateway
```

---

## Troubleshooting via Docker Desktop

### Container Won't Start

1. **Check Logs:**
   - Open container logs in Docker Desktop
   - Look for startup errors

2. **Check Port Conflicts:**
   ```bash
   lsof -i :8811
   ```

3. **Verify Docker Socket:**
   - Ensure Docker Desktop is running
   - Check `/var/run/docker.sock` is accessible

### Container Unhealthy

Health check failing shows in Docker Desktop as:
```
Status: Running (unhealthy)
```

**Fix:**
```bash
# Check health endpoint manually
curl http://localhost:8811/health

# View health check logs
docker inspect solsdev-mcp-gateway | grep -A 10 Health
```

### High Resource Usage

Monitor in Docker Desktop Stats tab:

**If Memory high:**
- Check which MCP servers are active
- Adjust limits in `mcp/config.yaml`
- Use lighter profile

**If CPU high:**
- Some MCP servers are compute-intensive
- Check logs for errors causing retries
- Restart gateway

---

## Docker Compose Integration

### View Stack in Docker Desktop

Since we use Docker Compose, you can:

1. Click **Containers** → Group by **solsdev-mcp** stack
2. See all services in the stack (currently just gateway)

### Manage via Compose

```bash
# From project root
docker compose -f docker-compose.mcp.yaml ps
docker compose -f docker-compose.mcp.yaml logs
docker compose -f docker-compose.mcp.yaml restart
docker compose -f docker-compose.mcp.yaml down
```

---

## Advanced Docker Desktop Features

### Extensions Integration

If you have Docker Desktop extensions:

#### **Docker Scout** (Security Scanning)
- Scans `docker/mcp-gateway` image for vulnerabilities
- View CVEs and recommendations

#### **Resource Saver**
- Automatically pauses gateway when inactive
- Saves system resources

#### **Disk Usage**
- Shows space used by MCP gateway image
- Clean up old images

### Dev Environments

Create a Dev Environment from your repo:

1. **Dev Environments** → **Create**
2. Point to `https://github.com/Neno73/solsdev`
3. Docker Desktop auto-starts gateway
4. Hot-reload on changes

---

## Docker Desktop Settings

### Optimal Settings for MCP Gateway

**Resources Tab:**
```
Memory: 4 GB minimum (8 GB recommended)
CPUs: 2 minimum (4 recommended)
Swap: 1 GB
Disk: 60 GB
```

**Network Tab:**
```
Enable host networking
DNS: Automatic
```

**Docker Engine (Advanced):**
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

---

## Backup & Restore

### Backup Configuration

```bash
# Backup MCP configuration
tar -czf mcp-backup-$(date +%Y%m%d).tar.gz \
  mcp/ \
  docker-compose.mcp.yaml \
  .env.mcp

# Backup Docker volumes (if any)
docker run --rm \
  -v solsdev-mcp-data:/data \
  -v $(pwd):/backup \
  alpine tar -czf /backup/mcp-volumes-$(date +%Y%m%d).tar.gz /data
```

### Restore Configuration

```bash
# Restore configuration
tar -xzf mcp-backup-20251219.tar.gz

# Restart gateway
./mcp/scripts/start-gateway.sh
```

---

## Docker Desktop CLI Integration

### Use Docker Desktop Commands

```bash
# Open Docker Desktop to container
open -a "Docker Desktop" --args --container solsdev-mcp-gateway

# Open logs in Docker Desktop
open -a "Docker Desktop" --args --logs solsdev-mcp-gateway
```

---

## Docker Desktop vs CLI Scripts

Both work seamlessly together!

| Action | Docker Desktop | CLI Script |
|--------|---------------|------------|
| **Start** | Click Start button | `./mcp/scripts/start-gateway.sh` |
| **Stop** | Click Stop button | `./mcp/scripts/stop-gateway.sh` |
| **Logs** | Click Logs tab | `./mcp/scripts/logs.sh` |
| **Status** | View container card | `./mcp/scripts/status.sh` |
| **Restart** | Click Restart button | Stop + Start scripts |

**Use whichever you prefer!**

---

## Screenshots Guide

### 1. Finding Your Gateway

![Finding Container](screenshots/docker-desktop-container.png)

### 2. Viewing Logs

![Container Logs](screenshots/docker-desktop-logs.png)

### 3. Resource Stats

![Resource Stats](screenshots/docker-desktop-stats.png)

*(Screenshots: Use Docker Desktop → Screenshot feature)*

---

## Quick Reference

### Common Docker Desktop Tasks

```
View Gateway:        Containers → solsdev-mcp-gateway
Check Health:        Green dot = healthy
View Logs:           Click container → Logs tab
Check Resources:     Click container → Stats tab
Stop/Start:          Use buttons in container card
Inspect Config:      Click container → Inspect tab
Terminal Access:     Click container → Exec tab
View Network:        Networks → solsdev-mcp-network
```

---

## Integration with Docker Desktop Dashboard

The gateway shows up in Docker Desktop dashboard with:

- ✅ **Health Status** - Green checkmark when healthy
- 📊 **Resource Usage** - Real-time CPU/memory graphs
- 📝 **Quick Actions** - Stop, restart, view logs
- 🔍 **Search** - Find by name "solsdev"

---

**Docker Desktop makes managing the MCP Gateway visual and intuitive!** 🐳
