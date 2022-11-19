# Bazel python + docker rules

## Overview

This repository provides support for using python and docker in Bazel when
the host and image platform do not match.

## Main features

- Run py_binary on both host and in container

- Monorepo requirements by default

## Setup

Add the following to your `WORKSPACE` file:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "com_github_ironpeak_rules_python_docker",
    strip_prefix = "rules_python_docker-<revision>",
    sha256 = "<revision_hash>",
    urls = ["https://github.com/ironpeak/rules_python_docker/archive/<revision>.tar.gz"],
)

load("@com_github_ironpeak_rules_python_docker//:defs.bzl", "pip_import")

# pip_monorepo
pip_import(
    name = "pip_monorepo",
    container_overrides = {
      # overrides for dependencies that are platform dependant.
      # if you do not have any overrides then you probably do not
      # need this repository.
      # "@pip_overrides//python/psycopg2-binary": "psycopg2-binary",
      # "@pip_overrides//python/xxhash": "xxhash",
    },
    requirements = "//:requirements.in",
    requirements_lock = "//:requirements_lock.txt",
)

load("@pip_monorepo_host//:requirements.bzl", pip_monorepo_host_pip_install = "pip_install")

pip_monorepo_host_pip_install([<optional pip install args])

load("@pip_monorepo_container//:requirements.bzl", pip_monorepo_container_pip_install = "pip_install")

pip_monorepo_container_pip_install([<optional pip install args])
```

## Target dependencies

To use pip packages you can

* add dependencies via `requirement` macro as

```python
load("@pip_deps//:requirements.bzl", "requirement")

py_binary(
    name = "main",
    srcs = ["main.py"],
    deps = [
        requirement("pip-module")
    ]
)
```

* use package aliases as

```python
py_binary(
    name = "main",
    srcs = ["main.py"],
    deps = [
        "@pip_deps//:pip-module"
    ]
)
```
