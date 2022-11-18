load("//pip:defs.bzl", _pip_import = "pip_import")
load("//python:binary.bzl", _py_binary = "py_binary", _py_binary_with_requirements = "py_binary_with_requirements")
load("//python:image.bzl", _py_image = "py_image", _py_image_with_requirements = "py_image_with_requirements")
load("//python:library.bzl", _py_library = "py_library")
load("//python:test.bzl", _py_test = "py_test", _py_test_with_requirements = "py_test_with_requirements")

pip_import = _pip_import
py_binary = _py_binary
py_binary_with_requirements = _py_binary_with_requirements
py_image = _py_image
py_image_with_requirements = _py_image_with_requirements
py_library = _py_library
py_test = _py_test
py_test_with_requirements = _py_test_with_requirements
