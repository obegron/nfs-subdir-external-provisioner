# Release Process

This fork is released on an as-needed basis. The upstream release process does not apply here. The process is as follows:

1. An issue is proposing a new release with a changelog since the last release
1. Update `CHANGELOG.md` and bump versions in `charts/nfs-subdir-external-provisioner/Chart.yaml`
1. Create a tag for the fork release (for example: `git tag $VERSION`)
1. Push commits (and tags, if desired) to your fork
