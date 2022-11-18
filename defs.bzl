def py_library(**attrs):
    """See the Bazel core [py_library](https://docs.bazel.build/versions/master/be/python.html#py_library) documentation.

    Args:
      **attrs: Rule attributes
    """

    # buildifier: disable=native-python
    native.py_library(**_add_tags(attrs))

def py_binary(**attrs):
    """See the Bazel core [py_binary](https://docs.bazel.build/versions/master/be/python.html#py_binary) documentation.

    Args:
      **attrs: Rule attributes
    """

    # buildifier: disable=native-python
    native.py_binary(**_add_tags(attrs))

def py_test(**attrs):
    """See the Bazel core [py_test](https://docs.bazel.build/versions/master/be/python.html#py_test) documentation.

    Args:
      **attrs: Rule attributes
    """

    # buildifier: disable=native-python
    native.py_test(**_add_tags(attrs))

def py_runtime(**attrs):
    """See the Bazel core [py_runtime](https://docs.bazel.build/versions/master/be/python.html#py_runtime) documentation.

    Args:
      **attrs: Rule attributes
    """

    # buildifier: disable=native-python
    native.py_runtime(**_add_tags(attrs))
