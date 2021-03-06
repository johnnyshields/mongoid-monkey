
#### 0.3.2

* Refactor "push_each.rb" patch.

#### 0.3.1

* Use Array#wrap with `$each` method to be safe.

#### 0.3.0

* Replace `$pushAll` with `$push + $each`.
* Aggregate methods (`max`, `sum`, etc) must use cursor in MongoDB 3.6+.
* Config `safe: true` should send WriteConcern: Acknowledged `w: 1` to database (and not `safe: true`).

#### 0.2.5

* Improvements to `:touch` callback support on `:embedded_in`.
* Backport fix to an infinite loop issue related to `:touch` callbacks from Mongoid 6.

#### 0.2.4

* Support aliases for index options.

#### 0.2.3

* Backport valid index options from Mongoid 6.

#### 0.2.2

* Backport [Issue #3310](https://github.com/mongodb/mongoid/commit/a94c2f43573e58f973913c881ad9d11d62bf857c) from Mongoid 4 to add `:touch` option to `embedded_in`.

#### 0.2.1

* Bug Fix: Remove accidental `puts` call.

#### 0.2.0

* Backport [PR #4299](https://github.com/mongodb/mongoid/pull/4299) from Mongoid 6 to Mongoid 3 which fixes `#only`, `#without`, and `#pluck` with localized fields.

#### 0.1.4

* Add atomic persistence support for Mongoid 3 (previously only contextual was supported).

#### 0.1.3

* Support index-related Rake tasks.
* Refactor if statements to be inside individual patch files for clarity.

#### 0.1.2

* More index support, port index-related tests from Mongoid lib.

#### 0.1.1

* Add index support to WiredTiger patch.
* Rename `list_collections.rb` to `db_commands.rb`

#### 0.1.0

* Initial release
