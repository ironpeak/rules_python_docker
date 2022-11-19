def map_dep(pip_import, dependency):
    return "@{}//:{}".format(pip_import, dependency)

def map_lib(lib):
    return _fullname(lib).replace(":", ":_") + ".container"

def get_lib_srcs(lib):
    return _fullname(lib).replace(":", ":_") + ".srcs"

def _fullname(target):
    if ":" in target:
        return target
    return target + ":" + target.split("/")[-1]
