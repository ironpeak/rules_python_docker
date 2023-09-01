load("//python:internal.bzl", "get_lib_srcs", "map_dep", "map_lib")
load("//python:binary.bzl", "py_binary", "py_binary_with_requirements")
load("@rules_oci//oci:defs.bzl", "oci_image")
load("//:py_image_layer.bzl", "py_image_layer")

def py_image(name, base, main = "main.py", srcs = ["main.py"], libs = [], deps = [], env = {}, **kwargs):
    py_binary(
        name = name + ".binary",
        main = main,
        srcs = srcs,
        libs = libs,
        deps = deps,
        **kwargs
    )

    _py3_image(
        name = name,
        main = main,
        srcs = srcs,
        deps = [map_lib(lib) for lib in libs] + [map_dep("pip_monorepo_container", dep) for dep in deps],
        base = base,
        env = env,
        **kwargs
    )

def py_image_with_requirements(name, base, main = "main.py", srcs = ["main.py"], libs = [], deps = [], pip_import = "pip_monorepo", env = {}, **kwargs):
    py_binary_with_requirements(
        name = name + ".binary",
        main = main,
        srcs = srcs,
        libs = libs,
        deps = deps,
        pip_import = pip_import,
        **kwargs
    )

    _py3_image(
        name = name,
        main = main,
        srcs = srcs,
        deps = [get_lib_srcs(lib) for lib in libs] + [map_dep("{}_container".format(pip_import), dep) for dep in deps],
        base = base,
        env = env,
        **kwargs
    )

def _py3_image(name, base, deps = [], env = {}, data = [], tags = [], visibility = None, **kwargs):
    """Constructs a container image wrapping a py_binary target.

    Args:
        name: Name of the py3_image rule target.
        base: Base image to use for the py3_image.
        deps: Dependencies of the py3_image.
        env: Environment variables for the py_image.
        data: Data for the py_image.
        tags: Tags for the py_image.
        visibility: Target visibility.
        **kwargs: See py_binary.
    """
    binary_name = "_" + name + ".container.binary"

    native.py_binary(
        name = binary_name,
        deps = deps,
        data = data,
        tags = ["manual"],
        visibility = ["//visibility:private"],
        **kwargs
    )

    layer_name = "_" + name + ".layer"
    py_image_layer(
        name = layer_name,
        binary = binary_name,
        root = "/opt",
    )

    oci_image(
        name = name,
        base = base,
        cmd = ["/opt/"],
        tars = [layer_name],
    )
