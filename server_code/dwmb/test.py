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
		#self.send_request('/dump', {"yes": True})
		self.send_request('/drop', {"yes": True})
		#self.send_request('/dump', {"yes": True})

	def tearDown(self):
		pass

	def prepare_data(self, data):
		json_encoded = json.dumps(data)
		data = urllib.urlencode({'data': json_encoded})
		return data

	def send_request(self, url, data):
		full_url = "http://localhost:12345/" + str(url)
		req = urllib2.Request(full_url, self.prepare_data(data))
		response = urllib2.urlopen(req)
		the_page = response.read()
		return the_page

	def send_default_poop(self, rfid='123'):
		result = self.send_request('/poop', {
			'rfid' : rfid
		})
		decoded = json.loads(result)
		code = ""
		if ("code" in decoded):
			code = decoded["code"]

		print("send_default_poop: result: ", result)

		return result, code

	def send_default_registration(self, code):
		result = self.send_request('/register', {
			'username' : 'ivankadraganova',
			'password' : 'password',
			'email' : 'ivanka@abv.bg',
			'code' : code
		})

		print("send_default_registration: result: ", result)

		return result

	def send_default_alive(self, slots=[0, 0, 0, 0, 0, 0, 0, 0]):
		result = self.send_request('/alive', {
			'slots': slots,
			'key': "6x9=42"
		})

		print("send_default_alive: result: ", result)

		return result

	def test_poop_returns_code(self):
		result, code = self.send_default_poop()
		result = json.loads(result)

		code = result["code"]
		self.assertTrue("code" in result)

	def test_registration(self):
		result, code = self.send_default_poop()

		result = self.send_default_registration(code)

		self.assertEqual(result, '{"status":"ok","message":"registered"}')

	def test_poop_alive1(self):
		result, code = self.send_default_poop()

		result = self.send_default_alive([1, 0, 0, 0, 0, 0, 0, 0])

		self.assertEqual(result, '{"status":"ok","message":"connected"}')

	def test_poop_register_alive1(self):
		result, code = self.send_default_poop()

		result = self.send_default_registration(code);

		result = self.send_default_alive([1, 0, 0, 0, 0, 0, 0, 0])

		self.assertEqual(result, '{"status":"ok","message":"connected"}')

	def test_theft(self):
		result, code = self.send_default_poop()

		result = self.send_default_alive([1, 0, 0, 0, 0, 0, 0, 0])

		result = self.send_default_alive([0, 0, 0, 0, 0, 0, 0, 0])

		self.assertEqual(result, '{"status":"error","message":"theft"}')

	def test_poop_alive1_poop_alive0(self):
		result, code = self.send_default_poop()

		result = self.send_default_alive([1, 0, 0, 0, 0, 0, 0, 0])

		result, code = self.send_default_poop()

		result = self.send_default_alive([0, 0, 0, 0, 0, 0, 0, 0])

		self.assertEqual(result, '{"status":"ok","message":"disconnected"}')

	def test_poop_register_alive1_poop_alive0(self):
		result, code = self.send_default_poop()

		result = self.send_default_registration(code)

		result = self.send_default_alive([1, 0, 0, 0, 0, 0, 0, 0])

		result, code = self.send_default_poop()

		result = self.send_default_alive([0, 0, 0, 0, 0, 0, 0, 0])

		self.assertEqual(result, '{"status":"ok","message":"disconnected"}')

	def test_poop_poop(self):
		result, code = self.send_default_poop()

		result, code = self.send_default_poop()
		self.assertEqual(code, "")

	def test_drop(self):
		pass

if __name__ == '__main__':
    unittest.main()
