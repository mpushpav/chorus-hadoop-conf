This repository acts as a sub-repository of the Chorus repository found [here](https://github.com/chorus/chorus/)

It provides code to fetch and filter the XML configuration of a hadoop cluster.

## Configuring

See [rules.default.yml](https://github.com/midnighteuler/chorus-hadoop-conf/blob/master/hadoopconf/rules.default.yml) for how to alter the default filter rules.

## Testing

Run the test ([test/hadoop_conf_test.rb](https://github.com/midnighteuler/chorus-hadoop-conf/blob/master/test/hadoop_conf_test.rb)) with:

```sh
cd test
ruby ./hadoop_conf_test.rb
```

See [test/manual_run.rb](https://github.com/midnighteuler/chorus-hadoop-conf/blob/master/test/manual_run.rb) for a simple example invocation.