# Mongoid Monkey [![Build Status](https://travis-ci.org/johnnyshields/mongoid_monkey.svg?branch=master)](https://travis-ci.org/johnnyshields/mongoid_monkey)

### Monkey Patches for Mongoid

Mongoid Monkey is a collection of monkey patches for Mongoid 3, 4, 5, including feature
backports, fixes, and forward compatibility.

### Warning

The patches in this gem will change/override the behavior of Mongoid. While effort has been
made to be as backward compatible as possible, use at your own risk.

### Installation

In your Gemfile, require this gem **after** requiring `mongoid`.

### Version Requirement

* Works with Mongoid 3, 4, 5
* Due to the `list_collections` patch, this gem requires **at least MongoDB 3.0.** Other patches will work on older MongoDB versions.

### Patch List

Installing this gem will apply all monkey patches for the Mongoid version you are using.
If you would only like some of the patches, please copy and paste the code to your app directly
(e.g. `/config/initializers` if using Rails.)

`●` = This gem adds support
`×` = This gem does not yet support (PRs welcome!)
`○` = Already supported natively

| File | Description | 3 | 4 | 5 |
| --- | --- | --- | --- | --- |
| `atomic.rb` | Backport syntax change of atomic query methods. | ● | ○ | ○ |
| `big_decimal.rb` | Fixes buggy BigDecimal behavior. | ● | ● | ● |
| `db_commands.rb` | Use MongoDB 3.0+ command syntax; required for WiredTiger. | ● | ● | ○ |
| `instrument.rb` | Backport instrumentation change to Moped 1. | ● | ○ | ○ |
| `reorder.rb` | Backport `Criteria#reorder` method from Mongoid 4. | ● | ○ | ○ |
| `only_pluck_localized.rb` | Backport [PR #4299](https://github.com/mongodb/mongoid/pull/4299) from Mongoid 6 which fixes `#only` and `#pluck` with localized fields. | ● | × | × |

### License

* This project is licensed under the MIT License.
* Some code in this repo is adapted from the fantastic work of Durran Jordan, et. al. on Mongoid.
* (c) Copyright 2016 Johnny Shields.
