import requests
nums = ['6029',
'6066',
'6091',
'6066',
'6016',
'6022',
'6073',
'6006',
'6106',
'6075',
'6058',
'6059',
'6054',
'6030',
'6061',
'6013',
'6064',
'6042',
'6003',
'6035',
'6005',
'6002',
'6008',
'6056',
'6023',
'6048',
'6025',
'6043',
'6100',
'6010',
'6028',
'6187',
'6027',
'6070',
'6063',
'6007',
'6074',
'6181',
'6069',
'6017',]
#nums = ['converse-factory-store-grapevine-mills','converse-factory-store-grapevine-mills','converse-factory-store-grapevine-mills','converse-factory-store-grapevine-mills','converse-factory-store-grapevine-mills','converse-factory-store-grapevine-mills','converse-factory-store-grapevine-mills']
data = [
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  },
  {
    "email": "donotreply@lordandtaylor.com"
  }
]

for index,object in enumerate(data):
	r = requests.put('http://lordandtaylor.brickworksoftware.com/api/v3/admin/stores/'+nums[index]+'/?api_key=XXXXXXXXX&store_number="TRUE"', json=object)
	print r
	
print r.json()
