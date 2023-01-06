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
    name = "jiko_devx_bazel_rules_python_docker",
    strip_prefix = "rules_python_docker-<revision>",
    sha256 = "<revision_hash>",
    urls = ["https://github.com/ironpeak/rules_python_docker/archive/<revision>.tar.gz"],
)

load("@jiko_devx_bazel_rules_python_docker//:defs.bzl", "pip_import")

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

## pip_import

The `pip_monorepo` dependencies are used by default when not using the `*_with_requirements` macros so it must be declared in your WORKSPACE file.

~~~python
load("@jiko_devx_bazel_rules_python_docker//:defs.bzl", "pip_import")

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
~~~

**PARAMETERS**

| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| name | The prefix for the host and container pip imports. | none |
| requirements | The `requirements.in` file that will be compiled for the host platform. | none |
| requirements_lock | The `requirements_lock.txt` file for the container platform. | none |
| host_overrides | Pip dependencies to replace with bazel dependencies on the host platform. | {} |
| container_overrides | Pip dependencies to replace with bazel dependencies on the container platform. | {} |
| kwargs | Attributes that are sent to a modified version of [ali5h/rules_pip](https://github.com/ali5h/rules_pip). | none |

## py_binary

Declare a `py_binary` target that uses the host dependencies from `pip_monorepo`.

~~~python
load("@jiko_devx_bazel_rules_python_docker//:defs.bzl", "py_binary")

py_binary(
    name = "hello_world",
    libs = [
        ":lib",
    ],
    deps = [
        "pip_package"
    ],
)
~~~

**PARAMETERS**

| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| name | The name of the target. target. | none |
| libs | A list of `py_library` targets. | [] |
| deps | A list of pip packages (e.g. `django`). | [] |
| kwargs | Attributes that are sent the Bazel native [py_binary](https://bazel.build/reference/be/python#py_binary) rule. | none |

## py_binary_with_requirements

Declare a `py_binary` target that uses the host dependencies from another `pip_import`.

**NOTE** You must declare every pip package in the deps field (in this example every pip package that `:lib` and any of it's dependencies depend on).

~~~python
load("@jiko_devx_bazel_rules_python_docker//:defs.bzl", "py_binary_with_requirements")

py_binary_with_requirements(
    name = "hello_world_custom",
    pip_import = "pip_custom_deps",
    libs = [
        ":lib",
    ],
    deps = [
        "pip_package"
    ],
)
~~~

**PARAMETERS**

| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| name | The name of the target. target. | none |
| pip_import | The `pip_import` to load requirements from. | `pip_monorepo` |
| libs | A list of `py_library` targets. | [] |
| deps | A list of pip packages (e.g. `django`). | [] |
| kwargs | Attributes that are sent the Bazel native [py_binary](https://bazel.build/reference/be/python#py_binary) rule. | none |

## py_image

Declare a [container_image](https://github.com/bazelbuild/rules_docker/blob/master/docs/container.md#container_image) target that uses the container dependencies from `pip_monorepo`.

It also creates a conveniance `py_binary` target that uses the corresponding host dependencies named `{name}.binary`.

~~~python
load("@jiko_devx_bazel_rules_python_docker//:defs.bzl", "py_image")

py_image(
    name = "hello_world",
    base = "@python//image",
    libs = [
        ":lib",
    ],
    deps = [
        "pip_package"
    ],
)
~~~

**PARAMETERS**

| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| name | The name of the target. target. | none |
| base | The base `container_image`. | [] |
| libs | A list of `py_library` targets. | [] |
| deps | A list of pip packages (e.g. `django`). | [] |
| env | Image environment variables. | {} |
| kwargs | Attributes that are sent the Bazel native [py_binary](https://bazel.build/reference/be/python#py_binary) rule. | none |

## py_image_with_requirements

Declare a [container_image](https://github.com/bazelbuild/rules_docker/blob/master/docs/container.md#container_image) target that uses the container dependencies from another `pip_import`.

It also creates a conveniance `py_binary` target that uses the corresponding host dependencies named `{name}.binary`.

**NOTE** You must declare every pip package in the deps field (in this example every pip package that `:lib` and any of it's dependencies depend on).

~~~python
load("@jiko_devx_bazel_rules_python_docker//:defs.bzl", "py_image_with_requirements")

py_image_with_requirements(
    name = "hello_world_custom",
    base = "@python//image",
    pip_import = "pip_custom_deps",
    libs = [
        ":lib",
    ],
    deps = [
        "pip_package"
    ],
)
~~~

**PARAMETERS**

| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| name | The name of the target. target. | none |
| base | The base `container_image`. | [] |
| pip_import | The `pip_import` to load requirements from. | `pip_monorepo` |
| libs | A list of `py_library` targets. | [] |
| deps | A list of pip packages (e.g. `django`). | [] |
| env | Image environment variables. | {} |
| kwargs | Attributes that are sent the Bazel native [py_binary](https://bazel.build/reference/be/python#py_binary) rule. | none |

## py_library

Declare `py_library` targets that are used by `py_binary`, `py_image` and `py_test`.

~~~python
load("@jiko_devx_bazel_rules_python_docker//:defs.bzl", "py_library")

py_library(
    name = "hello_world",
    libs = [
        ":lib",
    ],
    deps = [
        "pip_package"
    ],
)
~~~

The example above would create 3 py_library targets:

* //hello_world:_lib.container
  - Used by the `py_image` rule.
* //hello_world:_lib.srcs
  - Used by the `*_with_requirements` rules.
* //hello_world:lib
  - Used by the `py_binary` rule.

**PARAMETERS**

| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| name | The name of the target. target. | none |
| libs | A list of `py_library` targets. | [] |
| deps | A list of pip packages (e.g. `django`). | [] |
| kwargs | Attributes that are sent the Bazel native [py_library](https://bazel.build/reference/be/python#py_library) rule. | none |

## py_test

Declare `py_test` targets that uses the host requirements from `pip_monorepo`.

~~~python
load("@jiko_devx_bazel_rules_python_docker//:defs.bzl", "py_test")

py_test(
    name = "hello_world_test",
    libs = [
        ":lib",
    ],
    deps = [
        "pip_package"
    ],
)
~~~

**PARAMETERS**

| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| name | The name of the target. | none |
| libs | A list of `py_library` targets. | [] |
| deps | A list of pip packages (e.g. `django`). | [] |
| kwargs | Attributes that are sent the Bazel native [py_test](https://bazel.build/reference/be/python#py_test) rule. | none |

## py_test_with_requirements

Declare `py_test_with_requirements` targets that uses the host requirements another `pip_import`.

**NOTE** You must declare every pip package in the deps field (in this example every pip package that `:lib` and any of it's dependencies depend on).

~~~python
load("@jiko_devx_bazel_rules_python_docker//:defs.bzl", "py_test_with_requirements")

py_test_with_requirements(
    name = "hello_world_test",
    pip_import = "pip_custom_deps",
    libs = [
        ":lib",
    ],
    deps = [
        "pip_package"
    ],
)
~~~

**PARAMETERS**

| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| name | The name of the target. | none |
| pip_import | The `pip_import` to load requirements from. | `pip_monorepo` |
| libs | A list of `py_library` targets. | [] |
| deps | A list of pip packages (e.g. `django`). | [] |
| kwargs | Attributes that are sent the Bazel native [py_test](https://bazel.build/reference/be/python#py_test) rule. | none |

