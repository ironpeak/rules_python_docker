"""Import pip requirements into Bazel."""

pip_vendor_label = Label("@rules_python_docker//pip:third_party/py/BUILD")

def _execute(repository_ctx, arguments, quiet = False):
    pip_vendor = str(repository_ctx.path(pip_vendor_label).dirname)
    return repository_ctx.execute(arguments, environment = {
        "PYTHONPATH": pip_vendor,
    }, timeout = repository_ctx.attr.timeout, quiet = quiet)

def _pip_import_impl(repository_ctx):
    """Core implementation of pip_import."""

    repository_ctx.file("BUILD", "")
    reqs = repository_ctx.read(repository_ctx.attr.requirements)

    # make a copy for compile
    repository_ctx.file("requirements.txt", content = reqs, executable = False)
    if repository_ctx.attr.compile:
        result = _execute(repository_ctx, [
            "python",
            repository_ctx.path(repository_ctx.attr._compiler),
            "--quiet",
            "--allow-unsafe",
            "--no-emit-trusted-host",
            "--build-isolation",
            "--no-emit-find-links",
            "--no-header",
            "--no-emit-index-url",
            "--no-annotate",
            repository_ctx.path("requirements.txt"),
        ], quiet = repository_ctx.attr.quiet)
        if result.return_code:
            fail("pip_compile failed: %s (%s)" % (result.stdout, result.stderr))

    args = [
        "python",
        repository_ctx.path(repository_ctx.attr._script),
        "--name",
        repository_ctx.attr.name,
        "--input",
        repository_ctx.path("requirements.txt"),
        "--output",
        repository_ctx.path("requirements.bzl"),
        "--timeout",
        str(repository_ctx.attr.timeout),
        "--repo-prefix",
        str(repository_ctx.attr.repo_prefix),
        "--quiet",
        str(repository_ctx.attr.quiet),
    ]

    for label, pipdep in repository_ctx.attr.overrides.items():
        args.append(["--override=%s=%s" % (label, pipdep)])

    result = _execute(repository_ctx, args, quiet = repository_ctx.attr.quiet)
    if result.return_code:
        fail("pip_import failed: %s (%s)" % (result.stdout, result.stderr))

_pip_import = repository_rule(
    attrs = {
        "requirements": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "requirement.txt file generatd by pip-compile",
        ),
        "repo_prefix": attr.string(default = "pypi", doc = """
The prefix for the bazel repository name.
"""),
        "compile": attr.bool(
            default = False,
        ),
        "overrides": attr.label_keyed_string_dict(doc = """
Specify to replace certain pip dependencies with bazel dependencies.

pip_import(
    name = "pipdeps",
    ...
    overrides = {
        "@com_google_protobuf//:protobuf_python": "protobuf",
    },
)

This replaces "protobuf" with the bazel version even for indirect dependencies on it.
"""),
        "timeout": attr.int(default = 1200, doc = "Timeout for pip actions"),
        "_script": attr.label(
            executable = True,
            default = Label("@rules_python_docker//pip/src:piptool.py"),
            allow_single_file = True,
            cfg = "exec",
        ),
        "_compiler": attr.label(
            executable = True,
            default = Label("@rules_python_docker//pip/src:compile.py"),
            allow_single_file = True,
            cfg = "exec",
        ),
        "quiet": attr.bool(
            default = True,
            doc = "If stdout and stderr should be printed to the terminal.",
        ),
    },
    implementation = _pip_import_impl,
)

def pip_import(name, requirements, requirements_lock, host_overrides = {}, container_overrides = {}, **kwargs):
    _pip_import(
        name = name + "_host",
        requirements = requirements,
        compile = True,
        repo_prefix = name + "_host",
        overrides = host_overrides,
        **kwargs
    )

    _pip_import(
        name = name + "_container",
        requirements = requirements_lock,
        compile = False,
        repo_prefix = name + "_container",
        overrides = container_overrides,
        **kwargs
    )

def _whl_impl(repository_ctx):
    """Core implementation of whl_library."""

    pip_args = repository_ctx.attr.pip_args
    if "--timeout" not in repository_ctx.attr.pip_args:
        pip_args = repository_ctx.attr.pip_args + ["--timeout", str(repository_ctx.attr.timeout)]

    args = [
        "python",
        repository_ctx.path(repository_ctx.attr._script),
        "--requirements",
        repository_ctx.attr.requirements_repo,
        "--directory",
        repository_ctx.path("."),
        "--constraint",
        repository_ctx.path(
            Label("%s//:requirements.txt" % repository_ctx.attr.requirements_repo),
        ),
        "--package",
        repository_ctx.attr.pkg,
    ]
    if repository_ctx.attr.extras:
        args += [
            "--extras=%s" % extra
            for extra in repository_ctx.attr.extras
        ]
    for label, pipdep in repository_ctx.attr.overrides.items():
        args.append(["--override=%s=%s" % (label, pipdep)])

    args += pip_args

    result = _execute(repository_ctx, args, quiet = repository_ctx.attr.quiet)
    if result.return_code:
        fail("whl_library failed: %s (%s)" % (result.stdout, result.stderr))

whl_library = repository_rule(
    attrs = {
        "pkg": attr.string(),
        "requirements_repo": attr.string(),
        "extras": attr.string_list(),
        "pip_args": attr.string_list(default = []),
        "timeout": attr.int(default = 1200, doc = "Timeout for pip actions"),
        "overrides": attr.label_keyed_string_dict(),
        "_script": attr.label(
            executable = True,
            default = Label("@rules_python_docker//pip/src:whl.py"),
            cfg = "exec",
        ),
        "quiet": attr.bool(
            default = True,
            doc = "If stdout and stderr should be printed to the terminal.",
        ),
    },
    implementation = _whl_impl,
)
