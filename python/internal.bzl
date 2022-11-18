def map_dep(pip_import, dependency):
    return "@{}//:{}".format(pip_import, dependency)

def get_lib_srcs(dependency):
    return _fullname(dependency).replace(":", ":_") + ".srcs"

def _fullname(dependency):
    if ":" in dependency:
        return dependency
    return dependency + ":" + dependency.split("/")[-1]
