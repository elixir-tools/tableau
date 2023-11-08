# CHANGELOG

## [0.11.1](https://github.com/elixir-tools/tableau/compare/v0.11.0...v0.11.1) (2023-11-08)


### Bug Fixes

* correctly create page modules ([8ea0936](https://github.com/elixir-tools/tableau/commit/8ea09369396e21f51336eaca05ee64bf57623038))

## [0.11.0](https://github.com/elixir-tools/tableau/compare/v0.10.1...v0.11.0) (2023-11-08)


### Features

* automatically generate post ids ([#33](https://github.com/elixir-tools/tableau/issues/33)) ([b5bf6df](https://github.com/elixir-tools/tableau/commit/b5bf6dfc24a2c83288262c10604a1e86defafe3b))


### Bug Fixes

* typos ([#41](https://github.com/elixir-tools/tableau/issues/41)) ([8e47467](https://github.com/elixir-tools/tableau/commit/8e47467ba060891e520d89d51789a502447e7436))

## [0.10.1](https://github.com/elixir-tools/tableau/compare/v0.10.0...v0.10.1) (2023-11-08)


### Bug Fixes

* make frontmatter layout optional ([#38](https://github.com/elixir-tools/tableau/issues/38)) ([b5ae96b](https://github.com/elixir-tools/tableau/commit/b5ae96b67699aa6db2ae90ec82b7c9787d518b97))

## [0.10.0](https://github.com/elixir-tools/tableau/compare/v0.9.0...v0.10.0) (2023-11-07)


### Features

* fall back to first &lt;h1&gt; as title if no title in frontmatter ([#36](https://github.com/elixir-tools/tableau/issues/36)) ([707f4ef](https://github.com/elixir-tools/tableau/commit/707f4ef33529507cc41a2728a960ba9b84b12ae1))

## [0.9.0](https://github.com/elixir-tools/tableau/compare/v0.8.0...v0.9.0) (2023-11-06)


### Features

* PageExtension ([162420b](https://github.com/elixir-tools/tableau/commit/162420b01d313dcf77df2dc0b93b5bfed7357581))

## [0.8.0](https://github.com/elixir-tools/tableau/compare/v0.7.1...v0.8.0) (2023-10-31)


### Features

* allow nested directories of posts ([588a7d4](https://github.com/elixir-tools/tableau/commit/588a7d401a6ba6c5cea63fcd569b644be6b84e47))
* arbitrary frontmatter keys in permalink ([2b38b43](https://github.com/elixir-tools/tableau/commit/2b38b43a0bbe7c56035a1059cdfbea1e9add5831))
* extract web dev utils ([#31](https://github.com/elixir-tools/tableau/issues/31)) ([af98ea8](https://github.com/elixir-tools/tableau/commit/af98ea843521c4af1fcdc7d52dd131cea92277c0))
* **posts:** global permalink and layout ([#30](https://github.com/elixir-tools/tableau/issues/30)) ([c47e9e5](https://github.com/elixir-tools/tableau/commit/c47e9e5952df91034533eba5d4f1fe8a89b676ab))
* switch from cowboy to bandit ([36cccc9](https://github.com/elixir-tools/tableau/commit/36cccc9c14b1fc8e27f71fdf7629f029d50c3bac))
* use MDEx for markdown ([dea822e](https://github.com/elixir-tools/tableau/commit/dea822ee8202832652ad5226f07974e2cfd09b94))


### Bug Fixes

* removed dbg from router ([d7961c2](https://github.com/elixir-tools/tableau/commit/d7961c20cbcef0eedc11ea8565e49dd6d5c6f9a3))

## [0.7.1](https://github.com/elixir-tools/tableau/compare/v0.7.0...v0.7.1) (2023-10-19)


### Bug Fixes

* **posts:** pull correct config key ([0281348](https://github.com/elixir-tools/tableau/commit/0281348ac4b56597273fa157b8ed1247f6e05e68))

## [0.7.0](https://github.com/elixir-tools/tableau/compare/v0.6.0...v0.7.0) (2023-10-18)


### ⚠ BREAKING CHANGES

* convert all yaml keys to atoms

### Features

* convert all yaml keys to atoms ([2bea559](https://github.com/elixir-tools/tableau/commit/2bea559197198708788e3962a3cfd63915c0f1d8))

## [0.6.0](https://github.com/elixir-tools/tableau/compare/v0.5.0...v0.6.0) (2023-10-08)


### Features

* allow elixir scripts for data extension ([#25](https://github.com/elixir-tools/tableau/issues/25)) ([66416c1](https://github.com/elixir-tools/tableau/commit/66416c1477b61697201cbd9afd6bb1a936c95fe7))
* data extension ([#24](https://github.com/elixir-tools/tableau/issues/24)) ([736da42](https://github.com/elixir-tools/tableau/commit/736da42d5cea3495942579b68da8349f6aa4e58f))
* post extension ([#22](https://github.com/elixir-tools/tableau/issues/22)) ([16d1c14](https://github.com/elixir-tools/tableau/commit/16d1c1428b8d4ca1745adddd221b50ec2467a99b))
* RSS extension ([#23](https://github.com/elixir-tools/tableau/issues/23)) ([4d67147](https://github.com/elixir-tools/tableau/commit/4d67147f931605ae43ecadb6d67630703338eeba))
* site assign ([#20](https://github.com/elixir-tools/tableau/issues/20)) ([d766c22](https://github.com/elixir-tools/tableau/commit/d766c22cc9d01927fde06080db7fd3e44473f745))

## [0.5.0](https://github.com/elixir-tools/tableau/compare/v0.4.0...v0.5.0) (2023-10-06)


### Features

* pass values from page through to layouts ([996d7de](https://github.com/elixir-tools/tableau/commit/996d7de2816f679d5e40e76bed81cbf30c5d7da0))

## [0.4.0](https://github.com/elixir-tools/tableau/compare/v0.3.1...v0.4.0) (2023-06-26)


### Features

* extension priority ([#16](https://github.com/elixir-tools/tableau/issues/16)) ([c6f6444](https://github.com/elixir-tools/tableau/commit/c6f6444e0e6571990ed8eb9dda85ecbc37e06743))

## [0.3.1](https://github.com/elixir-tools/tableau/compare/v0.3.0...v0.3.1) (2023-06-26)


### Bug Fixes

* refresh graph after running extensions ([fbb2621](https://github.com/elixir-tools/tableau/commit/fbb2621ee92d1211faed6c3d21ae6fc07f1c135f))

## [0.3.0](https://github.com/elixir-tools/tableau/compare/v0.2.0...v0.3.0) (2023-06-26)


### Features

* extensions ([#13](https://github.com/elixir-tools/tableau/issues/13)) ([333437f](https://github.com/elixir-tools/tableau/commit/333437fa5ddeef29135e0c0070cea0e5140e1f9d))


### Bug Fixes

* fix deprecation warnings for Logger.warn/1 ([#10](https://github.com/elixir-tools/tableau/issues/10)) ([0b13494](https://github.com/elixir-tools/tableau/commit/0b13494c35628236d152fe780971bec8a7bf8dd3))

## [0.2.0](https://github.com/elixir-tools/tableau/compare/v0.1.2...v0.2.0) (2023-06-14)


### Features

* copy static assets ([ad4281b](https://github.com/elixir-tools/tableau/commit/ad4281b92969c82b6605235d509e7a21bbbe3fa9))


### Bug Fixes

* include page/layout behaviour in postlude ([06ef33e](https://github.com/elixir-tools/tableau/commit/06ef33e26a1c2bd32b2ae4b16be984d15ab0b271))

## [0.1.2](https://github.com/elixir-tools/tableau/compare/v0.1.1...v0.1.2) (2023-06-14)


### Bug Fixes

* always preload modules ([f083b46](https://github.com/elixir-tools/tableau/commit/f083b46cc425fdf22b8c2685f0b5932360eb3c98))

## [0.1.1](https://github.com/elixir-tools/tableau/compare/v0.1.0...v0.1.1) (2023-06-13)


### Bug Fixes

* only use ex_doc in dev ([ab7d2bc](https://github.com/elixir-tools/tableau/commit/ab7d2bccfb78dde9d7ab9d55bd7535e460f1ffa6))

## v0.1.0

Initial Release
