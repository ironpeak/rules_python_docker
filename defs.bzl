def py_library(**kwargs):
    """See the Bazel core [py_library](https://docs.bazel.build/versions/master/be/python.html#py_library) documentation.

    Args:
      **kwargs: Rule attributes
    """

    # buildifier: disable=native-python
    native.py_library(**kwargs)

def py_binary(**kwargs):
    """See the Bazel core [py_binary](https://docs.bazel.build/versions/master/be/python.html#py_binary) documentation.

    Args:
      **kwargs: Rule attributes
    """

    # buildifier: disable=native-python
    native.py_binary(**kwargs)

def py_test(**kwargs):
    """See the Bazel core [py_test](https://docs.bazel.build/versions/master/be/python.html#py_test) documentation.

    Args:
      **kwargs: Rule attributes
    """

    # buildifier: disable=native-python
    native.py_test(**kwargs)
