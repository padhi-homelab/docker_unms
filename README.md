# docker_unms <a href='https://github.com/padhi-homelab/docker_unms/actions?query=workflow%3A%22Docker+CI+Release%22'><img align='right' src='https://img.shields.io/github/workflow/status/padhi-homelab/docker_unms/Docker%20CI%20Release?logo=github&logoWidth=24&style=flat-square'></img></a>

<a href='https://hub.docker.com/r/padhihomelab/unms'><img src='https://img.shields.io/docker/image-size/padhihomelab/unms/latest?logo=docker&logoWidth=24&style=for-the-badge'></img></a> <a href='https://microbadger.com/images/padhihomelab/unms'><img src='https://img.shields.io/microbadger/layers/padhihomelab/unms/latest?logo=docker&logoWidth=24&style=for-the-badge'></img></a>

Multiarch Docker images for [UNMS] and its dependencies, all based on [Alpine Linux].

##### netflow

<table>
  <thead>
    <tr>
      <th>:heavy_check_mark: i386</th>
      <th>:heavy_check_mark: amd64</th>
      <th>:heavy_check_mark: arm</th>
      <th>:heavy_check_mark: armhf</th>
      <th>:heavy_check_mark: aarch64</th>
      <th>:heavy_check_mark: ppc64le</th>
    <tr>
  </thead>
</table>

##### nginx

<table>
  <thead>
    <tr>
      <th>:heavy_check_mark: i386</th>
      <th>:heavy_check_mark: amd64</th>
      <th>:heavy_check_mark: arm</th>
      <th>:heavy_check_mark: armhf</th>
      <th>:heavy_check_mark: aarch64</th>
      <th>:heavy_multiplication_x: ppc64le</th>
    <tr>
  </thead>
</table>

##### siridb

<table>
  <thead>
    <tr>
      <th>:heavy_check_mark: i386</th>
      <th>:heavy_check_mark: amd64</th>
      <th>:heavy_check_mark: arm</th>
      <th>:heavy_check_mark: armhf</th>
      <th>:heavy_check_mark: aarch64</th>
      <th>:heavy_check_mark: ppc64le</th>
    <tr>
  </thead>
</table>

##### ucrm

<table>
  <thead>
    <tr>
      <th>:heavy_check_mark: i386</th>
      <th>:heavy_check_mark: amd64</th>
      <th>:heavy_check_mark: arm</th>
      <th>:heavy_check_mark: armhf</th>
      <th>:heavy_check_mark: aarch64</th>
      <th>:heavy_check_mark: ppc64le</th>
    <tr>
  </thead>
</table>

##### unms

<table>
  <thead>
    <tr>
      <th>:heavy_check_mark: i386</th>
      <th>:heavy_check_mark: amd64</th>
      <th>:heavy_check_mark: arm</th>
      <th>:heavy_check_mark: armhf</th>
      <th>:heavy_check_mark: aarch64</th>
      <th>:heavy_check_mark: ppc64le</th>
    <tr>
  </thead>
</table>

### Credits

#### https://github.com/fastlorenzo/unms-chart/tree/master/docker
  - Although incomplete, this repo is close to the design goals I had in mind.
  - My [ucrm.Dockerfile](ucrm.Dockerfile) is largely based on the one available in this repo.
  - There were several small build and integration issues that I have fixed in my images.

#### https://github.com/Nico640/docker-unms
  - My multiarch images work on several more architectures.
  - I removed the dependence on [s6],
    and instead [compose] several containers as opposed to having a monolithic one.
  - I upgraded many of the default packages used by [UNMS] and this repo.

### TODO
  - Disable telemetry by default
  - Upgrade [LuaJIT] in [nginx.Dockerfile](nginx.Dockerfile) to compile for `ppc64le`



[Alpine Linux]: https://alpinelinux.org/
[compose]:      https://docs.docker.com/compose/
[LuaJIT]:       https://luajit.org/
[s6]:           https://github.com/just-containers/s6-overlay
[UNMS]:         https://www.ui.com/download/unms/
