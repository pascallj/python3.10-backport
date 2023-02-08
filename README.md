# Python 3.10 backport for Debian 11 bullseye
The aim of this project is to provide a Python 3.10 backport to Debian buster. Packages are of course much better manageable than compiling the source from scratch.

Motivation for this project was the [removal of Python 3.9 support in Home Assistant 2023.2.0](https://github.com/home-assistant/core/pull/85456). Debian bullseye doesn't have Python 3.10 however and Debian bookworm (which will contain Python 3.11) will not be released anytime before July 2023. In the meantime, you can use this backport.

More information about the use of this packages/repository for Home Assistant can be found on a [Home Assistant Community post](https://community.home-assistant.io/t/home-assistant-core-python-3-10-backport-for-debian-11-bullseye/528439) I've written.

## Scope
The scope of this project is limited to backporting just Python 3.10 itself. So no defaults (which provide virtual packages so `python3` get's automatically linked to `python3.10`) and no precompiled pip-packages or wheels. Therefore it can coexist with your regular Python (3.9) installation without any interference and still being simple to maintain. It's main use is for in virtual environments where you can use pip to compile and install any packages you desire. It does provide all the packages and dependencies needed to create a Python 3.10 virtual environment.

Because their were problems when cross-compiling the `stdlib-extensions`, I've included the contents which would normally be in the `python3.10-distutils` package inside the `python3.10-venv` package. This way you can create a Python 3.10 virtual environment without needing distutils as a seperate package.

Although Debian 11 at the moment still provides Python 3.10, it will not be available at release. Instead Python 3.11 will be the supported Python version for Debian 11. Therefore I am not sure if the maintainers will provide Python 3.10 updates in the mean time.

## Repository
You can download the packages in my repository at `deb.pascalroeleven.nl` by adding this line to your sources.list:
```sh
deb http://deb.pascalroeleven.nl/python3.10 bullseye-backports main
```
You should also add my PGP (which you can get from my website via https) to APT's sources keyring:
```sh
wget -qO- https://pascalroeleven.nl/deb-pascalroeleven.gpg | sudo tee /etc/apt/trusted.gpg.d/deb-pascalroeleven.gpg
```

Packages are built using Github actions along with a file containing the checksums of all packages. Therefore, you can compare the checksums of the packages in the repository with the checksums in Github Actions and trace the entire process (up to 90 days after the build after which the artifacts and logs get removed). This way, if you trust the Github Actions build system, you can be sure that the packages I provide are actually built using the instructions in this repo.

## Support
Currently there is support for **`amd64`**, **`arm64`** and **`armhf`** architectures. The `amd64` packages are build natively while the `arm64` and `armhf` packages are crossbuilt. Testing is not possible while crossbuilding, so these packages did not undergo the same amount of testing as usual Debian packages do.

## Building the packages yourself
If you want to build the packages yourself, you can use the Dockerfile and the patches in this repository. Patches will be applied by the Dockerfile.

Two targets are supported: `native` and `crossbuild`. You should specify either of these:
```sh
docker build --target native .
```

When crossbuilding, you can specify the architecture by adding the `CROSSBUILD` build argument:
```sh
docker build --target crossbuild --build-arg CROSSBUILD=armhf .
```

You can also specify your name, email and changelog message when building which will then be added to the changelog.
```sh
docker build --target native --build-arg NAME="James Smith" --build-arg EMAIL="jamessmith@example.org" --build-arg CHANGE="Initial backport for bullseye" .
```

Building natively takes about 2 hours on a modern decent PC because of the extensive testing. Cross building takes about 30 minutes (but uses native binaries so requires the extra 2 hours the first time).

The packages can the be extracted from the image.

