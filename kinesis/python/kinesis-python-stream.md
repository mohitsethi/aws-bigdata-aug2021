

### Read Data from Kinesis Stream

```
>>> from boto import kinesis
>>> import time
>>>
>>> kinesis = kinesis.connect_to_region("eu-west-1")
>>> shard_id = 'shardId-000000000000' #we only have one shard!
>>> shard_it = kinesis.get_shard_iterator("BotoDemo", shard_id, "LATEST")["ShardIterator"]
>>> while 1==1:
...     out = kinesis.get_records(shard_it, limit=2)
...     shard_it = out["NextShardIterator"]
...     print out;
...     time.sleep(0.2)
...
{u'Records': [{u'PartitionKey': u'partitionkey', u'Data': u'{"lastname": "Rau", "age": 23, "firstname": "Peyton", "gender": "male"}', u'SequenceNumber': u'49547280908463336004254488250517179461390244620594577410'}, {u'PartitionKey': u'partitionkey', u'Data': u'{"lastname": "Mante", "age": 29, "firstname": "Betsy", "gender": "male"}', u'SequenceNumber': u'49547280908463336004254488250518388387209859249769283586'}], u'NextShardIterator': u'AAAAAAAAAAEvI7MPAuwLucWMwYtZnATetztUUTqgtQaTaihyV/+buCmSqBdKnAwv2dMNeGlYo3fvYCcH6aI/A+DtG3uq+MnG8AlyrX7UrHnlX5OF0xG/IEhSJyyToPvwtJ8odDoWShib3bjuk+944QcsPrRRsUsBNx6xyKgnY+xi9lXvweiImL1ByK5Bdj0sLoRp/9nBWfw='}
```

Now you can analyze the latest data in Amazon Kinesis and visualize this data in a dashboard. The following code calculates the average age of the simulated data in Amazon Kinesis.

```
>>> from boto import kinesis
>>> from boto import kinesis 
>>> from __future__ import division
>>> import time
>>>
>>> kinesis = kinesis.connect_to_region("eu-west-1")
>>> shard_id = 'shardId-000000000000' #we only have one shard!
>>> shard_it = kinesis.get_shard_iterator("BotoDemo", shard_id, "LATEST")["ShardIterator"]
>>> i=0
>>> sum=0
>>> while 1==1:
...     out = kinesis.get_records(shard_it, limit=2)
...     for o in out["Records"]:
...         jdat = json.loads(o["Data"])
...         sum = sum + jdat["age"]
...         i = i+1
...     shard_it = out["NextShardIterator"]
...     if i <> 0:
...         print "Average age:" + str(sum/i)
...     time.sleep(0.2)
...

```

Re-Shard the Amazon Kinesis Stream

Elasticity and scaling are core features of Amazon Web Services. So far, the described use-case does not scale efficiently. An Amazon Kinesis shard is limited by the number of read and write operations per second and capacity. To scale your application, you can add and remove shards at any time. So let’s split the current shard into two shards and use a more efficient partition key to write into Amazon Kinesis.

```
>>> sinfo = kinesis.describe_stream("BotoDemo")
>>> hkey = int(sinfo["StreamDescription"]["Shards"][0]["HashKeyRange"]["EndingHashKey"])
>>> shard_id = 'shardId-000000000000' #we only have one shard!
>>> kinesis.split_shard("BotoDemo", shard_id, str((hkey+0)/2))
>>>
>>> for user in Users().generate(50):
...     print user
...     kinesis.put_record("BotoDemo", json.dumps(user), str(hash(user["gender"])))
...
{'lastname': 'Hilpert', 'age': 16, 'firstname': 'Mariah', 'gender': 'female'}
{u'ShardId': u'shardId-000000000001', u'SequenceNumber': u'49547282457763007181772469762801693095350958144429752338'}
{'lastname': 'Beer', 'age': 13, 'firstname': 'Ruthe', 'gender': 'male'}
{u'ShardId': u'shardId-000000000002', u'SequenceNumber': u'49547282457785307926971000385136875291940648846406713378'}
{'lastname': 'Boehm', 'age': 30, 'firstname': 'Lysanne', 'gender': 'female'}
{u'ShardId': u'shardId-000000000001', u'SequenceNumber': u'49547282457763007181772469762802902021170572773604458514'}
{'lastname': 'Bechtelar', 'age': 17, 'firstname': 'Darrick', 'gender': 'male'}
{u'ShardId': u'shardId-000000000002', u'SequenceNumber': u'49547282457785307926971000385138084217760263475581419554'}
```

Optimized Put Operations

```
>>> i=0;
>>> records=[];
>>> for user in Users().generate(50):
...     i=i+1
...     record = {'Data': json.dumps(user),'PartitionKey': str(hash(user["age"]))}
...     records.append(record)
...     if i%5==0:
...         kinesis.put_records(records, "BotoDemo")
...         records=[];
```


When you have finished with this tutorial, delete your Amazon Kinesis stream.
```
>>> kinesis.delete_stream("BotoDemo")
```

