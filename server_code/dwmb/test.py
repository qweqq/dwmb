from __future__ import print_function
import unittest
import urllib2
import urllib
import json
import os

class Blah(unittest.TestCase):
	@classmethod
	def setUpClass(cls):
		pass
	@classmethod
	def tearDownClass(cls):
		pass

	def setUp(self):
		self.send_request('/dump', {"yes": True})
		self.send_request('/drop', {"yes": True})
		self.send_request('/dump', {"yes": True})

	def tearDown(self):
		pass

	def prepare_data(self, data):
		json_encoded = json.dumps(data)
		data = urllib.urlencode({'data': json_encoded})
		return data

	def send_request(self, url, data):
		full_url = "http://localhost:1234/" + str(url)
		req = urllib2.Request(full_url, self.prepare_data(data))
		response = urllib2.urlopen(req)
		the_page = response.read()
		return the_page

	def test_gosho(self):

		user = self.send_request('/poop', {
			'rfid' : '123'
		})
		user = json.loads(user)
		print(user)
		code = user["code"]

		the_page = self.send_request('/register', {
			'username' : 'ivankadraganova',
			'password' : 'password',
			'email' : 'ivanka@abv.bg',
			'code' : code
		})

		print("response: " + str(the_page))

	def test_poop_alive(self):
		result = self.send_request('/poop', {
			'rfid' : '123'
		})

		result = json.loads(result)
		print(result)
		code = result["code"]
		self.assertTrue("code" in result)

		result = self.send_request('/alive', {
			'slots': [
				1, 0, 0, 0, 0, 0, 0, 0
			],
			'key': "6x9=42"
		})
		self.assertEqual(result, '{"status":"ok","message":"connected"}')

	def test_poop_register_alive(self):
		result = self.send_request('/poop', {
			'rfid' : '123'
		})

		result = json.loads(result)
		print(result)
		code = result["code"]
		self.assertTrue("code" in result)

		the_page = self.send_request('/register', {
			'username' : 'ivankadraganova',
			'password' : 'password',
			'email' : 'ivanka@abv.bg',
			'code' : code
		})

		result = self.send_request('/alive', {
			'slots': [
				1, 0, 0, 0, 0, 0, 0, 0
			],
			'key': "6x9=42"
		})
		self.assertEqual(result, '{"status":"ok","message":"connected"}')

	def test_theft(self):

		result = self.send_request('/poop', {
			'rfid' : '123'
		})

		result = json.loads(result)
		print(result)
		code = result["code"]
		self.assertTrue("code" in result)

		result = self.send_request('/alive', {
			'slots': [
				1, 0, 0, 0, 0, 0, 0, 0
			],
			'key': "6x9=42"
		})
		self.assertEqual(result, '{"status":"ok","message":"connected"}')

		result = self.send_request('/alive', {
			'slots': [
				0, 0, 0, 0, 0, 0, 0, 0
			],
			'key': "6x9=42"
		})
		self.assertEqual(result, '{"status":"error","message":"theft"}')

	def test_drop(self):
		pass

if __name__ == '__main__':
    unittest.main()
