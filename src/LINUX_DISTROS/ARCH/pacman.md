---

## INSTALL

```sh
pacman -S package_name1 package_name2
pacman -S group_name

pacman -S extra/package_name1             # to install package from specified repo
pacman -S $(pacman -Ssq package_regexp)   # to install all packages matched to regexp

## MANUAL build and install from AUR
# download snapshot .tar.gz file
makepkg
sudo pacman -U *.tar.xz
```

## REMOVE

```sh
pacman -Rs package_name  # remove package with all dependencies which are not
                         # required by any other installed package
pacman -R package_name   # remove only one package, without its dependencies

pacman -Rdd              # remove package which is required by other package,
                         # without removing the depended package

pacman -Rsc package_name # remove package, all dependencies, and all packages
                         # that depend on the target package

pacman -Rn package_name  # doesn't save config files, after removing
```

## UPGRADE

```sh
pacman -Syu                # update everything
pacman -S ${PACKAGE_NAME}  # update single package

# if you got "corrupted key" error
pacman -Sy archlinux-keyring
pacman -Syu
```

## QUERY

```sh
pacman -Qs string1 string2              # search for installed packages
pacman -Ss string1 string2              # search for not installed packages

pacman -Ql package_name                 # list files installed by package

pacman -Qi installed_package           # info about installed package, eg, dep list
pacman -Si not_installed_package       # info about not installed package, eg dep list

pacman -Qo /path/to/file_name           # print package which file belongs to

pacman -Qdt                             # print packages no longer required as
                                        # pependencies (orphans)
pacman -Qet                             # print packages explicity installed (not dependecies)

pactree package_name                    # print package dependecy tree
```
