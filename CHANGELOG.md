
#### 0.1.5

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
