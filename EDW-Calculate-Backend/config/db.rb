require 'sequel'

host = '16.152.122.102'
user = 'postgres'
password = '123456'
db = 'EDWData'


EDWDriver = Sequel.postgres({host: host, user: user, password: password, database: db,})

