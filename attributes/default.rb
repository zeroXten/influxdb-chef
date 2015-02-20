default.influxdb.version = 'latest'
default.influxdb.package.base_url = 'http://s3.amazonaws.com/influxdb/'

case node.platform_family
when 'debian'
  default.influxdb.package.name = node.kernel.machine == 'x86_64' ? "influxdb_#{node.influxdb.version}_amd64.deb" : "influxdb_#{node.influxdb.version}_i386.deb"
when 'rhel'
  default.influxdb.package.name = node.kernel.machine == 'x86_64' ? "influxdb-#{node.influxdb.version}-1.x86_64.rpm" : "influxdb-#{node.influxdb.version}-1.i686.rpm"
else
  Chef::Log.fatal "Not a supported platform family: #{node.platform_family}"
  raise
end

default.influxdb.user = 'influxdb'
default.influxdb.group = 'influxdb'

default.influxdb.config_file = '/opt/influxdb/shared/config.toml'
default.influxdb.config_cookbook = 'influxdb'

default.influxdb.limits.nofile.domain = node.influxdb.user
default.influxdb.limits.nofile.type = '-'
default.influxdb.limits.nofile.item = 'nofile'
default.influxdb.limits.nofile.value = '65536'

case node.platform_family
when 'debian'
  default.influxdb.enable_pam_limits = true
else
  default.influxdb.enable_pam_limits = false
end

# Generated from default config file using TOML.load_file but toml
# gem doesn't actually work properly. Leaving this here anyway.
default.influxdb.config = Mash.new ({
  'bind-address' => '0.0.0.0',
  'reporting-disabled' => false,
  'logging' => {
    'level' => 'info',
    'file' => '/opt/influxdb/shared/log.txt'
  },
  'admin' => {
    'port' => 8083,
    'assets' => '/opt/influxdb/current/admin'
  },
  'api' => {
    'port' => 8086,
    'read-timeout' => '5s'
  },
  'input_plugins' => {
    'graphite' => {
      'enabled' => false,
      'port' => 2003,
      'database' => 'graphite',
      'udp_enabled' => false
    },
    'udp' => {
      'enabled' => false
    },
    'udp_servers' => [{
      'enabled' => false
    }]
  },
  'raft' => {
    'port' => 8090,
    'dir' => '/opt/influxdb/shared/data/raft',
    'election-timeout' => '1s'
  },
  'storage' => {
    'dir' => '/opt/influxdb/shared/data/db',
    'write-buffer-size' => 10000
  },
  'cluster' => {
    'protobuf_port' => 8099,
    'protobuf_timeout' => '2s',
    'protobuf_heartbeat' => '200ms',
    'protobuf_min_backoff' => '1s',
    'protobuf_max_backoff' => '10s',
    'write-buffer-size' => 10000,
    'max-response-buffer-size' => 100,
    'concurrent-shard-query-limit' => 10
  },
  'leveldb' => {
    'max-open-files' => 40,
    'lru-cache-size' => '200m',
    'max-open-shards' => 0,
    'point-batch-size' => 100,
    'write-batch-size' => 5000000
  },
  'sharding' => {
    'replication-factor' => 1,
    'short-term' => {
      'duration' => '7d',
      'split' => 1
    },
    'long-term' => {
      'duration' => '30d',
      'split' => 1
    }
  },
  'wal' => {
    'dir' => '/opt/influxdb/shared/data/wal',
    'flush-after' => 1000,
    'bookmark-after' => 1000,
    'index-after' => 1000,
    'requests-per-logfile' => 10000
  }
})
