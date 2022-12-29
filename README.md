# Csvbuilder::Dynamic::Columns::Importer

[Csvbuilder::Dynamic::Columns::Importer](https://github.com/joel/csvbuilder-dynamic-columns-importer) is part of the [csvbuilder-collection](https://github.com/joel/csvbuilder)

The Dynamic Columns Importer contains the implementation for importing CSV data with a variable group, for instance, an object with categories.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add csvbuilder-dynamic-columns-importer

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install csvbuilder-dynamic-columns-importer

## Usage

Let's consider a Developer with languages skill.

```ruby
class UserCsvImportModel
  include Csvbuilder::Model
  include Csvbuilder::Import

  column :name, header: "Developer"

  dynamic_column :skills
end
```

The Row can iterate over the Dynamic Columns. Here are `skills`, and get access to the cell values.

For each entry of the Dynamic Columns, here `skills`, a method called by the singular version name of the declared Dynamic Columns will be called here `skill`.

This method provides the header value and the cell value; however, it returns only the cell value by default; if that is all that is needed, there is no need for overriding.

However, it is safe to override this method to put in place any logic needed.

For instance, returning the header and cell values to figure out what the importer has to do with them.

Check out the following example:

```ruby
class UserCsvImportModel
  include Csvbuilder::Model
  include Csvbuilder::Import

  column :name, header: "Developer"

  dynamic_column :skills

  def user
    User.where(name: name).take
  end

  def skill(value, header_value)
    { skill: header_value, has: value }
  end
end
```

```ruby
[
  ["Developer", "Ruby", "Python", "Javascript"],
  ["Bob"      ,    "1",      "0",          "1"],
]
```

```ruby
options = {}

Csvbuilder::Import::File.new(file.path, UserCsvImportModel, options).each do |row_model|
  row_model.skills.each do |skill_data|
    skill = Skill.find_or_create_by(name: skill_data[:skill])
    row_model.user.skills << skill if skill_data[:has] == "1"
  end
end

User.where(name: "Bob").take.skills.pluck(:name)
# => ["Ruby", "Javascript"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joel/csvbuilder-dynamic-columns. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/csvbuilder-dynamic-columns/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Csvbuilder::Dynamic::Columns project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/csvbuilder-dynamic-columns/blob/main/CODE_OF_CONDUCT.md).
