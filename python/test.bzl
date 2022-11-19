load("//python:internal.bzl", "get_lib_srcs", "map_dep")

def py_test(name, libs = [], deps = [], **kwargs):
    native.py_test(
        name = name,
        deps = libs + [map_dep("pip_monorepo_host", dep) for dep in deps],
        **kwargs
    )

def py_test_with_requirements(name, libs = [], deps = [], pip_import = "pip_monorepo", **kwargs):
    native.py_test(
        name = name,
        deps = [get_lib_srcs(lib) for lib in libs] + [map_dep("{}_host".format(pip_import), dep) for dep in deps],
        **kwargs
    )
