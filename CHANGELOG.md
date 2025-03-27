# CHANGELOG

## [0.22.0](https://github.com/elixir-tools/tableau/compare/v0.21.0...v0.22.0) (2025-03-27)


### ⚠ BREAKING CHANGES

* bump min mdex version to 0.4

### Features

* bump min mdex version to 0.4 ([dac5ddd](https://github.com/elixir-tools/tableau/commit/dac5ddd24c40e426a49082947611df64d2332e51))
* **rss:** multiple feeds ([#125](https://github.com/elixir-tools/tableau/issues/125)) ([3803ee5](https://github.com/elixir-tools/tableau/commit/3803ee5002576dd97515f393ca45ddfb4c60615d))


### Bug Fixes

* **sitemap:** sitemap custom tags ([#124](https://github.com/elixir-tools/tableau/issues/124)) ([2ef75da](https://github.com/elixir-tools/tableau/commit/2ef75da49db9f21bca1400ebf48eda23d78bc1e0))

## [0.21.0](https://github.com/elixir-tools/tableau/compare/v0.20.1...v0.21.0) (2025-03-14)


### Features

* **dev_server:** error page for compile and build errors ([#120](https://github.com/elixir-tools/tableau/issues/120)) ([0873535](https://github.com/elixir-tools/tableau/commit/08735357d587b2b1a444fefb00b691dce48d2f3c))


### Bug Fixes

* minimize deps ([#122](https://github.com/elixir-tools/tableau/issues/122)) ([91d84c0](https://github.com/elixir-tools/tableau/commit/91d84c03e44e10080723a21918e1296d1b9d0ea2))

## [0.20.1](https://github.com/elixir-tools/tableau/compare/v0.20.0...v0.20.1) (2025-01-18)


### Bug Fixes

* include toke.site.pages earlier in the pipeline ([1c78914](https://github.com/elixir-tools/tableau/commit/1c789148607a67d38ac99773a07f110d506144cc))

## [0.20.0](https://github.com/elixir-tools/tableau/compare/v0.19.0...v0.20.0) (2024-12-05)


### Features

* write pages with .html permalink to corresponding file([#115](https://github.com/elixir-tools/tableau/issues/115)) ([8c5a614](https://github.com/elixir-tools/tableau/commit/8c5a61483e9ee6e7195bb73347eb1ae091dd3dd6))

## [0.19.0](https://github.com/elixir-tools/tableau/compare/v0.18.0...v0.19.0) (2024-11-10)


### Features

* **pages, posts:** use custom converter in frontmatter ([#113](https://github.com/elixir-tools/tableau/issues/113)) ([e39efa4](https://github.com/elixir-tools/tableau/commit/e39efa42c5321ccb7f14384dc15e381bbda138af)), closes [#112](https://github.com/elixir-tools/tableau/issues/112)

## [0.18.0](https://github.com/elixir-tools/tableau/compare/v0.17.1...v0.18.0) (2024-10-11)


### ⚠ BREAKING CHANGES

* :pre_write extensions now are run after rendering the graph, but before writing to disk. Previously, the body content of each page would not have been converted yet, but now it will. This should enable anyone to modify the HTML after other extensions converter it.
* pass assigns to post/page extension rendering ([#102](https://github.com/elixir-tools/tableau/issues/102))

### Features

* add optional config/1 callback to extensions ([#104](https://github.com/elixir-tools/tableau/issues/104)) ([d1a5480](https://github.com/elixir-tools/tableau/commit/d1a548096a44b89e6b62ebdbc76d002f9be7481c))
* allow extensions to manually insert pages into the graph ([#96](https://github.com/elixir-tools/tableau/issues/96)) ([19f4ce5](https://github.com/elixir-tools/tableau/commit/19f4ce5f66916a57d3e4e5d16f1aeb844408a0b3))
* allow other markup formats ([#100](https://github.com/elixir-tools/tableau/issues/100)) ([0d9959f](https://github.com/elixir-tools/tableau/commit/0d9959f6300609da0bf2874742512d0e751bea90))
* pass assigns to post/page extension rendering ([#102](https://github.com/elixir-tools/tableau/issues/102)) ([896bf7f](https://github.com/elixir-tools/tableau/commit/896bf7f1dd3ce0c4f94a8e80de9fedbbca29c3fc))
* run pre-write extensions after render but before write ([#111](https://github.com/elixir-tools/tableau/issues/111)) ([b09ce49](https://github.com/elixir-tools/tableau/commit/b09ce49c6213fcddcfc99c32b41a15528337887e))


### Bug Fixes

* actually respect the "enabled" key in `use Tableau.Extension` ([b09ce49](https://github.com/elixir-tools/tableau/commit/b09ce49c6213fcddcfc99c32b41a15528337887e))
* allow atom layout module names ([#108](https://github.com/elixir-tools/tableau/issues/108)) ([c128593](https://github.com/elixir-tools/tableau/commit/c1285938d06d2e7ce6b053ae788cdad47670ed2a))
* bump MDEx and fix breaking change ([19f4ce5](https://github.com/elixir-tools/tableau/commit/19f4ce5f66916a57d3e4e5d16f1aeb844408a0b3))
* ensure extensions are loading ([9585d16](https://github.com/elixir-tools/tableau/commit/9585d1631240b1992bb3f6e51b5e5477eccadaee))
* handle token format correctly in MDExConverter ([#105](https://github.com/elixir-tools/tableau/issues/105)) ([9585d16](https://github.com/elixir-tools/tableau/commit/9585d1631240b1992bb3f6e51b5e5477eccadaee))
* handle token format correctly in RSSExtension ([9585d16](https://github.com/elixir-tools/tableau/commit/9585d1631240b1992bb3f6e51b5e5477eccadaee))
* **posts,regression:** sort posts ([0677ce6](https://github.com/elixir-tools/tableau/commit/0677ce67985e193d41e61f88045dc118236dd4ad))


### Performance Improvements

* improve live reload performance ([#110](https://github.com/elixir-tools/tableau/issues/110)) ([e0cc106](https://github.com/elixir-tools/tableau/commit/e0cc106343d1762ccc2f438a967e19194d5417b1))
* render the graph in parallel ([b09ce49](https://github.com/elixir-tools/tableau/commit/b09ce49c6213fcddcfc99c32b41a15528337887e))

## [0.17.1](https://github.com/elixir-tools/tableau/compare/v0.17.0...v0.17.1) (2024-08-16)


### Bug Fixes

* properly encode title in rss feed ([#85](https://github.com/elixir-tools/tableau/issues/85)) ([9382afa](https://github.com/elixir-tools/tableau/commit/9382afa3ca14149a9fac1b6a4f8b2044d6e0f946))

## [0.17.0](https://github.com/elixir-tools/tableau/compare/v0.16.0...v0.17.0) (2024-07-17)


### Features

* **extensions:** pre-write extensions ([#83](https://github.com/elixir-tools/tableau/issues/83)) ([12d1c7f](https://github.com/elixir-tools/tableau/commit/12d1c7f8f0c566fc469e6abb3415c21a3c989b10))


### Bug Fixes

* **extensions:** don't require a config module ([12d1c7f](https://github.com/elixir-tools/tableau/commit/12d1c7f8f0c566fc469e6abb3415c21a3c989b10))

## [0.16.0](https://github.com/elixir-tools/tableau/compare/v0.15.3...v0.16.0) (2024-03-10)


### ⚠ BREAKING CHANGES

* uri encode permalink

  This is a breaking change because previously un-encoded characters might be encoded now. Please check your pages and add redirects for any that have changed.

### Bug Fixes

* uri encode permalink ([3fbc2c7](https://github.com/elixir-tools/tableau/commit/3fbc2c7ad885209dc1cf92a1265519e59bc96d9f)), closes [#80](https://github.com/elixir-tools/tableau/issues/80)

## [0.15.3](https://github.com/elixir-tools/tableau/compare/v0.15.2...v0.15.3) (2024-02-26)


### Bug Fixes

* remove unused dep ([d626cb8](https://github.com/elixir-tools/tableau/commit/d626cb841cb97ed16d94fcfcce1da9453c108fe6))

## [0.15.2](https://github.com/elixir-tools/tableau/compare/v0.15.1...v0.15.2) (2024-01-28)


### Bug Fixes

* add base_path to config schema ([#68](https://github.com/elixir-tools/tableau/issues/68)) ([03a43d4](https://github.com/elixir-tools/tableau/commit/03a43d4d9e992d4f9268d482d3cd427a99b3f7e0))

## [0.15.1](https://github.com/elixir-tools/tableau/compare/v0.15.0...v0.15.1) (2024-01-22)


### Bug Fixes

* urls in rss output ([#47](https://github.com/elixir-tools/tableau/issues/47)) ([66d15d4](https://github.com/elixir-tools/tableau/commit/66d15d41049fc5e7b72c7d5514c150e401600542))

## [0.15.0](https://github.com/elixir-tools/tableau/compare/v0.14.3...v0.15.0) (2024-01-08)


### Features

* configurable development server root  ([#59](https://github.com/elixir-tools/tableau/issues/59)) ([641cb20](https://github.com/elixir-tools/tableau/commit/641cb2062cf146c5c3b66553667d1b933321f75a))

## [0.14.3](https://github.com/elixir-tools/tableau/compare/v0.14.2...v0.14.3) (2024-01-07)


### Performance Improvements

* speed up page and post extensions ([#64](https://github.com/elixir-tools/tableau/issues/64)) ([357d0f9](https://github.com/elixir-tools/tableau/commit/357d0f9b2fb46be8cbb87793704a93c92b9130c6)), closes [#48](https://github.com/elixir-tools/tableau/issues/48)

## [0.14.2](https://github.com/elixir-tools/tableau/compare/v0.14.1...v0.14.2) (2024-01-07)


### Bug Fixes

* start telemetry app to handle warning logs ([#62](https://github.com/elixir-tools/tableau/issues/62)) ([97e1fba](https://github.com/elixir-tools/tableau/commit/97e1fba6f91f0b7872bcd904b90286572974ce77)), closes [#61](https://github.com/elixir-tools/tableau/issues/61)

## [0.14.1](https://github.com/elixir-tools/tableau/compare/v0.14.0...v0.14.1) (2024-01-04)


### Bug Fixes

* rss moduledoc ([#55](https://github.com/elixir-tools/tableau/issues/55)) ([788f09d](https://github.com/elixir-tools/tableau/commit/788f09d4c695dbc572fb974da6f71a13aceca372))

## [0.14.0](https://github.com/elixir-tools/tableau/compare/v0.13.0...v0.14.0) (2023-12-30)


### ⚠ BREAKING CHANGES

* improve slug generation ([#51](https://github.com/elixir-tools/tableau/issues/51))

### Bug Fixes

* improve slug generation ([#51](https://github.com/elixir-tools/tableau/issues/51)) ([bbc702d](https://github.com/elixir-tools/tableau/commit/bbc702dcaf3fde50d73b851a2df07900400e0ef6))

## [0.13.0](https://github.com/elixir-tools/tableau/compare/v0.12.0...v0.13.0) (2023-12-30)


### ⚠ BREAKING CHANGES

* use DateTimeParser for date property ([#49](https://github.com/elixir-tools/tableau/issues/49))

### Features

* use DateTimeParser for date property ([#49](https://github.com/elixir-tools/tableau/issues/49)) ([78cb446](https://github.com/elixir-tools/tableau/commit/78cb446e87a1b9097042d140888fe61406224ed3))

## [0.12.0](https://github.com/elixir-tools/tableau/compare/v0.11.1...v0.12.0) (2023-11-15)


### Features

* sitemap extension ([#45](https://github.com/elixir-tools/tableau/issues/45)) ([f9a97a3](https://github.com/elixir-tools/tableau/commit/f9a97a3536ba547012882222c39da80eb907addf))

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
