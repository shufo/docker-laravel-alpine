# docker-laravel-alpine

This repository contains a Dockerfile for create Laravel 5.x, 6.x* ready image bundled with Composer and [hirak/prestissimo](https://github.com/hirak/prestissimo).

DockerHub repository is [here](https://hub.docker.com/r/shufo/laravel-alpine/).

You can use these tags as php version.

`-node-browsers` tagged image includes nodejs and chromium browser to test E2E by Laravel Dusk, puppeteer, Cypress, etc...

- `7.4.3`, `latest`
  - `7.4.3-node-browsers`
- `7.4.2`, `7.4.2-node-browsers`
- `7.4.1`, `7.4.1-node-browsers`
- `7.3.11`, `7.3.11-node-browsers`
- `7.1`
- `7.1-opcache`
- `7.0.10`
