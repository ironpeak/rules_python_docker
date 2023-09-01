workspace(name = "jiko_devx_bazel_rules_python_docker")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# oci
http_archive(
    name = "rules_oci",
    sha256 = "fc8551ccbfe4e716c8a3876b1b42d37e80f0bbd5045ec4de3bed88f0dc1ff0aa",
    strip_prefix = "rules_oci-1.3.2",
    url = "https://github.com/bazel-contrib/rules_oci/releases/download/v1.3.2/rules_oci-v1.3.2.tar.gz",
)

load("@rules_oci//oci:dependencies.bzl", "rules_oci_dependencies")

rules_oci_dependencies()

load("@rules_oci//oci:repositories.bzl", "LATEST_CRANE_VERSION", "LATEST_ZOT_VERSION", "oci_register_toolchains")

oci_register_toolchains(
    name = "oci",
    crane_version = LATEST_CRANE_VERSION,
    zot_version = LATEST_ZOT_VERSION,
)
