# hive-pseudo-distributed

**Hadoop+Hive** の擬似分散モードで仮想マシンを構築するスクリプトです。
[tasukujp/hadoop-pseudo-distributed](https://github.com/tasukujp/hadoop-pseudo-distributed) を参考にさせていただきました。

仮想環境起動後は `setup.sh` を元にセットアップを行ないます。


## Requirements

* [virtualbox](https://www.virtualbox.org/)
* [vagrant](https://www.vagrantup.com/)


## Installation

VagrantとVirtualBoxのインストール

### Mac

```
$ brew install caskroom/cask/brew-cask
$ brew cask install vagrant
$ brew cask install virtualbox
```

### Windows ( ex: Use [Chocolatey](https://chocolatey.org/) )

```
$ choco install git
$ choco install vagrant
$ choco install virtualbox
```


リポジトリのクローン

```
$ git clone git@github.com:tasukujp/hadoop-pseudo-distributed.git
```


## Usage

仮想マシンを生成

```
$ vagrant up
```
