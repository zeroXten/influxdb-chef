# influxdb

Installs InfluxDB. See http://influxdb.com/ for details

## Supported Platforms

* debian
* rhel

## Attributes

See the defaults.rb file for what can be configured.

## Usage

### influxdb::default

Include `influxdb` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[influxdb::default]"
  ]
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: Fraser Scott (fraser.scott@gmail.com)
