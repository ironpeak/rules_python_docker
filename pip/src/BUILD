package(default_visibility = ["//visibility:public"])

py_library(
    name = "whllib",
    srcs = ["whl.py"],
    deps = [
        "//pip/third_party/py:pypi_vendor",
    ],
)

py_binary(
    name = "whl",
    srcs = ["whl.py"],
    python_version = "PY3",
    deps = [
        ":whllib",
    ],
)

py_binary(
    name = "piptool",
    srcs = ["piptool.py"],
    python_version = "PY3",
    deps = [
        ":whllib",
        "//pip/third_party/py:pypi_vendor",
    ],
)

py_binary(
    name = "compile",
    srcs = ["compile.py"],
    python_version = "PY3",
    deps = [
        "//pip/third_party/py:pypi_vendor",
    ],
)
