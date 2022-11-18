load("//python:internal.bzl", "get_lib_srcs", "map_dep")

def py_library(name, srcs, libs, deps, **kwargs):
    native.py_library(
        name = "_" + name + ".container",
        srcs = srcs,
        deps = libs + [map_dep("pip_monorepo_container", dep) for dep in deps],
        exec_compatible_with = ["@io_bazel_rules_docker//platforms:run_in_container"],
        tags = ["manual"],
        **kwargs
    )

    native.py_library(
        name = "_" + name + ".srcs",
        srcs = srcs,
        deps = [get_lib_srcs(lib) for lib in libs],
        tags = ["manual"],
        **kwargs
    )

    native.py_library(
        name = name,
        srcs = srcs,
        deps = libs + [map_dep("pip_monorepo_host", dep) for dep in deps],
        **kwargs
    )
