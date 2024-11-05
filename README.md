# Roon Server with Tailscale

This project sets up a Roon Server with options for Stable or EarlyAccess versions, alongside a Tailscale integration for secure remote access. The setup includes ipvlan/macvlan network isolation.

## Features
- **Stable or EarlyAccess Version**: Choose which version of Roon to run by specifying the version in the docker-compose file.
- **Tailscale Integration**: Optionally start and configure Tailscale through the docker-compose configuration.
- **Network Isolation**: Instructions for setting up network isolation using ipvlan/macvlan.
- **Reusable Tailscale API Keys**: Generate reusable keys without expiry and manage API keys effectively.

## 1. Running Roon Server in Stable or EarlyAccess Mode

In the `docker-compose.yaml`, you can define which version of Roon Server to use by setting the `ROON_VERSION` environment variable:

```yaml
environment:
  - ROON_VERSION=Stable # Set to 'Stable' or 'EarlyAccess' to choose the version
```

## 2. Integrating Tailscale with Roon Server

To enable Tailscale, set the `ENABLE_TAILSCALE` environment variable to true:

```yaml
environment:
  - ENABLE_TAILSCALE=true
  - TAILSCALE_AUTHKEY=your_tailscale_authkey # Authentication key for Tailscale
  - TAILSCALE_EXTRA_ARGS=--reset --accept-routes # Additional arguments for Tailscale
```

When Tailscale is enabled, it will automatically start when the container is launched.

## 3. Configuring Tailscale via Docker-Compose Variables

In the docker-compose file, use these variables to configure Tailscale:

- `TAILSCALE_AUTHKEY`: Your Tailscale API key for authentication.
- `TAILSCALE_EXTRA_ARGS`: Additional arguments for more granular control of Tailscale.

## 4. Using ipvlan/macvlan for Network Isolation

For advanced network isolation, you can use ipvlan or macvlan. Here's an example of configuring macvlan in the `docker-compose.yaml`:

```yaml
networks:
  vlan:
    driver: macvlan
    driver_opts:
      parent: eth0
    ipam:
      config:
        - subnet: 192.168.1.0/24
          gateway: 192.168.1.1
```

This will isolate the container at Layer 2 of the network and assign it a dedicated IP address.

### Example macvlan Setup

Run the following to create a macvlan network:

```bash
docker network create -d macvlan   --subnet=192.168.1.0/24   --gateway=192.168.1.1   -o parent=eth0 vlan
```

This allows the container to operate on its own IP address, separated from the Docker host's network stack.

## 5. Creating Reusable Tailscale API Keys and Managing Expiry

To create reusable Tailscale API keys without expiry:

1. Log into your Tailscale admin console.
2. Go to the "Keys" section.
3. Create a new key and mark it as reusable (non-expiring).
4. Use this key in the `TAILSCALE_AUTHKEY` environment variable in the `docker-compose.yaml`.

To revoke a key, simply remove it from the Tailscale admin console.

---

## How to Run

1. Clone this repository.
2. Update the `docker-compose.yaml` file with your configuration.
3. Run the following command to start:

```bash
docker-compose up -d
```

That's it! You're now running Roon Server with Tailscale integration.


## CHANGELOG

05/11/2024 Updated ffmpeg to 7.1
