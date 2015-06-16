require '../hadoopconf/hadoop_conf'

HADOOP_SERVER_IP='10.0.0.146'
HADOOP_SERVER_PORT=8088

t = HadoopConfig.new({
   :server => HADOOP_SERVER_IP,
   :port => HADOOP_SERVER_PORT,
   :timeout => 5
})

puts t
puts t.server_url
puts t.fetch
puts t.rules_default
puts t.properties
puts t.errors.full_messages